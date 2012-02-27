require 'ferret'
class SearchIndex

  @@indexes_root = File.join(Rails.root, 'indexes')

  
  def initialize(user)
    @user = user
    @index_dir = File.join(@@indexes_root, @user.username)
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

  def reindex!
    @user.messages.select(:id).find_each{|m| @index.delete(m.id.to_s)}
    @index.flush #paranoid?
    @index.close
    @index = Ferret::I.new(:path => @index_dir)
    @user.messages.find_each{|m| @index << m.index_entry }
    @index.flush #even more paranoid
    @index.close
    @index = Ferret::I.new(:path => @index_dir)
  end

  def ferret_index
    return @index
  end

end