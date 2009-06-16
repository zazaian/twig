
module Twirp::Version #:nodoc:
  MAJOR = 0
  MINOR = 0
  TINY = 8
  REVISION = 8
  
  # Returns X.Y.Z formatted version string
  def self.to_version
    "#{MAJOR}.#{MINOR}.#{TINY}"
  end
  
  # Returns X-Y-Z formatted version name
  def self.to_name
    "#{MAJOR}_#{MINOR}_#{TINY}"
  end
end
