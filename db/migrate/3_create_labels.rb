class CreateLabels < ActiveRecord::Migration
  def up
    create_table :labels do |t|
        
        t.references :user
        t.string :name
        t.boolean :system
    end
  end

  def down
  end
end
