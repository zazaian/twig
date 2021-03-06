
module Twig::VERSION #:nodoc:
  MAJOR = 0
  MINOR = 5
  TINY = 12
  
  class << self
    # Returns X.Y.Z formatted version string
    def to_version
      "#{MAJOR}.#{MINOR}.#{TINY}"
    end
    alias_method :print, :to_version
    alias_method :pretty, :to_version
    
    # Returns X-Y-Z formatted version name
    def to_name
      "#{MAJOR}_#{MINOR}_#{TINY}"
    end
  end
end
