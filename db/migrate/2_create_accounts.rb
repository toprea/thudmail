class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
    	
    	t.references :user, :null => false
    	t.string :name, :null => false

     t.timestamps
   end
 end
end
