class CreateLabels < ActiveRecord::Migration
  def up
    create_table :labels do |t|
      
      t.references :user
      t.string :name, :null => false
      t.boolean :system, :null => false
    end
  end

  def down
  end
end
