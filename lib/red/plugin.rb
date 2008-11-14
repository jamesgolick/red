require 'pathname'

class Pathname; alias / + end

include Red

module Red
  class SourceFile < Pathname
    def preamble
      return "" unless Red.debug
      "try{\n"
    end
    
    def postamble
      return "" unless Red.debug
      "\n}\
      catch(e){\
      if(e.__class__){\
        m$raise(e);\
      };
      $ee=e;\
      var m=e.message.match(/([^\\$]+)\\.m\\$(\\w+)\\sis\\snot\\sa\\sfunction/);\
      if(m){\
        m$raise(c$NoMethodError,$q('undefined method \"'+m[2]+'\" for '+m[1]));\
      };\
      var c=e.message.match(/([\\s\\S]+)\\sis\\sundefined/);\
      if(c){\
        c=c[1].replace(/\\./g,'::').replace(/c\\$/g,'');\
        m$raise(c$NameError,$q('uninitialized constant '+c));\
        };\
      }"
    end
  
    def should_regenerate?
      return true unless self.target_file.exist?
      self.mtime > target_file.mtime
    end
    
    def generate!
      return unless self.should_regenerate?
      Red.init self.to_s
      ruby = self.read
      generated = ruby.translate_to_sexp_array.red!
      ruby_js = compile_ruby_js_source
      
      File.open(self.target_file.to_s, 'w+') do |f|
        f << preamble
        f << ruby_js
        f << generated
        f << postamble
      end
    end
    
    def basename
      super.to_s.gsub extname, ''
    end
    
    def target_directory
      self.dirname / ".."
    end
    
    def target_file
      self.target_directory / "#{basename}.js"
    end
  end
  
  if defined?(RAILS_ENV) 
    module RailsPlugin
      def self.framework_root
        Pathname.new RAILS_ROOT
      end
      
      def self.framework_env
        RAILS_ENV
      end
      
      def self.included mod
        mod.send :alias_method, :red_old_process, :process
        base.class_eval do
          def process *args
            Red::RailsPlugin.update_javascripts
            self.red_old_process
          end
        end
      end
      
      def self.update_javascripts
        self.red_files.each{|file| file.generate! }
      end
      
      def self.red_files
        files = self.options[:load_paths].map do |load_path|
          SourceFile.glob "#{framework_root}#{load_path}/*.{rb,red}"
        end 
        files.flatten
      end

      class << self
        attr_accessor :options
      end

      self.options = {
        :load_paths => ['/public/javascripts/red'],
        :always_check => !(self.framework_env == 'production')
      }
      
      module Mixin
        def self.included(base)
          base.send('alias_method', :red_old_process, :process)
          base.class_eval do
            def process(*args)
              puts "FUCKING UPDATE"
              puts RailsPlugin.red_files.inspect
              RailsPlugin.update_javascripts  
              red_old_process(*args)
            end
          end
        end
      end
    end

    if RailsPlugin.options[:always_check]
      if defined?(ActionController) 
        unless ActionController.ancestors.include?(Red::RailsPlugin::Mixin)
          ActionController::Base.send(:include, Red::RailsPlugin::Mixin)
        end
      end
    else
      RailsPlugin.update_javascripts
    end
  end
  
  if defined?(Merb) 
    module MerbPlugin
      class RackMiddleware < Merb::Rack::Middleware
        def call env
          MerbPlugin.update_javascripts if MerbPlugin.options[:always_check]
          @app.call env
        end
      end

      def self.update_javascripts
        self.red_files.each{|file| file.generate! }
      end
      
      def self.red_files
        files = self.options[:load_paths].map do |load_path|
          SourceFile.glob "#{framework_root / load_path}/*.{rb,red}"
        end 
        files.flatten
      end
      
      def self.init!; end
      
      def self.point_five?
        version = Merb::VERSION.split('.').map { |n| n.to_i }
        version[0] <= 0 && version[1] < 5
      end
      
      def self.framework_env
        self.point_five? ? MERB_ENV : Merb.env
      end
      
      def self.framework_root
        self.point_five? ? MERB_ROOT : Merb.root
      end
      
      class << self
        attr_accessor :options
      end

      self.options = {
        :load_paths => ['/public/javascripts/red'],
        :always_check => !(framework_env == 'production')
      }
      
      options[:always_check] ? self.init! : self.update_javascripts
    end
  end 
end

