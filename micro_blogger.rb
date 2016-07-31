require 'jumpstart_auth'
require 'bitly'
require 'klout'

class MicroBlogger
  attr_reader :client

  def initialize
    puts 'Initializing MicroBlogger'
    @client = JumpstartAuth.twitter
    Klout.api_key = 'xu9ztgnacmjx3bu82warbr3h'
  end

  def tweet(message)
    if message.length > 140
      puts 'message exceeds 140 chars'
    else
      @client.update(message)
    end

  end

  def dm(target, message)
    puts "Trying to send #(target) this direct message:"
    puts message
screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
    if screen_names.include?(target) 
      message = "d @#{target} #{message}"
      tweet(message)
    else
      puts 'ERROR: you can only DM people who follow you'
    end
  end

  def followers_list 
    screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name }
    return screen_names
  end
  
  def spam_my_followers(message)
    followers_list.each { |follower| dm(follower, message) }
  end

  def everyones_last_tweet
    friends = @client.friends
    sorted_friends = friends.sort_by { |j| 
      if @client.user(j).screen_name.downcase[0] == /\d/
      @client.user(j).screen_name[0].to_i(2)
      else 
        @client.user(j).screen_name.downcase[0].unpack('B*')[0]
      end
    }
    sorted_friends.each do |friend|
      name = @client.user(friend).screen_name
      time = @client.user(friend).created_at.strftime('%A, %b %d')
      status = @client.user(friend).status.text
      p "#{name} said this on #{time}..."
      p "#{status}"
    end
  end
  
  def shorter_url(message, original_url)
    Bitly.use_api_version_3
    bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
    url = bitly.shorten(original_url).short_url
    tweet("#{message} #{url}")
  end 

  def klout_score
    friends = @client.friends
    sorted_friends = friends.sort_by { |j| 
      if @client.user(j).screen_name.downcase[0] == /\d/
      @client.user(j).screen_name[0].to_i(2)
      else 
        @client.user(j).screen_name.downcase[0].unpack('B*')[0]
      end
    }
    sorted_friends.each do |friend|
      name = @client.user(friend).screen_name
      p "#{name}"
      identity = Klout::Identity.find_by_screen_name(name)
      user = Klout::User.new(identity.id)
      score = user.score.score
      p "has a klout score of #{score}"
    end
  end



  def run
    puts 'Welcome to the JSL Twitter Client!'
    command = ''
    while command != 'q'
      printf 'enter command: '
      input = gets.chomp
      parts = input.split(' ')
      command = parts[0]
      case command
      when 'q' then puts 'Goodbye!'
      when 't' then tweet(parts[1..-1].join(' '))
      when 'dm' then dm(parts[1], parts [2..-1].join(' '))
      when 'spam' then spam_my_followers(parts [1..-1].join(' '))
      when 'elt' then everyones_last_tweet
      when 'turl' then shorter_url(parts[1..-2].join(' '), parts[-1])
      else
        puts "Sorry, I don't know how to #{command}"
      end
    end
  end
end
 
blogger = MicroBlogger.new
#p blogger.followers_list
#blogger.client.followers.each { |i| p i }
blogger.klout_score
blogger.run
