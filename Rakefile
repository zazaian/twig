
require 'rubygems'
require 'hoe'
$:.unshift(File.dirname(__FILE__) + "/lib")
require 'twig'

#RDOCOPT="-S -f html -T hanna"
RDOCOPT="-f hanna"

Hoe.spec('twig') do |p|
  p.version = Twig::VERSION.print
  p.developer 'Mike Zazaian', 'zazaian@gmail.com'
  p.url = "http://twig-twitter.rubyforge.org"

  p.extra_deps = ['twitter4r', '>=0.2.4']

  d = "An intelligent wrapper for the Twitter4r gem."
  p.description = d
  p.summary = d
end

desc "Simple test on packaged files to make sure they are all there"
task :verify => :package do
  # An error message will be displayed if files are missing
  if system %(ruby -e "require 'pkg/twig-#{Twig::VERSION.print}/lib/twig'")
    puts "\nThe library files are present"
  end
end

