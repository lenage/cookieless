class TestStore
  attr_accessor :store
  def initialize
    @store = {}
  end

  def exist?(id)
    @store.include?(id)
  end

  def read(id)
    @store[id]
  end

  def write(id,val)
    @store[id]=val
  end
end
