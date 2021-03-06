require 'fs_message_store'
require 'mail'
class Message < ActiveRecord::Base
	
	# for will_paginate
	self.per_page = 50

	belongs_to :user
	belongs_to :account

	has_and_belongs_to_many :labels


	def self.test_threaded_label_page(label)
	  thread_ids = Message.select(:thread_id).uniq.joins('INNER JOIN labels_messages lm ON lm.message_id = message_id').where('lm.label_id = ?', label.id).order('header_date DESC').limit(50).map{|m| m.thread_id}
	  threads = Message.where(:thread_id => thread_ids)
	end		

	def data_info
		return {
			:id => self.id,
			:message_id => self.header_message_id,
			:thread_id => self.thread_id,
			:date => self.header_date.to_i * 1000, #date as unix timestamp
			:from => self.header_from,
			:to => self.header_to,
			:subject => self.header_subject,
			:read => self.read,
			:has_attachments => self.has_attachments
		}
	end

	def data_details
		# everything from info view, plus more stuff
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
						:filename => Message.attachment_filename(a),
						:content_type => Message.attachment_content_type(a),
						:disposition => Message.attachment_disposition(a)
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
		return Mail.new(self.raw_message)
	end

	def add_reply
		# use the built-in Message#reply method.
		# if that method is given any params, will attempt to send the message, so don't do that

		reply_mail = self.parsed_message.reply # returns a Mail::Message

		#TODO: add quoting of original message
		reply_mail.body = "REPLY BODY"

		reply_label = Label.where(:user_id => self.user.id, :name => 'Drafts')[0]
		
		reply_msg = Message.add(reply_mail.to_s, self.user, self.account, reply_label)
		return reply_msg
	end

	# Call Message.add to store a new message for a user and have it indexed
	def self.add(raw_message, user, account, label, do_threading = true, do_indexing = true)
		
		if account.user.id != user.id or label.user.id != user.id
			raise "account or label do not belong to user"
		end

		message = Message.new
		message.user = user
		message.account = account
		message.read = false
		
		mail = Mail.new(raw_message)

		# initial thread id is set to our own message id.  
		# might be replaced by thread!, later
		message.header_message_id = message.thread_id = mail.message_id
		
		message.header_date = mail.date
		message.header_subject = mail.subject
		
		# to / from fields are handled weirdly by the mail gem.
		# mail.to / mail.from return either a string which is the bare email address (no display name)
		# or an array of such strings.  If we want the display name, we have to treat the mail object as a hash
		# and look at the :to and :from keys, both of which return Mail::Field objects.  Calling .to_s on
		# those objects will return all addresses joined together, with their display names.
		message.header_to = mail[:to].to_s
		message.header_from = mail[:from].to_s
		
		message.has_attachments = (mail.attachments and mail.attachments.length > 0)
		
		# save message so we can create its label association.
		message.save
		message.labels << label

		# if we can't store the raw message, the db entry is useless, so delete it
		begin
			FSMessageStore.put(message, raw_message)
		rescue => err
			message.delete
			raise err
		end

		if do_threading
			begin
				message.thread!
			rescue 
			end
		end

		if do_indexing
			# fuck that's slow
			user.index.add(message)
		end
		return message
	end

	def thread!
		# jwz's threading algorithm is all well and good, but we have our stuff in a database
		# and we're lazy and don't care about hierarchy, just a linear conversation view.
		#
		# scan the db for messages mentioned in References
		# if one of those belongs to a non-singleton thread then so do we
		# if not, try to find the last (most-recent) referenced message and add ourselves to its thread
		# if that doesn't work either, do the same for In-Reply-To
		# --finally, strip all "Re:" prefixes and try to find the first matching subject line--
		# actually, subject-line matching isn't all that great, forget that.
		# otherwise, we remain a singleton thread ourselves

		# don't even bother unless subject starts with "Re:"
		return unless self.header_subject and self.header_subject.strip.downcase.start_with?('re:')
		
		mail = Mail.new(self.raw_message)
		return unless mail.references

		in_reply_to = mail.in_reply_to || ""
		references = mail.references || [] # array of Message-ID -spec strings

		found_thread = false
		
		if references.length > 0
		
			referenced_msgs = Message.where(:user_id => self.user.id, :header_message_id => references)
			referenced_msgs.each do |rm|
				if rm.header_message_id != rm.thread_id
					found_thread = true
					self.thread_id = rm.thread_id
					break
				end
			end

			if not found_thread
				last_referenced_msg = Message.where(:user_id => self.user.id, :header_message_id => references.last).last
				if last_referenced_msg
					found_thread = true
					self.thread_id = last_referenced_msg.thread_id
				end
			end

		end
		
		if (not found_thread) and in_reply_to != ""
			in_reply_to_msg = Message.where(:user_id => self.user.id, :header_message_id => in_reply_to).first
			if in_reply_to_msg
				found_thread = true
				self.thread_id = in_reply_to_msg.thread_id
			end
		end

		# subject-line matching disabled
		#
		# if (not found_thread)
		# 	subject = self.header_subject.strip.downcase
		# 	while (subject.start_with?('re:'))
		# 		subject = subject[3,subject.length].strip
		# 	end
		# 	# TODO should use search index instead
		# 	subject_msgs = Message.where(:user_id => self.user.id, :header_subject => subject)
		# 	if subject_msgs.length > 0
		# 		found_thread = true
		# 		self.thread_id = subject_msgs.first.thread_id
		# 	end
		# end

		if found_thread
			self.save
		end

	end

	def body
		msg = self.parsed_message
		body = ""
		if msg.multipart?
			if msg.text_part
				body = msg.text_part.decoded
			end
		else
			body = msg.body.decoded
		end
		return body
	end

	def raw_message
		FSMessageStore.get(self)
	end

	# Returns the hash that will be indexed by the search engine for this message.
	def index_entry
		return { :id => self.id, 
			:message_id => self.header_message_id,
			:thread_id => self.thread_id,
			:account => self.account.name,
			:labels => self.labels.map {|l| l.name},
			:subject => self.header_subject,
			:from => self.header_from,
			:to => self.header_to,
			:has_attachments => self.has_attachments,
			:read => self.read,
			:body => self.body
		}
	end

	def self.attachment_disposition(att)
      return att['Content-Disposition'].value
  end

  def self.attachment_content_type(att)
      return att['Content-Type'].value
  end

  def self.attachment_filename(att)
      return att['Content-Disposition'].filename
  end

end
