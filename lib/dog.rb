class Dog

attr_reader :id
attr_accessor :name, :breed

  def initialize (id: nil, name:, breed:)
    @id = id
    @name = name
    @breed = breed
  end

  def self.create_table
    query = <<-SQL
    CREATE TABLE dogs (
      id INTEGER PRIMARY KEY,
      name STRING,
      breed STRING
    )
    SQL
    DB[:conn].execute(query)
  end

  def self.drop_table
    DB[:conn].execute("DROP TABLE dogs")
  end

  def self.new_from_db(row)
    Dog.new(id: row[0], name: row[1], breed: row[2])
  end

  def self.create(hash)
    dog = Dog.new(name: hash[:name], breed: hash[:breed])
    dog.save
    dog
  end

  def self.find_by_id(id)
    query = <<-SQL
    SELECT * FROM dogs
    WHERE id = ?
    SQL
    DB[:conn].execute(query, id).map { |row| new_from_db(row) }.first
  end

  def self.find_or_create_by(name:, breed:)
    query = <<-SQL
    SELECT *
    FROM dogs
    WHERE name = ? AND breed = ?
    SQL
    dog = DB[:conn].execute(query, name, breed)

    unless dog.empty?
      data = dog[0]
      dog = Dog.new(id: data[0], name: data[1], breed: data[2])
    else
      dog = create(name: name, breed: breed)
    end
    dog
  end

  def self.find_by_name(name)
    query = <<-SQL
    SELECT * FROM dogs
    WHERE name = ?
    SQL
    DB[:conn].execute(query, name).map { |row| new_from_db(row) }.first
  end

  def save
    if @id
      update
    else
      query = <<-SQL
      INSERT INTO dogs (name, breed)
      VALUES (?, ?)
      SQL
      DB[:conn].execute(query, @name, @breed)
      query = <<-SQL
      SELECT last_insert_rowid()
      FROM dogs
      SQL
      @id = DB[:conn].execute(query)[0][0]
    end
    self
  end

  def update
    query = <<-SQL
    UPDATE dogs
    SET name = ?, breed = ?
    WHERE id = ?
    SQL
    DB[:conn].execute(query, @name, @breed, @id)
  end

end
