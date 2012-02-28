class ApiController < ApplicationController

    # TODO we currently link to attachments directly in the client, so we can't
    # ensure that the auth token header is sent.  Fix this.
    before_filter :validate_authtoken, :except => [:login, :attachment]

    # pushState doesn't seem to work so well, but if we were to do it,
    # this action renders public.html
    #def client
    #    render :file => File.join(Rails.root, "public", "index.html"), :layout => false
    #end

    def validate_authtoken
        token = request.env['HTTP_X_THUDMAIL_AUTHTOKEN']
        if token
            user = User.validate_authtoken(token)
            if user
                @current_user = user
                return
            end
        end
        unauthorized
    end

    def unauthorized
        render :nothing => true, :status => 403
    end

    def mark_read
    end

    def mark_unread
    end

    def delete
    end

    def login
        user = User.authenticate(params[:username], params[:password])
        response = {}
        if user
            response = {:status => 'success', :authtoken => user.generate_authtoken}
        else
            response = {:status => 'error'}
        end
        json response
    end
    
    def search
        #refactor pagination out of here
        query = params[:q]
        page_size = 50
        page = (params[:page] || 1).to_i
        results = @current_user.index.search(query, :offset => (page_size * (page - 1)), :limit => page_size)
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
        system_labels = Label.where(:user_id => @current_user.id, :system => true)
        user_labels = Label.where(:user_id => @current_user.id, :system => false)
        response = {:systemLabels => system_labels.map{|l| l.name},
            :userLabels => user_labels.map{|l| l.name} }
        json response
    end


    def label
        label = Label.where(:user_id => @current_user.id, :name => params[:name]).first
        #msgs = Message.where(:label_id => label.id).order('header_date DESC').page(params[:page])
        msgs = label.messages.order('header_date DESC').page(params[:page])
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
        msg = Message.where(:user_id => @current_user.id, :id => params[:id])[0]
        json msg.data_info
    end

    def details
        msg = Message.where(:user_id => @current_user.id, :id => params[:id])[0]
        json msg.data_details
    end

    def attachment
        #TODO: we don't check userID -- change when we fix attachment links to have auth tokens
        #msg = Message.where(:user_id => @current_user.id, :id => params[:id])[0]
        msg = Message.where(:id => params[:id])[0]
        att = msg.parsed_message.attachments[params[:index].to_i]

        content_type = Message.attachment_content_type(att)
        filename = Message.attachment_filename(att)
        #disposition = Message.attachment_disposition(att)
        
        send_data att.body.decoded, :type => content_type, :filename => filename#, :disposition => disposition
    end

    

    def json(data)
        headers['Content-Type'] = "application/json; charset=utf-8"
        render :json => data
    end

end
