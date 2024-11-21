#!/usr/bin/env ruby
# frozen_string_literal: true

require 'csv'

class BenchmarkAnalyzer
  def self.call
    new.call
  end

  def initialize
    @results = CSV.read(ARGV[0], headers: true)
    @languages = @results['language'].uniq
  end

  def call
    results.group_by { |row| row['filename'] }.each do |filename, rows|
      print_file_statistics(filename, rows)
      print_performance_comparison(rows)
    end
  end

  private

  attr_reader :results, :languages

  def print_file_statistics(filename, rows)
    first_row = rows.first
    puts "\n===== Overall Statistics ======="
    puts "\nFile: #{filename}"
    puts "Size: #{first_row['file_size_mb'].to_f.round(2)}MB"
    puts "Rows: #{first_row['rows']}"
    puts "Columns: #{first_row['columns']}"

    languages.each do |lang|
      lang_rows = rows.select { |row| row['language'] == lang }
      next if lang_rows.empty?

      puts "\n#{lang} Statistics:"
      lang_rows.each do |row|
        puts "  #{row['method']}:"
        puts "    Duration: #{format('%.2f', row['duration_ms'].to_f)}ms"
        puts "    Memory: #{format('%.2f', row['memory_mb'].to_f)}MB"
        puts "    CPU: #{format('%.1f', row['cpu_percent'].to_f)}%"
      end
    end
  end

  def print_performance_comparison(rows)
    puts "\n==== Performance Comparison ===="

    # Group by method
    rows.group_by { |row| row['method'] }.each do |method, method_rows|
      puts "\n#{method.capitalize}:"

      # Sort by duration for ranking
      sorted = method_rows.sort_by { |row| row['duration_ms'].to_f }
      fastest = sorted.first
      fastest_duration = fastest['duration_ms'].to_f

      sorted.each do |result|
        duration = result['duration_ms'].to_f
        memory = result['memory_mb'].to_f
        cpu = result['cpu_percent'].to_f

        if result == fastest
          comparison = "🏆 Fastest"
        else
          # Calculate how many times slower: slower_time / faster_time
          times_slower = (duration / fastest_duration).round(2)
          comparison = "#{times_slower}x slower"
        end

        puts "  #{result['language']}: #{format('%.2f', duration)}ms (#{comparison})"
        puts "    Memory: #{format('%.2f', memory)}MB"
        puts "    CPU: #{format('%.1f', cpu)}%"
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  if !File.exist?(ARGV[0])
    puts "Error: #{ARGV[0]} not found!"
    exit 1
  end

  BenchmarkAnalyzer.call
end
