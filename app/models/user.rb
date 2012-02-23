class User < ActiveRecord::Base
	has_secure_password

	has_many :accounts
	has_many :labels
	has_many :messages

	# returns the user object or false
	def self.authenticate(username, password)
		User.find_by_username(username).try(:authenticate, password)
	end
	

	# returns the Ferret index for the current user.
	# if index does not exist, creates it.
	def index
		if @index 
			return @index
		end
		index_dir = self.index_dir
		unless File.exists?(index_dir) 
			Dir.mkdir(index_dir)
		end
		@index = Ferret::I.new(:path => index_dir)
		return @index
	end

	#don't actually know how to do this yet
	def rebuild_index
		return false
	end

	def index_dir
		"#{Rails.root}/indexes/#{username}"
	end

	
end
