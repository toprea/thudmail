class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
    	
    	t.references :user   	
        t.references :account

    	t.datetime :header_date
        
        t.string :header_message_id
    	t.string :header_from
        t.string :header_to, :limit => 1000
    	t.string :header_subject

        t.boolean :read
        t.boolean :has_attachments

        t.timestamps
    end
  end
end