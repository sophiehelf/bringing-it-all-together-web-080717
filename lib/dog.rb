class Dog
  attr_accessor :name, :breed, :id

  def initialize(name:, breed:, id: nil)
    @name = name
    @breed = breed
    @id = id
  end

  def self.create_table

  end

  def self.drop_table
    sql = "DROP TABLE dogs;"
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL 
    INSERT INTO dogs (name, breed) 
    VALUES (?, ?) 
    SQL
    DB[:conn].execute(sql, self.name, self.breed)
    results = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")
    @id = results.flatten.first
    self
  end

  def self.create(attributes)
    dog = Dog.new(attributes)
    dog.save
  end

  def self.find_by_id(new_id)
    sql = <<-SQL
      SELECT * FROM dogs WHERE id = ? LIMIT 1
    SQL
    result = DB[:conn].execute(sql, new_id).flatten
    dog = Dog.new(id: result[0], name: result[1], breed: result[2])
  end

  def self.new_from_db(array)
    dog = Dog.new(id: array[0], name: array[1], breed: array[2])
  end

  def self.find_by_name(new_name)
    sql = <<-SQL
      SELECT * FROM dogs WHERE name = ? LIMIT 1
    SQL
    result = DB[:conn].execute(sql, new_name).flatten
    dog = Dog.new(id: result[0], name: result[1], breed: result[2])
  end

  def update
    sql = <<-SQL
      UPDATE dogs 
      SET name = ?, breed = ?
      WHERE id = ?
    SQL
    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

  def self.persists?(dog_hash)
    sql = <<-SQL
    SELECT * FROM dogs 
    WHERE name = ? AND breed = ?
    LIMIT 1
  SQL
  result = DB[:conn].execute(sql, dog_hash[:name], dog_hash[:breed]).flatten
  return {valid: !!result.first, entry: result}
  end

  def self.find_or_create_by(dog_hash)
  sql = <<-SQL
    SELECT * FROM dogs
    WHERE name = ? AND breed = ?
    LIMIT 1
  SQL
  result = DB[:conn].execute(sql, dog_hash[:name], dog_hash[:breed]).flatten 
  result.first ? Dog.new(id: result[0], name: result[1], breed: result[2]) : self.create(dog_hash)
end

end