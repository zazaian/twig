
module Twig::User
 
  def user(opts={})
    login = opts[:login] ? opts[:login] :false
    password = opts[:password] ? opts[:password] :false
    
    if login && password
      unless @login == login && @password == password
        c = Twitter::Client.new(:login => login, :password => password)
        i = c.my(:info)
        if i
          self.clear
          @client = c
          @info = i
          @login = login
          @password = password
        else
          raise ArgumentError, "Could not switch to user '#{login}'.  Either login or password are incorrect."
        end
      else
        raise "Already using user '#{login}'."
      end
    else
      raise ArgumentError, "Login and password were not provided for the new user." \
                          + "  Could not switch."
    end
  end
  
  def clear
    if @info || @friends || @followers || @favorites || @status || @message_box
      @info = nil
      @friends = nil
      @followers = nil
      @favorites = nil
      @status = nil
      @message_box = nil
    end
  end 
  
  def info(action=nil)
    if @info
      case action
      when :update
        @info = @client.my(:info)
      when nil
        @info
      else
        raise ArgumentError, "#{action} is not a valid argument for @info."
      end
    else
      @info = @client.my(:info)
    end
  end

  def favorites(action=nil)
    if @favorites
      case action
      when :update
        @favorites = @client.favorites
      when nil
        @favorites
      else
        raise ArgumentError, "#{action} is not a valid argument for @favorites."
      end
    else
      @favorites = @client.favorites
    end
  end

  def friends(action=nil)
    if @friends
      case action
      when :update
        @friends = @client.my(:friends)
      when nil
        @friends
      else
        raise ArgumentError, "#{action} is not a valid argument for @friends."
      end
    else
      @friends = @client.my(:friends)
    end
  end

  def followers(action=nil)
    if @followers
      case action
      when :update
        @followers = @client.my(:followers)
      when nil
        @followers
      else
        raise ArgumentError, "#{action} is not a valid argument for @followers."
      end
    else
      @followers = @client.my(:followers)
    end
  end
end
