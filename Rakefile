
require 'rubygems'
require 'hoe'
$:.unshift(File.dirname(__FILE__) + "/lib")
require 'twig'

Hoe.new('twig', Twig::VERSION.print) do |p|
  p.developer 'Mike Zazaian', 'zazaian@gmail.com'
  p.url = "http://twig-twitter.rubyforge.org"

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

