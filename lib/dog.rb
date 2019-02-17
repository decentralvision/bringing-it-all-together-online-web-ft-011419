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
    row = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id)[0]
    dog_attr = {:id => row[0], :name => row[1], :breed => row[2]}
    dog = Dog.new(dog_attr)
    dog
  end

  def self.find_or_create_by(name:, breed:)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? and breed = ?", name, breed)
    if !row.empty?
      row = row[0]
      dog = self.new_from_db(row)
    else
      dog = self.create(name: name, breed: breed)
    end
    dog
  end

  def self.new_from_db(row)
    Dog.new({:id => row[0], :name => row[1], :breed => row[2]})
  end

  def self.find_by_name(name)
    row = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name)[0]
    self.new_from_db(row)
  end

  def update

  end

end
