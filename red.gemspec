# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{red}
  s.version = "4.1.7"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Jesse Sielaff"]
  s.date = %q{2008-11-14}
  s.default_executable = %q{red}
  s.description = %q{Red writes like Ruby and runs like JavaScript.}
  s.email = ["jesse.sielaff@gmail.com"]
  s.executables = ["red"]
  s.extra_rdoc_files = ["License.txt", "Manifest.txt", "README.txt"]
  s.files = ["bin/red", "config/website.yml", "lib/red.rb", "lib/red/errors.rb", "lib/red/executable.rb", "lib/red/plugin.rb", "lib/red/nodes/assignment_nodes.rb", "lib/red/nodes/call_nodes.rb", "lib/red/nodes/control_nodes.rb", "lib/red/nodes/data_nodes.rb", "lib/red/nodes/definition_nodes.rb", "lib/red/nodes/illegal_nodes.rb", "lib/red/nodes/literal_nodes.rb", "lib/red/nodes/logic_nodes.rb", "lib/red/nodes/variable_nodes.rb", "lib/source/redshift.rb", "lib/source/redspec.rb", "lib/source/ruby.rb", "lib/source/redshift/accessors.rb", "lib/source/redshift/browser.rb", "lib/source/redshift/chainable.rb", "lib/source/redshift/code_events.rb", "lib/source/redshift/cookie.rb", "lib/source/redshift/document.rb", "lib/source/redshift/element.rb", "lib/source/redshift/event.rb", "lib/source/redshift/redshift.red", "lib/source/redshift/request.rb", "lib/source/redshift/selectors.rb", "lib/source/redshift/situated.rb", "lib/source/redshift/store.rb", "lib/source/redshift/transform.rb", "lib/source/redshift/tween.rb", "lib/source/redshift/user_events.rb", "lib/source/redshift/validator.rb", "lib/source/redshift/window.rb", "lib/source/redspec/index.html", "lib/source/redspec/lib/red_spec/red_spec.red", "lib/source/redspec/lib/stylesheets/specs.sass", "License.txt", "Manifest.txt", "Rakefile", "README.txt", "spec/array.red", "spec/hash.red", "spec/object.red", "spec/string.red"]
  s.has_rdoc = true
  s.homepage = %q{Red takes the Ruby you write and turns it into JavaScript for your browser.}
  s.post_install_message = %q{For more information on Red, see http://github.com/backtik/red/wikis}
  s.rdoc_options = ["--main", "README.txt"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{red-js}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<ParseTree>, [">= 2.2.0"])
      s.add_runtime_dependency(%q<rake>, [">= 0.8.3"])
      s.add_development_dependency(%q<newgem>, [">= 1.1.0"])
      s.add_development_dependency(%q<hoe>, [">= 1.8.2"])
    else
      s.add_dependency(%q<ParseTree>, [">= 2.2.0"])
      s.add_dependency(%q<rake>, [">= 0.8.3"])
      s.add_dependency(%q<newgem>, [">= 1.1.0"])
      s.add_dependency(%q<hoe>, [">= 1.8.2"])
    end
  else
    s.add_dependency(%q<ParseTree>, [">= 2.2.0"])
    s.add_dependency(%q<rake>, [">= 0.8.3"])
    s.add_dependency(%q<newgem>, [">= 1.1.0"])
    s.add_dependency(%q<hoe>, [">= 1.8.2"])
  end
end
