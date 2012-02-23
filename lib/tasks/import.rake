namespace :import do

	
	
	desc "Import all messages from an directory into a user's account."
	task :dir => :environment do
		unless ENV.include?("dir") and ENV.include?("username") and ENV.include?("account") and ENV.include?("label")
			raise "usage: rake import:dir dir=<path> username=<user> account=<account> label=<label> [max=<num-max-messages>]"
		end
		username = ENV['username']
		accountname = ENV['account']
		labelname = ENV['label']
		dir = ENV['dir']
		max = ENV['max']

		unless File.exists?(dir) and File.directory?(dir)
			raise "Could not find dir #{dir}"
		end

		user = User.where(:username => username).first
		unless user
			raise "could not find user #{username}"
		end
		puts "found user #{user.username}"

		account = Account.where(:user_id => user.id, :name => accountname).first
		unless account
			raise "could not find account #{accountname}"
		end
		puts "found account #{account.name}"

		label = Label.where(:user_id => user.id, :name => labelname).first
		unless label
			raise "could not find label #{labelname}"
		end
		puts "found label #{label.name}"

		
		i = 0
		Dir.foreach(dir) do |filename|
			next if filename == '.' or filename == '..'
			str = IO.read("#{dir}/#{filename}")
			Message.add(str, user, account, label)
						
			i += 1
			puts "Imported message #{i} - #{dir}/#{filename}"
			if max and (i >= max.to_i)
				break
			end
		end
		
	end

end