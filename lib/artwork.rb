# frozen_string_literal: true
require 'json'

class Artwork
  DATABASE = JSON.parse(File.read('db.json'))

  def self.formatted_count
    DATABASE.count.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
  end

  def self.find(id)
    DATABASE.find { |entry| entry['object_number'] == id }
  end
end
