# Tweet Wheel : A tool for hamster tweeting
#
# Copyright (c) 2013 Justin Leavitt jusleavitt@gmail.com
#
# This program is free software


require 'twitter' # https://github.com/sferik/twitter
require 'yaml'

module TweetWheel

  # The TweetWheel::Tweet class holds all the methods used to generate a
  # tweet based on the wheel's activity.
  
  class Tweet
    
    def initialize
      @client = Twitter::Client.new(
        :consumer_key => "sUySqvvF4xQF7F0vx1g2uA",
        :consumer_secret => "lf6wJGz9da1BXPuLCxT3st5TqcN25jSNaG7cglq9Q",
        :oauth_token => "1067037691-qc4cf7zJwsEGQ0qaRhmyvioE50Hf9Kp6MBmIDxz",
        :oauth_token_secret => "ldHzdF7tFA0eSiAVfVWAgQ2fswjMU2j76LHkgMYFPuU"
        )
      @tweets = YAML.load_file("tweets.yml")
    end

    def send_tweet params
      current_time  = params[:current_time]
      duration      = params[:duration]
      speed         = params[:speed]
      distance      = params[:distance]

      random_tweet = []

      # Time of day
      random_tweet << check_time(current_time)

      # Duration
      random_tweet << check_duration(duration)

      # Distance
      random_tweet << check_distance(distance)

      # Speed
      random_tweet << check_speed(speed)

      tweet = random_tweet.sample
      formatted_tweet = subber({ tweet: tweet,
                                 duration: duration,
                                 speed: speed,
                                 distance: distance
                                })
      
      @client.update(formatted_tweet)
      puts formatted_tweet
    end

    private

    def check_time current_time
      if night?(current_time)
        @tweets[:time][:late].sample
      elsif afternoon?(current_time)
        @tweets[:time][:afternoon].sample
      elsif morning?(current_time)
        @tweets[:time][:morning].sample
      end
    end 

    def check_duration duration
      case duration
        when 5...9
          @tweets[:duration][:medium].sample
        when 10..14
          @tweets[:duration][:medium_long].sample
        when 15..60
          @tweets[:duration][:long].sample
        else 
          @tweets[:duration][:short].sample
      end
    end

    def check_speed speed
      case speed
        when 2..2.5
          @tweets[:speed][:medium].sample
        when 2.6..10 
          @tweets[:speed][:fast].sample
        else
          @tweets[:speed][:slow].sample
      end
    end

    def check_distance distance
      case distance
        when 1..2 
          @tweets[:distance][:medium].sample
        when 3..5
          @tweets[:distance][:long].sample
        else
          @tweets[:distance][:short].sample
      end
    end

    def subber params
      tweet     = params[:tweet]
      duration  = params[:duration]
      speed     = params[:speed]
      distance  = params[:distance]

      params.each do |key, value|
        if tweet.include?(key.to_s.upcase)
          tweet = tweet.gsub(key.to_s.upcase, value.to_s)
        end      
      end
      tweet
    end

    def night? date
      !("18:00"..."23:59").include?(date.strftime("%H:%M"))
    end

    def afternoon? date
      !("12:00"..."17:59").include?(date.strftime("%H:%M"))
    end

    def morning? date
      !("24:00"..."11:59").include?(date.strftime("%H:%M"))
    end
  end
end