
module Twig::User
  attr_reader :info, :favorites, :followers
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
