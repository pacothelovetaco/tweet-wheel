# Hamster Tweet Wheel
I have a hamster. He's a cute little critter. He's clean, quiet, and low maintence. However, he is very active. The little guy spends hours in his wheel going around and around and .... As I watched him going around in that wheel, my wheels started spinning too. I wanted to harness that activity somehow. So I decided to rig his wheel with a sensor to track is activity. But that's a little boring on it's own. So since he is a hamster living in the 21st century, I also decided that he should be able to tweet his little adventures as well.

The Hamster Tweet Wheel monitors the hamster's activity in his wheel. It tracks distance, speed, and time of day. It then sends a random Tweet based on the data collected during his run in the wheel. See it in action [here!](https://twitter.com/ChaunceyHamster)


##Hardware
- [Arduino board](http://arduino.cc)
- Breadboard
- 10K ohm resitor
- [Magnetic door switch](http://www.trossenrobotics.com/p/magnetic-door-switch.aspx)
- A few wires.

##Circuit
The setup is simialr to the the button tutorial found on Arduino's site. The connections are the same, except replace the button with the magnetic door switch.
The instructions can be found here: [http://arduino.cc/en/Tutorial/Button](http://arduino.cc/en/Tutorial/Button)

Lastly, fasten the connected end of the magnetic door switch to cage, and the other magnet to the hamster's wheel. Make sure they are close enough to make a connection.

##Requirements
1. You'll need to bootstrap the Arduino board using the Dino Ruby gem: [https://github.com/austinbv/dino](https://github.com/austinbv/dino)
2. You'll also need to install the Tweet Ruby gem: [https://github.com/sferik/twitter](https://github.com/sferik/twitter)

##Setup

1. Edit `lib/tweet.rb` and add your tweet credentials:
		
		@client = Twitter::Client.new(
			:consumer_key => "",
			:consumer_secret => "",
			:oauth_token => "",
			:oauth_token_secret => ""
			)

2. Edit `tweet-wheel.rb`:
	
		- Replace the constant `CIRCUMFERENCE` with the actual circumference of your hamster wheel in inches.
		- Replace `MAX_WAIT_TIME` with the wait time you prefer. To send more tweets set the time lower, or set it higher to send more tweets. 


3. Add or remove tweets in `tweets.yml`.
	The program has the ability to make the tweets dynamic. For instance, if you wanted to write a tweet for speed add the word `SPEED` (in all caps) as a placeholder. The program will replace it with the actual statistic. So `"I just had a SPEED MPH run."` will become `"I just had a 2 MPH run."` if the critter ran 2 MPH speed.


##Run
Open Terminal and issue: `$ ruby bin/tweet-wheel`


