class Dog
  attr_accessor :name, :breed, :id

  def initialize(hash)
    @name = hash[:name]
    @breed = hash[:breed]
    @id = hash[:id]
  end

  def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
      id INTEGER PRIMARY KEY,
      name TEXT,
      breed TEXT
    );
    SQL
    DB[:conn].execute(sql)
  end

  def self.drop_table
    sql = <<-SQL
    DROP TABLE dogs
    SQL
    DB[:conn].execute(sql)
  end

  def save
    sql = <<-SQL
    INSERT INTO dogs (name, breed)
    VALUES (?,?)
    SQL
    DB[:conn].execute(sql,@name, @breed )
    values = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")
    self.id = values.flatten[0]
    return self
  end

  def self.create(hash)
    dog = self.new(hash)
    dog.save
  end

  def self.find_by_id(id)
    values = DB[:conn].execute("Select * FROM dogs where id = ?",id).flatten
    hash = {id: values[0], name:values[1], breed: values[2]}
    self.new(hash)
  end

  def self.find_or_create_by(hash)
    info = DB[:conn].execute("Select * FROM dogs where name = ? AND breed = ?", hash[:name], hash[:breed]).flatten
      if  info != []
        hash = {id:info[0], name:info[1], breed: info[2]}
        self.new(hash)
      else
        hash = {id:info[0], name:info[1], breed: info[2]}
        self.create(hash)
      end
  end

  def self.new_from_db(row)
    hash = {id: row[0], name:row[1], breed: row[2]}
    self.new(hash)
  end

  def self.find_by_name(name)
    info = DB[:conn].execute("Select * FROM dogs WHERE dogs.name = ?",name).flatten
    hash = {id: info[0], name:info[1], breed: info[2]}
    self.new(hash)
  end

  def update
    sql = <<-SQL
      UPDATE dogs SET name = ?, breed = ? WHERE id = ?
    SQL

    DB[:conn].execute(sql, self.name, self.breed, self.id)
  end

end
