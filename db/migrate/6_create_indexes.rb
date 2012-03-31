class CreateIndexes < ActiveRecord::Migration
  def up

    add_index :messages, :id
    add_index :messages, :thread_id
    add_index :messages, :header_message_id
    add_index :messages, :header_date
    add_index :messages, :header_subject
    
    add_index :labels_messages, :label_id
    add_index :labels_messages, :message_id
    add_index :labels_messages, [:label_id, :message_id]
    

  end

  def down
  end
end
