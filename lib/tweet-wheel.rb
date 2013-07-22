# Tweet Wheel : A tool for hamster tweeting
#
# Copyright (c) 2013 Justin Leavitt jusleavitt@gmail.com
#
# This program is free software

require "tweet-wheel/version"
require "tweet-wheel/tweet"
require 'dino' # https://github.com/austinbv/dino
  
# 
# Initialization of the Arduino Board and general settings
#

HIGH            = '1023'    # Reed HIGH value
LOW             = '000'     # Reed LOW value
MAX_REED_COUNT  = 150       # Max counts before timeout
CIRCUMFERENCE   = 34.54     # Circumference of the wheel in inches

# Remember, the little critter likes to take breaks. Adjust this
# amount in order to get a full wheel session (in seconds).
MAX_WAIT_TIME   = 10800 

# Initializing basic operating settings.
@reed_counter   = MAX_REED_COUNT
@reed_timer     = 0
@distance       = 0
@array_of_mph   = []
@tweet_sent     = true
@start_time     = Time.now

# Important Arduino variables. The sensor is mapped to port A0.
board           = Dino::Board.new(Dino::TxRx.new)
sensor          = Dino::Components::Sensor.new(pin: 'A0', board: board)


# Let's print an awesome welcome message
puts "+---------------------------------------+"
puts "|      Chauncey's Wheel is running      |"
puts "+---------------------------------------+"

# 
# The Arduino loop and main logic
#

on_data = Proc.new do |data|
# The on_data Proc monitors the reed state and
# reacts according to the signal state. When the two
# connectors make contact, the reed is in a HIGH state.
# When the connectors are apart, the reed is in a LOW state.
#
# When @reed_counter hits 0 and the MAX_WAIT_TIME is reached,
# the end_wheel_session method executes the tweet.
  
  if data == HIGH
    if @reed_counter == 0
      @elapsed_time = Time.now - @reed_timer
  
      # mph = ((CIRCUMFERENCE * 3600000) / 5280) / (@elapsed_time * 1000)
      mph = ((CIRCUMFERENCE / 12) / 5280) / (@elapsed_time / 3600)
      @array_of_mph << mph.round unless mph.round > 50
  
      @reed_counter = MAX_REED_COUNT
      @distance += CIRCUMFERENCE
  
      @start_time = Time.now if @tweet_sent
      @tweet_sent = false

      puts "#{mph.round} MPH, rotation: #{@elapsed_time}s, distance: #{@distance}"
    else
      if @reed_counter > 0
        @reed_counter -= 1
      end
    end
    @reed_timer = Time.now
  end
  
  if data == LOW
    if @reed_counter > 0
      @reed_counter -= 1
    end
  end

  if (Time.now - @start_time) > MAX_WAIT_TIME && !@tweet_sent
    end_wheel_session 
  end

  # Uncomment to see data activity from sensor
  # puts "#{data}"
end

def end_wheel_session
  # When the MAX_WAIT_TIME has been reached, then the current session
  # is over. This method parses the stats for the session,
  # then passes the stats to Tweet::send_tweet.

  
  # Becasue the first MPH is only used to begin calculations,
  # it's always inaccurate and shouldn't be used.
  @array_of_mph.shift
  
  # Calculate the average MPH
  avg_mph = @array_of_mph.inject{|sum,x| sum + x }
  avg_mph = (avg_mph / @array_of_mph.count).round

  # Calculate the final distance in miles
  final_distance = (@distance / 63360).round

  # Of course, record the total duration
  duration = ((Time.now - @start_time) / 60).round

  puts "AVG MPH: #{avg_mph}, DISTANCE: #{final_distance}, DURATION: #{duration}"
  
  # Flag that tweet was sent to stop subsequent tweet sends.
  @tweet_sent = true

  begin 
    tweet.send_tweet({ current_time: Time.now, 
                       duration: duration, 
                       speed: avg_mph, 
                       distance: final_distance 
                      })

    puts "Tweet sent!"
  
  rescue Exception => msg
    puts "Tweet failed | #{msg}"
  end
  
  # Reset data, ready for another session.
  @distance = 0
  @array_of_mph = []
end


def tweet
  @tweet ||= TweetWheel::Tweet.new
end

sensor.when_data_received(on_data)

sleep 


