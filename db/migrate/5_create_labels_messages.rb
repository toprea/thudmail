class CreateLabelsMessages < ActiveRecord::Migration
  def up
    create_table :labels_messages do |t|
        
        t.references :message, :null => false
        t.references :label, :null => false
        
    end
  end

  def down
  end
end
