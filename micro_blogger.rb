require 'jumpstart_auth'
require 'bitly'

class MicroBlogger
	attr_reader :client
	def initialize
		puts "Initializing MicroBlogger"
		@client = JumpstartAuth.twitter
	end

	def tweet(message)
		if message.length >= 140 
			puts "The message is too long (#{message.length}) to be tweeted. It must be less than or equal to 140 characters."
			return
		end
		@client.update(message)
	end

	def dm(target, message)
		screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
		if screen_names.include?target
			puts "Trying to send #{target} this direct message:"
			puts message
			message = "d @#{target} #{message}"
			tweet(message)
		else
			puts "#{target} is not following you, so you cannot send a direct message to that user."
			return 
		end
	end

	def followers_list
		screen_names = []
		@client.followers.each do |follower| 
			screen_names << @client.user(follower).screen_name
		end
		screen_names
	end

	def spam_my_followers(message)
		followers_list.each do |follower|
			dm(follower, message)
		end
	end

	def everyones_last_tweet
		friends = @client.friends
		friends = friends.sort_by { |friend| @client.user(friend).screen_name.downcase }
		friends.each do |friend|
			# for some reason, friend.screen_name was not working.  Maybe API has changed since tutorial written?
			# Looking at earlier solutions, it seems like it used to work.
			# I had to take a hint from one of the later solutions to get the correct call, credit to: Florian Mainguy
			
			puts "[#{@client.user(friend).status.created_at.strftime("%A, %b %d")}] #{@client.user(friend).screen_name} tweeted:"
			puts @client.user(friend).status.text
			puts	
		end
	end

	def shorten(original_url)
		puts "Shortening this URL: #{original_url}"

		Bitly.use_api_version_3
		bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
		short_url = bitly.shorten(original_url).short_url

		return short_url
	end

	def run
		puts "Welcome to the JSL Twitter Client!"
		command = ""
		while command != "q"
			printf "Enter command: "
			input = gets.chomp
			parts = input.split(" ")
			command = parts[0]

			case command
				when 'q' then puts "Goodbye!"
				when 't' then tweet (parts[1..-1].join(" "))
				when 'turl' then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
				when 'dm' then dm(parts[1], parts[2..-1].join(" "))
				when 'spam' then spam_my_followers(parts[1..-1].join(" "))
				when 'elt' then everyones_last_tweet
				when 's' then shorten(parts[1])
				else
					puts "Sorry, I don't know how to #{command}"
			end
		end
	end
end

blogger = MicroBlogger.new
blogger.run
