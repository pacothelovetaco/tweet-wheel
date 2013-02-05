require "tweet-wheel/version"
require "tweet-wheel/tweet"
require 'dino' # https://github.com/austinbv/dino

=begin
 
 Tweet Wheel

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 3 of the License, or
 (at your option) any later version.

=end
  
HIGH            = '1023'    # Reed HIGH variable
LOW             = '000'     # Reed LOW variable
MAX_REED_COUNT  = 150       # Max counts before timeout
CIRCUMFERENCE   = 34.54     # in inches
MAX_WAIT_TIME   = 10        # in seconds

@reed_counter   = MAX_REED_COUNT
@old_time       = 0
@distance       = 0
@array_of_mph   = []
@tweet_sent     = true
@timer          = Time.now

board           = Dino::Board.new(Dino::TxRx.new)
sensor          = Dino::Components::Sensor.new(pin: 'A0', board: board)

def tweet
  @tweet ||= TweetWheel::Tweet.new
end

puts "+---------------------------------------+"
puts "|       Loading Chauncey's Wheel        |"
puts "+---------------------------------------+"


# 
# Arduino Main Logic
#

# def execute_high
#   @elapsed_time = Time.now - @old_time
  
#   mph = ((CIRCUMFERENCE * 3600000) / 5280) / (@elapsed_time * 1000)
#   @array_of_mph << mph.round
  
#   @reed_counter = MAX_REED_COUNT
#   @distance += CIRCUMFERENCE
  
#   @timer = Time.now 
#   @tweet_sent = false

#   puts "#{mph.round} MPH, rotation: #{@elapsed_time}s"
# end

def end_session
  @array_of_mph.shift       # Becasue the first one is always bloated
  
  avg_mph = @array_of_mph.inject{|sum,x| sum + x }
  avg_mph = (avg_mph / @array_of_mph.count).round

  final_distance = (@distance / 63360).round

  duration = ((Time.now - @timer) / 60)).round

  puts "#{avg_mph}, #{final_distance}, #{duration}"
  puts "fire off tweet"
  @tweet_sent = true

  tweet.generate_tweet({current_time: Time.now, 
                  duration: duration, 
                  speed: avg_mph, 
                  distance: final_distance 
                  })
  
  # Reset data
  @distance = 0
  @array_of_mph = []
end


on_data = Proc.new do |data|
  if data == HIGH
    if @reed_counter == 0
      @elapsed_time = Time.now - @old_time
  
      mph = ((CIRCUMFERENCE * 3600000) / 5280) / (@elapsed_time * 1000)
      @array_of_mph << mph.round
  
      @reed_counter = MAX_REED_COUNT
      @distance += CIRCUMFERENCE
  
      @timer = Time.now 
      @tweet_sent = false

      puts "#{mph.round} MPH, rotation: #{@elapsed_time}s"
    else
      if @reed_counter > 0
        @reed_counter -= 1
      end
    end
    @old_time = Time.now
  end
  
  if data == LOW
    if @reed_counter > 0
      @reed_counter -= 1
    end
  end

  if (Time.now - @timer) > MAX_WAIT_TIME && !@tweet_sent
    end_session 
  end

  # Uncomment to see data activity from sensor
  # puts "#{data}"
end

sensor.when_data_received(on_data)

sleep 


