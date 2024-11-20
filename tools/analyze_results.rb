#!/usr/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'terminal-table'

class BenchmarkAnalyzer
  def initialize(file_path = ARGV[0])
    @results = CSV.read(file_path, headers: true)
    @languages = @results['language'].uniq
  end

  def call
    print_summary_table
    print_detailed_comparison
  end

  private

  attr_reader :results, :languages

  def grouped_results
    @grouped_results ||= results.group_by { |row| row['filename'] }
  end

  def print_summary_table
    grouped_results.each do |filename, rows|
      # Get file metrics from the first row
      first_row = rows.first
      file_info = {
        rows: first_row['rows'].to_i,
        columns: first_row['columns'].to_i,
        size: first_row['file_size_mb'].to_f
      }
      
      # Create file info table
      file_table = Terminal::Table.new do |t|
        t.style = { border_x: "=", border_i: "=", border_y: "||" }
        t.rows = [
          ["File Analysis"],
          ["Filename", filename],
          ["File size", "#{file_info[:size].round(2)} MB"],
          ["Rows", file_info[:rows].to_s],
          ["Columns", file_info[:columns].to_s]
        ]
      end
      puts "\n#{file_table}"
      
      # Create benchmark results table
      results_table = Terminal::Table.new do |table|
        table.headings = ['Language', 'Method', 'Duration (ms)', 'Memory (MB)', 'CPU (%)']
        
        # Group rows by method
        grouped_by_method = rows.group_by { |row| row['method'] }
        
        # Add entire_file results first
        grouped_by_method['entire_file']&.sort_by { |row| row['language'] }&.each do |row|
          table << [
            row['language'],
            row['method'],
            format('%.2f', row['duration_ms'].to_f),
            format('%.2f', row['memory_mb'].to_f),
            format('%.1f', row['cpu_percent'].to_f)
          ]
        end
        
        # Add separator between methods
        table.add_separator
        
        # Add line_by_line results
        grouped_by_method['line_by_line']&.sort_by { |row| row['language'] }&.each do |row|
          table << [
            row['language'],
            row['method'],
            format('%.2f', row['duration_ms'].to_f),
            format('%.2f', row['memory_mb'].to_f),
            format('%.1f', row['cpu_percent'].to_f)
          ]
        end
      end
      puts results_table
      print_performance_comparison(rows)
    end
  end

  def print_performance_comparison(rows)
    puts "\nPerformance Comparison:"
    
    # Group by method
    rows.group_by { |row| row['method'] }.each do |method, results|
      puts "\n#{method.capitalize}:"
      
      # Sort by duration for ranking
      sorted = results.sort_by { |row| row['duration_ms'].to_f }
      fastest = sorted.first
      
      sorted.each do |result|
        duration = result['duration_ms'].to_f
        memory = result['memory_mb'].to_f
        cpu = result['cpu_percent'].to_f
        
        if result == fastest
          comparison = "🏆 Fastest"
        else
          diff_percent = ((duration - fastest['duration_ms'].to_f) / fastest['duration_ms'].to_f * 100).round(1)
          comparison = "#{diff_percent}% slower"
        end
        
        puts "  #{result['language']}: #{format('%.2f', duration)}ms (#{comparison})"
        puts "    Memory: #{format('%.2f', memory)}MB"
        puts "    CPU: #{format('%.1f', cpu)}%"
      end
    end
  end

  def print_detailed_comparison
    puts "\n=== Overall Statistics ==="
    
    grouped_results.each do |filename, rows|
      first_row = rows.first
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
  end
end

if __FILE__ == $PROGRAM_NAME
  if !File.exist?(ARGV[0])
    puts "Error: #{ARGV[0]} not found!"
    exit 1
  end
  
  BenchmarkAnalyzer.new.call
end
