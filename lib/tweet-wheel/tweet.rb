require 'twitter' # https://github.com/sferik/twitter
require 'yaml'

module TweetWheel
  class Tweet
    def initialize
      @client = Twitter::Client.new(
        :consumer_key => "sUySqvvF4xQF7F0vadx1g2uA",
        :consumer_secret => "lf6wJGz9da1BXPuLCxT3st5TqcN25jSNaG7cglq9Q",
        :oauth_token => "1067037691-qc4cf7zJwsEGQ0qaRhmyvioE50Hf9Kp6MBmIDxz",
        :oauth_token_secret => "ldHzdF7tFA0eSiAVfVWAgQ2fswjMU2j76LHkgMYFPuU"
        )
      @tweets = YAML.load_file("tweets.yml")
    end

    def generate_tweet params
      current_time  = params[:current_time]
      duration      = params[:duration]
      speed         = params[:speed]
      distance      = params[:distance]

      random_tweet = []

      #  === Time of day ===
      if night?(current_time)
        random_tweet << @tweets[:time][:late].sample
      
      elsif afternoon?(current_time)
        random_tweet << @tweets[:time][:afternoon].sample
      
      elsif morning?(current_time)
        random_tweet << @tweets[:time][:morning].sample
      end

      # === Duration ===
      if duration >= 15
       random_tweet << @tweets[:duration][:long].sample
      
      elsif duration < 15 && duration >= 10
       random_tweet << @tweets[:duration][:medium_long].sample
      
      elsif duration < 10 && duration >= 5
        random_tweet << @tweets[:duration][:medium].sample
      
      else
       random_tweet << @tweets[:duration][:short].sample
      end

      # === Speed ===
      if speed >= 15 
        random_tweet << @tweets[:speed][:fast].sample
      elsif speed < 15 && speed >= 5
        random_tweet << @tweets[:speed][:medium].sample
      else
        random_tweet << @tweets[:speed][:slow].sample
      end

      # === Distance ===
      if distance >= 500
        random_tweet << @tweets[:distance][:long].sample
      elsif distance < 500 && distance >= 300 
        random_tweet << @tweets[:distance][:medium].sample
      else
        random_tweet << @tweets[:distance][:short].sample
      end 

      tweet = random_tweet.sample
      subbed_tweet = subber({ tweet: tweet,
                              duration: duration,
                              speed: speed,
                              distance: distance
                            })
      #@client.update(subbed_tweet)
      puts subbed_tweet
    end

    private 

    def subber params
      tweet         = params[:tweet]
      duration      = params[:duration]
      speed         = params[:speed]
      distance      = params[:distance]

      params.each do |key, value|
        if tweet.include?(key.to_s.upcase)
          tweet = tweet.gsub(key.to_s.upcase, value.to_s)
        end      
      end
      tweet
    end

    def night? date
      !("06:00"..."23:59").include?(date.strftime("%H:%M"))
    end

    def afternoon? date
      !("12:00"..."5:59").include?(date.strftime("%H:%M"))
    end

    def morning? date
      !("24:00"..."11:59").include?(date.strftime("%H:%M"))
    end
  end
end