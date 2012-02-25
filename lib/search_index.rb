require 'ferret'
class SearchIndex

  @@indexes_root = File.join(Rails.root, 'indexes')

  
  def initialize(user)
    @username = user.username
    @index_dir = File.join(@@indexes_root, @username)
    unless File.exists?(@index_dir) 
      Dir.mkdir(@index_dir)
    end
    @index = Ferret::I.new(:path => @index_dir)
  end

  def add(message)
    return if message.user.username != @username
    @index << message.index_entry
  end

  def search(query, options={})
    results = @index.search(query, options)
    return results
  end

  

end