# frozen_string_literal: true
require 'json'

class Artwork
  DATABASE = JSON.parse(File.read('db.json'))

  def self.find(id)
    DATABASE.find { |entry| entry['object_number'] == id }
  end

  def self.count
    DATABASE.count
  end
end
