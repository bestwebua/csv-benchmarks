#!/usr/bin/env ruby
# frozen_string_literal: true

require 'securerandom'

class CsvFileGenerator
  def self.generate(filename, rows, columns)
    File.open(filename, 'w') do |file|
      file.puts((1..columns).to_a.join(','))
      (rows - 1).times { file.puts(Array.new(columns) { SecureRandom.hex(16) }.join(',')) }
    end
  end
end

CsvFileGenerator.generate(ARGV[0], ARGV[1].to_i, ARGV[2].to_i)
