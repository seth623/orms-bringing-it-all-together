class Dog

    attr_accessor :name, :breed
    attr_reader :id

    def initialize(id: nil, name:, breed:)
        @id = id 
        @name = name 
        @breed = breed 
    end 

    def save

        if @id 
            self.update 
        else
            sql = <<-SQL
            INSERT INTO dogs (name, breed)
            VALUES (?, ?)
            SQL

            DB[:conn].execute(sql, self.name, self.breed)

            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs;")[0][0]
        end 

        self 

    end 

    def self.create(hash)
        
        name = hash[:name]
        breed = hash[:breed]

        new_dog = self.new(name: name, breed: breed)

        new_dog.save 

    end 

    def self.create_table

        sql = <<-SQL
        CREATE TABLE dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        );
        SQL

        DB[:conn].execute(sql)
    
    end 

    def self.drop_table

        sql = <<-SQL
        DROP TABLE dogs;
        SQL

        DB[:conn].execute(sql)

    end

    def self.find_or_create_by(name:, breed:)

        sql = <<-SQL
        SELECT * 
        FROM dogs 
        WHERE name == ? AND breed == ?
        SQL
        dog_find = DB[:conn].execute(sql, name, breed)[0]

        if dog_find 
            self.new_from_db(dog_find) 
        else 
            new_dog_hash = {}
            new_dog_hash[:name] = name 
            new_dog_hash[:breed] = breed
            self.create(new_dog_hash)
        end 

    end 
    
    def self.find_by_id(id)

        sql = <<-SQL
        SELECT * 
        FROM dogs
        WHERE id == ?
        SQL

        dog_row = DB[:conn].execute(sql, id)[0]

        self.new_from_db(dog_row)

    end 

    def self.find_by_name(name)

        sql= <<-SQL
        SELECT * 
        FROM dogs 
        WHERE name == ?;
        SQL

        dog_data = DB[:conn].execute(sql, name)[0]

        self.new_from_db(dog_data)

    end 

    def self.new_from_db(array)

        object = Dog.new(id: array[0], name: array[1], breed: array[2])

        object 

    end
    
    def update

        sql = <<-SQL
        UPDATE dogs 
        SET name = ?, breed = ?
        WHERE id == ?;
        SQL

        DB[:conn].execute(sql, self.name, self.breed, self.id)

    end 

end
