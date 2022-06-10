class Dog
    #attributes has a name and a breed. #has an id that defaults to `nil` on initialization
 attr_accessor :name, :breed, :id

    def initialize(name:, breed:, id: nil)
      @id = id
      @name = name
      @breed = breed
    end

    #creates the dogs table in the database
    def self.create_table
    sql = <<-SQL
    CREATE TABLE IF NOT EXISTS dogs (
        id INTEGER PRIMARY KEY,
        name TEXT,
        breed TEXT
        )
    SQL
    DB[:conn].execute(sql)
    end
    # drops the dogs table from the database
    def self.drop_table
        sql = "DROP TABLE IF EXISTS dogs"
        DB[:conn].execute(sql)
    end

    #save. returns an instance of the dog class
    #saves an instance of the dog class to the database and then sets the given dogs `id` attribute
    def save
        if self.id
            self.update
          else
            sql = <<-SQL
              INSERT INTO dogs (name, breed)
              VALUES (?, ?)
            SQL
            DB[:conn].execute(sql, self.name, self.breed)
            self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
          end 
          self
    end
    #create a new dog object and uses the #save method to save that dog to the database
  
    def self.create(name:, breed:)
        dog = Dog.new(name: name, breed: breed)
        dog.save
      end
    #.new_from_db: creates an instance with corresponding attribute values
    def self.new_from_db(row)
    self.new(id: row[0], name: row[1], breed: row[2])
    end
    #.all: returns an array of Dog instances for all records in the dogs table
    def self.all 
    sql = <<-SQL
    SELECT *
    FROM dogs;
  SQL

  DB[:conn].execute(sql).map do |row|
    self.new_from_db(row)
    end
    end

    #.find_by_name: returns an instance of dog that matches the name from the DB
   def  self.find_by_name (name)
    sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE dogs.name = ?
        LIMIT 1
        SQL

        DB[:conn].execute(sql, name).map do |row|
            self.new_from_db(row)
        end.first
    end
    #.find: returns a new dog object by id
    def self.find(id)
        sql = <<-SQL
        SELECT *
        FROM dogs
        WHERE dogs.id = ?
        LIMIT 1
        SQL
        DB[:conn].execute(sql, id).map do |row|
            self.new_from_db(row)
        end.first
    end

    #advanced delieverabls

    def self.find_or_create_by(name:, breed:)
        sql = <<-SQL
          SELECT *
          FROM dogs
          WHERE name = ?
          AND breed = ?
          LIMIT 1
        SQL
    
        row = DB[:conn].execute(sql, name, breed).first
    
        if row
          self.new_from_db(row)
        else
          self.create(name: name, breed: breed)
        end
      end
    
      def update
        sql = <<-SQL
          UPDATE dogs 
          SET 
            name = ?, 
            breed = ?  
          WHERE id = ?;
        SQL
        
        DB[:conn].execute(sql, self.name, self.breed, self.id)
      end
    

end