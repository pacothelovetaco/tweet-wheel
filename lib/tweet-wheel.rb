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

# Initialize sensor and board
board = Dino::Board.new(Dino::TxRx.new)
sensor = Dino::Components::Sensor.new(pin: 'A0', board: board)

MAX_REED_COUNT = 150
CIRCUMFERENCE = 34.54 # in inches
MAX_WAIT_TIME = 10 # in seconds


@reed_counter = MAX_REED_COUNT
@old_time = 0
@distance = 0
@all_mph = []
@tweet_sent = true
@timer = Time.now

def tweet
  @tweet ||= TweetWheel::Tweet.new
end

puts "Loading Chauncey's Wheel"

# 
# Arduino Main Logic
#

on_data = Proc.new do |data|
  # Main logic that listens for reed connection and acts accordingly.

  if data == '1023'

    if @reed_counter == 0
      @in_time = Time.now - @old_time
      mph = ((CIRCUMFERENCE * 3600000) / 5280) / (@in_time * 1000)
      #rounded_mph = (mph * 100).round / 100.0

      @all_mph << mph

      puts "#{mph} MPH, rotation: #{@in_time}s"
      
      @reed_counter = MAX_REED_COUNT
      @distance += CIRCUMFERENCE
      
      @timer = Time.now #reset times 
      @tweet_sent = false
    else
      if @reed_counter > 0
        @reed_counter -= 1
      end
    end
    @old_time = Time.now
  end
  
  if data == '000'
    if @reed_counter > 0
      @reed_counter -= 1
    end
  end

  if (Time.now - @timer) > MAX_WAIT_TIME && !@tweet_sent
    
    # Calculate
    @all_mph.shift # Becasue the first one is always bloated
    avg_mph = @all_mph.inject{|sum,x| sum + x }
    avg_mph = avg_mph / @all_mph.count
    rounded_mph = (avg_mph * 100).round / 100.0

    final_distance = @distance / 63360
    final_distance = (final_distance * 100).round / 100.0

    duration = (Time.now - @timer) / 60
    rounded_duration = (duration * 100).round / 100.0

    puts "#{rounded_mph}, #{final_distance}, #{duration}"
    puts "fire off tweet"
    @tweet_sent = true

    tweet.generate_tweet({current_time: Time.now, 
                    duration: rounded_duration, 
                    speed: rounded_mph, 
                    distance: final_distance 
                    })
    @distance = 0
    @all_mph = []
  end

  #puts "#{data}"
end

sensor.when_data_received(on_data)

sleep 


