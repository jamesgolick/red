require 'rubygems'
require 'newgem'
require 'hoe'
%w[rubygems rake rake/clean fileutils newgem rubigen].each { |f| require f }
require File.dirname(__FILE__) + '/lib/red'

# Generate all the Rake tasks
# Run 'rake -T' to see list of generated tasks (from gem root directory)
$hoe = Hoe.new('red', Red::VERSION) do |p|
  p.developer('Jesse Sielaff', 'jesse.sielaff@gmail.com')
  p.description          = 'Red writes like Ruby and runs like JavaScript.'
  p.changes              = '' #p.paragraphs_of("History.txt", 0..1).join("\n\n")
  p.post_install_message = 'For more information on Red, see http://github.com/backtik/red/wikis'
  p.name                 = 'red'
  p.rubyforge_name       = 'red-js'
  p.extra_deps           = [
    ['ParseTree', '>= 2.2.0'],
    ['rake', '>= 0.8.3']
  ]
  p.extra_dev_deps       = [
    ['newgem', ">= #{::Newgem::VERSION}"]
  ]
  
  p.clean_globs |= %w[**/.DS_Store tmp *.log]
  path = (p.rubyforge_name == p.name) ? p.rubyforge_name : "\#{p.rubyforge_name}/\#{p.name}"
  p.remote_rdoc_dir = File.join(path.gsub(/^#{p.rubyforge_name}\/?/,''), 'rdoc')
  p.rsync_args = '-av --delete --ignore-errors'
end

require 'newgem/tasks' # load /tasks/*.rake
Dir['tasks/**/*.rake'].each { |t| load t }

# TODO - want other tests/tasks run by default? Add them to the list
# task :default => [:spec, :features]

desc 'Install the gem locally without documentation'
task :local => [:install_gem_no_doc]
