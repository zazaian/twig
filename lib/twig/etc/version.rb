
module Twig::Version #:nodoc:
  MAJOR = 0
  MINOR = 0
  TINY = 14
  REVISION = 14
  
  # Returns X.Y.Z formatted version string
  def self.to_version
    "#{MAJOR}.#{MINOR}.#{TINY}"
  end
  
  # Returns X-Y-Z formatted version name
  def self.to_name
    "#{MAJOR}_#{MINOR}_#{TINY}"
  end
end
