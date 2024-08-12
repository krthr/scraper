# require "granite"
# require "granite/adapter/sqlite"

require "db"
require "sqlite3"
require "json"

module DefinitionsConverter
  def self.from_rs(rs : DB::ResultSet) : Array(JSON::Any)
    str = rs.read(String)
    Array(JSON::Any).from_json(str)
  end
end

class Database
  @@db : DB::Database?

  DATABASE_URI = "sqlite3://./database.db"

  getter db : DB::Database

  def initialize
    @db = DB.open(DATABASE_URI)
    @@db = @db
  end

  def create_tables
    @db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS `urls` (
        `id` INTEGER NOT NULL PRIMARY KEY autoincrement,
        `url` TEXT NOT NULL UNIQUE
      ) 
    SQL

    @db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS `pages` (
        `id` INTEGER NOT NULL PRIMARY KEY autoincrement,
        `url` TEXT NOT NULL UNIQUE,
        `definitions` BLOB NOT NULL
      ) 
    SQL

    @db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS `robots` (
        `id` INTEGER NOT NULL PRIMARY KEY autoincrement,
        `host` TEXT NOT NULL UNIQUE
      ) 
    SQL

    @db.exec <<-SQL
      CREATE TABLE IF NOT EXISTS `sitemaps` (
        `id` INTEGER NOT NULL PRIMARY KEY autoincrement,
        `url` TEXT NOT NULL UNIQUE
      ) 
    SQL
  end

  def first(table, klass)
    db.query_one?("SELECT * FROM #{table} LIMIT 1", as: klass)
  end

  def delete(table, id)
    db.exec("DELETE FROM #{table} WHERE id=?", id)
  end

  class Robots
    include DB::Serializable

    property id : Int64
    property host : String
  end

  class Sitemap
    include DB::Serializable

    property id : Int64
    property url : String
  end

  class Page
    include DB::Serializable
    include JSON::Serializable

    property id : Int64
    property url : String

    @[DB::Field(converter: DefinitionsConverter)]
    property definitions : Array(JSON::Any)
  end

  class Url
    include DB::Serializable

    property id : Int64
    property url : String
  end
end
