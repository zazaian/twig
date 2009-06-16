
# Login Info 
class Timeline

  puts "### PUBLIC MESSAGES ###"
  public_timeline = client.timeline_for(:public) do |status|
    # do something here with each individual status in timeline that is also returned
    
    puts status.text
  end
end

