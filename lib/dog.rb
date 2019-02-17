class Dog
  attr_accessor :id, :name, :breed
  def initialize(id:nil, name:nil, breed:nil)
    @id = id
    @name = name
    @breed = breed
  end
  def self.create_table
    sql = <<-SQL
      CREATE TABLE dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
      )
    SQL
    DB[:conn].execute(sql)
  end
  def self.drop_table
    DB[:conn].execute("DROP TABLE IF EXISTS dogs")
  end
  def save
    DB[:conn].execute("INSERT INTO dogs (name, breed) VALUES (?, ?)", self.name, self.breed)
    self.id = DB[:conn].execute("SELECT id FROM dogs WHERE id = (SELECT MAX(id) FROM dogs)")[0][0]
    self
  end
  def self.create(dog_attr)
    dog = self.new(id:dog_attr[:id], name:dog_attr[:name], breed:dog_attr[:breed])
    saved_dog = dog.save
  end

  def self.find_by_id(id)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).last
    dog_attr = {:id => row[0], :name => row[1], :breed => row[2]}
    dog = self.create(dog_attr)
    dog
  end
end
