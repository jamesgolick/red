module Red
  def self.update_javascripts
    red_dir = 'public/javascripts/red/'
    (Dir.glob("%s/*.red" % red_dir) + Dir.glob("%s/*.rb" % red_dir)).each do |filepath|
      basename = File.basename(filepath).gsub(/\.(rb|red)/,'')
      if self.update?(basename)
        Red.init(filepath)
        js_output = File.read(filepath).translate_to_sexp_array.red!
        ruby_js   = compile_ruby_js_source
        pre  = Red.debug ? "try{" : ""
        post = Red.debug ? "}catch(e){if(e.__class__){m$raise(e);};$ee=e;var m=e.message.match(/([^\\$]+)\\.m\\$(\\w+)\\sis\\snot\\sa\\sfunction/);if(m){m$raise(c$NoMethodError,$q('undefined method \"'+m[2]+'\" for '+m[1]));};var c=e.message.match(/([\\s\\S]+)\\sis\\sundefined/);if(c){c=c[1].replace(/\\./g,'::').replace(/c\\$/g,'');m$raise(c$NameError,$q('uninitialized constant '+c));};}" : ""
        File.open("public/javascripts/%s.js" % basename, 'w') {|f| f.write(pre + ruby_js + js_output + post)}
      end
    end
  end
  
  def self.update?(basename)
    return true unless File.exists?('public/javascripts/%s.js' % basename)
    return (File.mtime('public/javascripts/red/%s.red' % basename) rescue File.mtime('public/javascripts/red/%s.rb' % basename)) > File.mtime('public/javascripts/%s.js' % basename)
  end
  
  # def self.update_javascripts
  #   @@red_updated = true
  #   Red.init
  #   red_dir = 'public/javascripts/red/'
  #   Dir.glob("#{red_dir}**/*.red").each do |filepath|
  #     if self.update?(filename = filepath.gsub(red_dir,'').gsub(/.[rb|red]+$/,'')) || true
  #       js_output = (File.read(filepath).translate_to_sexp_array.red! || '')
  #       
  #       filename.split('/')[0...-1].inject('public/javascripts') do |string,dir|
  #         new_dir = string << '/' << dir
  #         Dir.mkdir(new_dir) unless File.exists?(new_dir)
  #         string
  #       end
  #       
  #       File.open("public/javascripts/#{filename}.js", 'w') { |f| f.write(js_output) }
  #     end
  #   end
  # end
  
  module RailsBase # :nodoc:
    def self.included(base)
      base.send('alias_method', :red_old_process, :process)
      base.class_eval do
        def process(*args)
          Red.update_javascripts
          red_old_process(*args)
        end
      end
    end
  end
end

include Red

unless defined?(Red::RAILS_LOADED) || !defined?(ActionController)
  Red::RAILS_LOADED = true
  ActionController::Base.send(:include, Red::RailsBase)
end
