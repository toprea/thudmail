class CreateLabelsMessages < ActiveRecord::Migration
  def up
    create_table :labels_messages do |t|
        
        t.references :message
        t.references :label
        
    end
  end

  def down
  end
end
