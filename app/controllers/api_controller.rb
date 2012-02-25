class ApiController < ApplicationController

    def mark_read
    end

    def mark_unread
    end

    def delete
    end
    
    def search
        #refactor pagination out of here
        query = params[:q]
        page_size = 50
        page = (params[:page] || 1).to_i
        results = User.first.index.search(query, :offset => (page_size * (page - 1)), :limit => page_size)
        #        search_entries = results.hits.map{|h| {:score => h.score, :message_id => h.doc, :message => Message.find(h.doc).data_info} }
        search_entries = results.hits.map{|h| Message.find(h.doc).data_info } 
        response = {    :messages => search_entries, 
            :count => results.hits.count, 
            :page => page, 
            :per_page => page_size, 
            :total => results.total_hits
        }
        json response
    end

    def labels
        system_labels = Label.where(:system => true)
        user_labels = Label.where(:system => false)
        response = {:systemLabels => system_labels.map{|l| l.name},
            :userLabels => user_labels.map{|l| l.name} }
        json response
    end


    def label
        label = Label.where(:name => params[:name]).first
        msgs = label.messages.page(params[:page])
        info_entries = msgs.map{|m| m.data_info}
        response = {
            :messages => info_entries,
            :count => info_entries.length, # on this page
            :page => params[:page] || "1", # page number
            :per_page => Message.per_page, # per page
            :total => msgs.total_entries # in the db
        }
        json response
    end

    def info
        msg = Message.find(params[:id])
        json msg.data_info
    end

    def details
        msg = Message.find(params[:id])
        json msg.data_details
    end

    def attachment
        msg = Message.find(params[:id])
        attachment = msg.parsed_message.attachments[params[:index].to_i]
        content_type_combined = attachment.content_type
        content_type, filename = content_type_combined.split('; name=')
        send_data attachment.body.decoded, :type => content_type, :filename => filename, :disposition => 'inline'
    end

    def json(data)
        headers['Content-Type'] = "application/json; charset=utf-8"
        render :json => data
    end

end
