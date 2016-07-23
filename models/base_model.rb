require 'pg'

class BaseModel

  attr_accessor :id

  @@connection = PG.connect(dbname: 'quotes_inc', host: 'localhost')
  @@table_name = nil

  # returns table_name or the name of the class "pluralized" and lowercase
  def self.table_name
    @@table_name || self.name.downcase << "s"
  end

  # creates an attribute accessor for each instance variable,
  # based on the table's column names
  def self.initialize_attributes
    sql = "SELECT column_name FROM INFORMATION_SCHEMA.COLUMNS WHERE table_name='#{table_name}';"
    result = @@connection.exec(sql)

    raise "Undefined table or colum names for #{table_name}"

    result.each do |row|
      self.class_eval("attr_accessor :#{row['column_name']}") if row['column_name'] != 'id'
    end
  end

  # call the above method when subclass is instantiated
  def self.inherited(subclass)
    subclass.initialize_attributes
    super
  end

  # initialize takes a hash of data, we trust the data is good,
  # and create an instance variable for key / value pair in the hash
  def initialize(data)
    @id = data[:id] ? data[:id].to_i : nil 

    data.delete(:id)

    data.each do |key, value|
      instance_variable_set("@#{key}", value)
    end
  end

  # get all records for this table, and create an instance for each
  def self.all
    sql = "SELECT * FROM quotes"
    result = @@connection.exec(sql)
    
    result.map do |record|
      self.new(record)
    end
  end

  # insert a new record into the database, then create a new instnce for it
  def self.create(data)

    sql = "INSERT INTO #{table_name} ("
    sql << data.keys.join(',')
    sql << ") VALUES ("
    sql << data.values.map { |value| "'#{@@connection.escape_string(value)}'" }.join(',')
    sql << " RETURNING *"

    result = @@connection.exec(sql)

    record = result[0]
    self.new(record)
  end

  # query the table by id, then create an instance for the result
  def self.find(id)
    sql = "SELECT * FROM #{table_name} WHERE id=#{id}"
    result = @@connection.exec(sql)

    record = result[0]
    self.new(record)
  end

  # query the database using a hash of key/value pair
  # key refers to the column, value the value
  # create an instance for each row returned from the query
  def self.where(data)
    sql = "SELECT * FROM #{table_name} WHERE "
    sql << data.map do |key, value|
      "#{key}='#{value}'"
    end.join(" AND ")

    result = @@connection.exec(sql)

    result.map do |record|
      self.new(record)
    end
  end

  # update the database using the data held in the instance
  def save
    attrs = self.instance_variables.map { |attr| attr[1..-1].to_sym }
    attrs.delete(:id)

    if self.id
      sql = "UPDATE #{self.class.table_name} SET "
      sql << attrs.map do |attr|
        "#{attr}='#{@@connection.escape_string(self.send(attr))}'"
      end.join(",")
      sql << " WHERE id=#{self.id}"

      @@connection.exec(sql)

      self
    else
      sql = "INSERT INTO #{self.class.table_name} ("
      sql << attrs.join(',')
      sql << ") VALUES ("
      sql << attrs.map { |attr| "'#{@@connection.escape_string(self.send(attr))}'" }.join(',')
      sql << ") RETURNING *"

      result = @@connection.exec(sql)
      @id = result[0]['id'].to_i
    end    
  end

  # delete a row by the instance's id
  def destroy
    sql = "DELETE FROM #{table_name} WHERE id=#{id}"

    @@connection.exec(sql)
  end
end