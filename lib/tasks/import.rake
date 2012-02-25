namespace :import do

	desc "Import all messages from a directory into a user's account."
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




	desc "Import all messages from a set of directories.  Each top-level directory becomes a username, each dir under that a label."
	task :dirs => :environment do
		unless ENV.include?("rootdir")
			raise "usage: rake import:dirs rootdir=<path>"
		end
		rootdir = ENV['rootdir']


		unless File.exists?(rootdir) and File.directory?(rootdir)
			raise "Could not find dir #{rootdir}"
		end

		# loop over all top-level dirs and create users for them
		Dir.foreach(rootdir) do |userdir|
			next if userdir.start_with?(".") or (not File.directory?(File.join(rootdir,userdir)))
			puts "userdir: #{userdir}"

			# create user with username/pwd set to dir name
			# default account and inbox/sent/drafts labels are created as well
			user = User.add(userdir, userdir)
			next unless user
			account = user.accounts[0]
			next unless account

			# loop over all dirs in the user dir and create labels for them
			Dir.foreach(File.join(rootdir, userdir)) do |labeldir|
				next if labeldir.start_with?(".") or (not File.directory?(File.join(rootdir, userdir, labeldir)))
				puts "labeldir: #{labeldir}"

				label = nil
				if labeldir == 'inbox'
					label = Label.where(:user_id => user.id, :name => 'INBOX')[0]
					puts "matched INBOX label"
				elsif labeldir == 'sent_items' or labeldir == '_sent_mail' or labeldir == 'sent'
					label = Label.where(:user_id => user.id, :name => 'Sent Mail')[0]
					puts "matched Sent Mail label"
				else
					label = Label.create(:user => user, :name => labeldir, :system => false)
					puts "created new label"
				end
				next unless label

				puts "importing into user #{user.username}, label #{label.name}"

				Dir.foreach(File.join(rootdir, userdir, labeldir)) do |email|
					next if email.start_with?(".") or File.directory?(File.join(rootdir, userdir, labeldir, email))
					#puts "email: #{email}"

					str = IO.read(File.join(rootdir, userdir, labeldir, email))
					Message.add(str, user, account, label)
				end #email

			end #label
		end #user

	end
end