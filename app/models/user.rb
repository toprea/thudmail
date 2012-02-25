require 'search_index'
class User < ActiveRecord::Base
	has_secure_password

	has_many :accounts
	has_many :labels
	has_many :messages

	# returns the user object or false
	def self.authenticate(username, password)
		User.find_by_username(username).try(:authenticate, password)
	end
	
	def self.add(username, password)
		user = User.create(:username => username, :password => password)
		account = Account.create(:user => user, :name => 'default')
		label = Label.create(:user => user, :name => 'INBOX', :system => true)
		label = Label.create(:user => user, :name => 'Sent Mail', :system => true)
		label = Label.create(:user => user, :name => 'Drafts', :system => true)
		return user
	end

	# returns the Ferret index for the current user.
	# if index does not exist, creates it.
	def index
		if not @index 
			@index = SearchIndex.new(self)
		end
		return @index
		
	end

	def generate_authtoken
		return self.username
	end

	def self.validate_authtoken(token)
		User.find_by_username(token)
	end

	
end
