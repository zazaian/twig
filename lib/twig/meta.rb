
module Twig::WriteMethod
  def Twig::WriteMethod.cached(name, update_method)
    raise ArgumentError, "#{name} must be entered as a symbol." unless name.class == Symbol
    
    ivar = "@#{name.to_s}".to_sym

    define_method name
    end
  end
end
