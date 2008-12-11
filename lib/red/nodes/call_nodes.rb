module Red
  class CallNode < String # :nodoc:
    class Ampersand < CallNode # :nodoc:
      # [:block_pass, {expression}, {expression}]
      def initialize(block_pass_sexp, function_call_sexp, options)
        block_string = "%s.m$to_proc().__block__" % block_pass_sexp.red!(:as_receiver => true)
        function_call = function_call_sexp.red!(options.merge(:block_string => block_string))
        self << "%s" % [function_call]
      end
    end
    
    class Block < CallNode # :nodoc:
      # [:iter, {expression}, {0 | :dasgn_curr | :masgn, [:array, {:dasgn_curr, :dasgn_curr, ...}]}, (expression | :block)]
      def initialize(function_call_sexp, block_arguments_array_sexp, block_body_sexp = nil, options = {})
        (options = block_body_sexp) && (block_body_sexp = [:block, [:nil]]) if block_body_sexp.is_a?(::Hash)
        block_arguments = block_arguments_array_sexp.is_sexp?(:masgn) ? block_arguments_array_sexp.assoc(:array)[1..-1].map {|dasgn_curr| dasgn_curr.last.red! }.join(",") : (block_arguments_array_sexp && block_arguments_array_sexp != 0 ? block_arguments_array_sexp.last : nil).red!
        block_body      = (block_body_sexp.is_sexp?(:block) ? block_body_sexp : [:block, block_body_sexp]).red!(:force_return => true)
        block_string    = "function(%s){%s;}" % [block_arguments, block_body]
        block_string   << ".m$(this)" unless [:instance_eval, :class_eval].include?(function_call_sexp.last)
        function_call   = function_call_sexp.red!(options.merge(:block_string => block_string))
        self << "%s" % [function_call]
      end
    end
    
    class Defined < CallNode # :nodoc:
      # [:defined, {expression}]
      def initialize(expression_sexp, options)
        expression = expression_sexp.red!(:as_argument => true)
        self << "!(typeof(%s)=='undefined')" % [expression]
      end
    end
    
    class Match # :nodoc:
    # # [:match2, {expression}, {expression}] => when first expression is RegExp e.g. /foo/ =~ foo | /foo/ =~ /foo/
    # def initialize(regex, expression)
    #   @regex, @expression = [regex, expression].build_nodes
    # end
    # 
    # def compile_node(options = {}) # :nodoc:
    #   regex = @regex.compile_node
    #   expression = @expression.compile_node(:as_argument => true)
    #   "%s.match(%s)" % [regex, expression]
    # end
      
      class Reverse < Match # :nodoc:
      # # [:match3, {expression}, {expression}] => when only second expression is RegExp e.g. foo =~ /foo/
      # def initialize(expression, regex)
      #   @regex, @expression = [regex, expression].build_nodes
      # end
      end
    end
    
    class Method < CallNode # :nodoc:
      class ExplicitReceiver < Method # :nodoc:
        # [:call, {expression}, :foo, (:array, {expression}, {expression}, ...)]
        def initialize(receiver_sexp, function_sexp, *arguments_array_sexp)
          options     = arguments_array_sexp.pop
          receiver    = receiver_sexp.red!(:as_receiver => true)
          function    = (METHOD_ESCAPE[function_sexp] || function_sexp).red!
          args_array  = arguments_array_sexp.last.is_sexp?(:array) ? arguments_array_sexp.last[1..-1].map {|argument_sexp| argument_sexp.red!(:as_argument => true)} : []
          args_array += [options[:block_string]] if options[:block_string]
          arguments   = args_array.join(",")
          self << "%s.m$%s(%s)" % [receiver, function, arguments]
          unless @@red_import
            @@red_methods |= [function_sexp]
            @@red_methods |= ([arguments_array_sexp.last[1].last.to_sym] rescue []) if function_sexp == :send && arguments_array_sexp.last.is_sexp?(:array)
          end
        end
      end
      
      class ImplicitReceiver < Method # :nodoc:
        # [:vcall]
        # [:fcall, :foo, (:array, {expression}, {expression}, ...)]
        def initialize(function_sexp, *arguments_array_sexp)
          options     = arguments_array_sexp.pop
          function    = (METHOD_ESCAPE[function_sexp] || function_sexp).red!
          args_array  = arguments_array_sexp.last.is_sexp?(:array) ? arguments_array_sexp.last[1..-1].map {|argument_sexp| argument_sexp.red!(:as_argument => true)} : []
          args_array += [options[:block_string]] if options[:block_string]
          arguments   = args_array.join(",")
          case function_sexp
          when :require
            basename    = File.basename((arguments_array_sexp.assoc(:array).assoc(:str).last rescue ''))
            dirname     = File.dirname((arguments_array_sexp.assoc(:array).assoc(:str).last rescue ''))
            pretty_name = dirname == '.' ? basename : File.join(dirname, basename)
            unless @@red_required.include?(basename)
              @@red_required |= [basename]

              file = Red.file_in_load_path(dirname, basename)

              raise ArgumentError, "no such file to load -- #{pretty_name}" if file.nil?

              stored_filepath = @@red_filepath
              @@red_filepath = File.dirname(file)
              self << hush_warnings { File.read(file).translate_to_sexp_array }.red!
              @@red_filepath = stored_filepath
            else
              self << "false";
            end
          when :[]
            self << "this.m$%s(%s)" % [function, arguments]
          when :block_given?
            self << "m$block_given_bool(%s.__block__)" % (@@red_block_arg || 'nil')
          else
            if Red.debug
              error_function = arguments.empty? ? 'n' : 'm'
              self << "((this.m$%s&&this.m$%s(%s))||(window.m$%s&&window.m$%s(%s))||$%s(this,'%s'))" % [function,function,arguments,function,function,arguments,error_function,function_sexp]
            else
              arguments = ','+arguments unless arguments.empty?
              self << "(this.m$%s||window.m$%s).call(this%s)" % [function, function, arguments]
            end
            @@red_methods |= [function_sexp] unless @@red_import
          end
        end
      end
    end
    
    class Super < CallNode # :nodoc:
      # [:super, (:array, {expression}, {expression}, ...)]
      def initialize(*arguments_array_sexp)
        options     = arguments_array_sexp.pop
        args_array  = arguments_array_sexp.last.is_sexp?(:array) ? arguments_array_sexp.last[1..-1].map {|argument_sexp| argument_sexp.red!(:as_argument => true)} : []
        args_array  = ["this"] + args_array
        args_array += [options[:block_string]] if options[:block_string]
        arguments   = args_array.join(",")
        self << "this.m$class().m$superclass().prototype.m$%s.call(%s)" % [@@red_function, arguments]
      end
      
      class Delegate < Super # :nodoc:
        # [:zsuper]
        # FIX: Super::Delegate ignores block_string option when called inside an :iter e.g. super { foo }; this is an easy enough fix but annoying in that it needs fixing
        def initialize(*arguments_array_sexp)
          options = arguments_array_sexp.pop
          self << "this.m$class().m$superclass().prototype.m$%s.apply(this,arguments)" % [@@red_function]
        end
      end
    end
    
    class Yield < CallNode # :nodoc:
      # [:yield, (expression | :array, {expression}, {expression}, ...)]
      def initialize(arguments_array_sexp = nil, options = {})
        (options = arguments_array_sexp) && (arguments_array_sexp = [:array]) if arguments_array_sexp.is_a?(Hash)
        argument_sexps = arguments_array_sexp.is_sexp?(:array) ? arguments_array_sexp[1..-1] || [] : [arguments_array_sexp]
        args_array     = argument_sexps.map {|argument_sexp| argument_sexp.red!(:as_argument => true)}
        arguments      = args_array.join(",")
        self << "%s.m$call(%s)" % [@@red_block_arg, arguments]
      end
    end
  end
end
