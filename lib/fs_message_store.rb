require 'fileutils'
class FSMessageStore
    
    
    @@basedir = "#{Rails.root}/mailboxes"

    def FSMessageStore.filename_for_message(message)
        "#{@@basedir}/#{message.user.username}/#{message.id.to_s}.eml"
    end

    def FSMessageStore.put(message, str_data)
        
        unless File.exists?(@@basedir)
            Dir.mkdir(@@basedir, 0700)
        end

        store_dir = message.user.username
        unless File.exists?("#{@@basedir}/#{store_dir}")
            Dir.mkdir("#{@@basedir}/#{store_dir}", 0700)
        end

        store_filename = self.filename_for_message(message)
        file = File.new(store_filename, "w", 0700)
        num_bytes = file.write(str_data)
        file.close
        return num_bytes
    end

    def FSMessageStore.delete(message)
        File.delete(self.filename_for_message(message))
    end

    def FSMessageStore.get(message)
        IO.read(self.filename_for_message(message))
    end

end