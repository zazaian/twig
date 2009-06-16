
class Time
  Time::Order = [:year, :month, :week, :day, :hour, :minute, :second]
  Time::Units = {
    :year => {
      :basic => 60 * 60 * 24 * 365,
      :gregorian => 86400 * 365.2425,
      },
    :month => {
      :basic => 60 * 60 * 24 * 30,
      :gregorian => 86400 * 30.436875,
      },
    :week => {
      :basic => 60 * 60 * 24 * 7,
      :gregorian => 86400 * 7.02389423076923,
      },
    :day => {
      :basic => 60 * 60 * 24
      },
    :hour => {
      :basic => 60 * 60
      },
    :minute => {
      :basic => 60
      },
    :second => {
      :basic => 1
      }
    } 
   
  def Time.cal_check(calendar)
    error = ":calendar => value must be either :basic or :gregorian." 
    unless calendar == :basic || calendar == :gregorian
      raise ArgumentError, error
    end
  end

end

module TimeAgo
  VERSION = "0.1.0"
   
  # Generate List of valid unit :symbols
  valids = ""
  Time::Order.each do |u|
    unless u == :second
      valids += ":#{u.to_s}, "
    else
      valids += "and :#{u.to_s}."
    end
  end
  TimeAgo::Valids = valids
 
  def ago(opts={})
    # Process options {hash}
    focus = opts[:focus] ? opts[:focus] : 0 
    start_at = opts[:start_at] ? opts[:start_at] : :year
    now = opts[:now] ? opts[:now].to_i : Time.now
    in_time = opts[:in_time] ? opts[:in_time] : :past
    cal = opts[:cal] ? opts[:cal] : :basic

    # Filter out invalid arguments for :in_time
    in_time_error = ":in_time => value must be either :past or :future, " \
                   + "depending on whether the Time object is before or after Time.now."
    unless in_time == :past || in_time == :future
      raise ArgumentError, in_time_error
    end
   
    # Filter out invalid arguments for :calendar
    Time.cal_check(cal)

    # Filter out invalid arguments for :start_at and :focus
    base_error = " => value must either be a number " +
      "between 0 and 6 (inclusive),\nor one of the following " +
      "symbols: " + TimeAgo::Valids
    {:focus => focus, :start_at => start_at}.each do |key, opt|
      opt_error = ":" + key.to_s + base_error
      if opt.class == Fixnum
        raise ArgumentError, opt_error unless opt >= 0 && opt <= 6
      elsif opt.class == Symbol
        raise ArgumentError, opt_error unless Time::Units[opt]
      else
        raise ArgumentError, opt_error
      end
    end
 
    # Create Variables necessary for processing.
    frags = []
    output = ""
    count = 0
    
    now = cal == :basic ? now.to_i : now.to_f
    my_time = cal == :basic ? self.to_i : self.to_f
    if now > my_time
      diff = now - my_time
      tail = " ago"
    elsif my_time > now
      diff = my_time - now
      tail = " from now"
    else
      diff = 0
      tail = "Right now, this very moment."
    end

    # Begin Time.ago processing
    Time::Order.each do |u|
      if cal == :gregorian && Time::Units[u][:gregorian]
        value = Time::Units[u][:gregorian]
      else
        value = Time::Units[u][:basic]
      end
      count += 1

      # Move further ahead in the Ago::Units array if start_at is farther back than
      # the current point in the array.
      if start_at.class == Fixnum
        next if count <= start_at
      elsif start_at.class == Symbol 
        next if Time::Order.index(u) < Time::Order.index(start_at)
      end

      n = (diff/value).floor
      if n > 0
        plural = n > 1 ? "s" : ""
        frags << "#{n} #{u.to_s + plural}"

        # If the argument passed into ago() is a symbol, focus the ago statement
        # down to the level specified in the symbol
        if focus.class == Symbol
          break if u == focus || u == :second
        elsif focus.class == Fixnum
          if focus == 0 || u == :second
            break
          else
            focus -= 1
          end
        end
        diff -= n * value
      end
    end

    # Der Kommissar
    frags.size.times do |n|
      output += frags[n]
      output += ", " unless n == frags.size - 1
    end

    return output + "#{tail}"
  end

  def from_now(opts={})
    ago(opts)
  end
end

class Time
  include TimeAgo
end


module NumAgo
 
  def ago
    return Time.now - self
  end
  
  def from_now
    return Time.now + self
  end
  
  def years(opts={})
    cal = opts[:cal] ? opts[:cal] : :basic
    Time.cal_check(cal)

    self * Time::Units[:year][cal]
  end

  def year(opts={})
    years(opts)
  end
  
  def months(opts={})
    cal = opts[:cal] ? opts[:cal] : :basic
    Time.cal_check(cal)
   
    self * Time::Units[:month][cal]
  end

  def month(opts={})
    months(opts)
  end

  def weeks(opts={})
    cal = opts[:cal] ? opts[:cal] : :basic
    Time.cal_check(cal)
    
    self * Time::Units[:week][cal]
  end

  def week(opts={})
    weeks(opts)
  end

  def days
    self * Time::Units[:day][:basic]
  end

  def day
    days
  end
  
  def hours
    self * Time::Units[:hour][:basic]
  end

  def hour
    hours
  end
  
  def minutes
    self * Time::Units[:minute][:basic]
  end

  def minute
    minutes
  end

  def seconds
    self * Time::Units[:second][:basic]
  end

  def second
    seconds
  end
end

class Fixnum
  include NumAgo
end

class Bignum
  include NumAgo
end

class Float
  include NumAgo
end
