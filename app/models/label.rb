class Label < ActiveRecord::Base
    belongs_to :user
    has_and_belongs_to_many :messages

    def system?
      return self.system 
    end

end
