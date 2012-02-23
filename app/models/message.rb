require 'fs_message_store'
require 'mail'
class Message < ActiveRecord::Base
	
	# for will_paginate
	self.per_page = 50

	belongs_to :user
	belongs_to :account

	has_and_belongs_to_many :labels

	def data_info
		{
			:id => self.id,
			:message_id => self.header_message_id,
			:date => self.header_date,
			:from => self.header_from,
			:to => self.header_to,
			:subject => self.header_subject,
			:read => self.read,
			:has_attachments => self.has_attachments
		}
	end

	def data_details
		data = self.data_info

		msg = self.parsed_message
		if msg.multipart?
			# we only look for a text body. 
			if msg.text_part
				data[:body] = msg.text_part.body.decoded
			end
			if msg.attachments
				atts = []
				msg.attachments.each do |a|

					atts << {
						:index => msg.attachments.index(a),
						:content_id => a.content_id,
						:content_type => a.content_type
					}
				end
				data[:attachments] = atts
			end
		else
			data[:body] = msg.body.decoded
		end

		return data
	end

	def parsed_message
		Mail.new(self.raw_message)
	end

	# Call Message.add to store a new message for a user and have it indexed
	def self.add(raw_message, user, account, label)
		#TODO sanity checks: label is user's, etc

		message = Message.new
		message.user = user
		message.account = account
		message.labels << label
		message.read = false
		
		mail = Mail.new(raw_message)
		message.header_message_id = mail.message_id
		message.header_date = mail.date
		message.header_from = mail.from.to_s
		message.header_subject = mail.subject
		message.header_to = (mail.to ? mail.to.join(", ") : "")
		message.has_attachments = (mail.attachments and mail.attachments.length > 0)
		
		# transactional: storing the message data requires a saved message.
		# if something goes wrong storing it, delete the message as it is not valid
		message.save
		begin
			FSMessageStore.put(message, raw_message)
		rescue => err
			message.delete
			raise err
		end

		user.index << message.index_entry
	end


	def raw_message
		FSMessageStore.get(self)
	end

	# Returns the document that will be indexed by Ferret for this message.
	def index_entry
		
		msg = self.parsed_message
		body = ""
		if msg.multipart?
			if msg.text_part
				body = msg.text_part.decoded
			end
		else
			body = msg.body.decoded
		end
		index_entry = { :id => self.id, 
				:account => self.account.name,
				:labels => self.labels.map {|l| l.name},
				:subject => self.header_subject,
				:from => self.header_from,
				:to => self.header_to,
				:has_attachments => self.has_attachments,
				:read => self.read,
				:body => body
		}
		return index_entry
	end

end
