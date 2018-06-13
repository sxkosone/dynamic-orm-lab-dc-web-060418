require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'
##PAIR programming with Jared & Susanna
class InteractiveRecord
  def self.table_name
    self.to_s.downcase.pluralize
  end

  def self.column_names
    #returns sql results as hash
    sql = "pragma table_info('#{table_name}')"
    array = DB[:conn].execute(sql)
    #binding.pry
    column_names = []
    array.each do |hash|
        column_names << hash["name"]
    end
    column_names.compact
  end

  def save
    sql = "INSERT INTO #{self.table_name_for_insert} (#{self.col_names_for_insert}) VALUES (#{self.values_for_insert})"
    DB[:conn].execute(sql)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{self.table_name_for_insert}")[0][0]
  end

  def initialize(options={})
    options.each do |key, value|
        self.send("#{key}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col_name| col_name == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
        values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def self.find_by_name(name)
    
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    DB[:conn].execute(sql)
  end

  def self.find_by(hash)
    sql = "SELECT * FROM #{self.table_name} WHERE #{hash.first[0].to_s} = '#{hash.first[1]}'"
    #OR SAME THING WITH EACH
    # sql = ""
    # hash.each do |key, value|
    #     sql = "SELECT * FROM #{self.table_name} WHERE #{key.to_s} = '#{value}'"
    # end
    DB[:conn].execute(sql)
  end

end