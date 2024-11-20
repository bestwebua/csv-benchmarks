#!/usr/bin/env ruby
# frozen_string_literal: true

require 'benchmark'
require 'csv'
require 'get_process_mem'

class Main
  class << self
    def measure_cpu
      start_cpu = Process.times
      result = yield
      end_cpu = Process.times
      
      # Calculate total CPU time (user + system) in seconds
      cpu_time = (end_cpu.utime - start_cpu.utime) + (end_cpu.stime - start_cpu.stime)
      [result, cpu_time]
    end

    def measure_memory_and_cpu
      # Clear memory and run GC before measurement
      GC.start
      GC.compact if GC.respond_to?(:compact)
      sleep(0.1)
      
      memory_before = GetProcessMem.new.mb
      cpu_result = measure_cpu { yield }
      
      # Clear memory and run GC after measurement
      GC.start
      GC.compact if GC.respond_to?(:compact)
      sleep(0.1)
      
      memory_after = GetProcessMem.new.mb
      
      # Return operation result, memory delta, and CPU time
      [cpu_result[0], [memory_after - memory_before, 0].max, cpu_result[1]]
    end

    def benchmark_read_file(filename)
      measure_memory_and_cpu do
        time = Benchmark.measure do
          data = CSV.read(filename)
          GC.start
          data
        end
        time
      end
    end

    def benchmark_read_filelines(filename)
      measure_memory_and_cpu do
        time = Benchmark.measure do
          CSV.foreach(filename) do |row|
            row.map(&:to_s)
          end
          GC.start
        end
        time
      end
    end

    def benchmark
      filename = ARGV[0]
      metadata = ARGV[1]  # Expecting "METADATA:rows,columns,filesize"
      results_csv = ARGV[2]
      
      # Parse metadata from Go output
      row_count, column_count, file_size_mb = if metadata&.start_with?('METADATA:')
        metadata.sub('METADATA:', '').split(',').map { |v| v.to_f }
      else
        # Fallback to calculating if metadata not provided
        file_size_mb = File.size(filename).to_f / (1024 * 1024)
        first_row = CSV.read(filename, headers: true).headers
        [File.foreach(filename).count, first_row.length, file_size_mb]
      end
      
      # Run benchmarks multiple times to get more accurate results
      runs = 3
      puts "\nRunning benchmarks (#{runs} runs)..."
      
      entire_file_results = runs.times.map do |i|
        puts "  Entire file run #{i + 1}/#{runs}"
        benchmark_read_file(filename)
      end
      
      line_by_line_results = runs.times.map do |i|
        puts "  Line by line run #{i + 1}/#{runs}"
        benchmark_read_filelines(filename)
      end
      
      # Calculate averages including CPU time
      entire_file_time = entire_file_results.map { |r| r[0].real }.sum / runs * 1000
      entire_file_memory = entire_file_results.map { |r| r[1] }.sum / runs
      entire_file_cpu = entire_file_results.map { |r| r[2] }.sum / runs * 100
      
      line_by_line_time = line_by_line_results.map { |r| r[0].real }.sum / runs * 1000
      line_by_line_memory = line_by_line_results.map { |r| r[1] }.sum / runs
      line_by_line_cpu = line_by_line_results.map { |r| r[2] }.sum / runs * 100

      ruby_version = "Ruby #{RUBY_VERSION}"
      filename_base = File.basename(filename)
      
      # Print results to stdout
      puts "\nRuby CSV Benchmarks (#{ruby_version}):"
      puts "File: #{filename_base}"
      puts "File size: %.2f MB" % file_size_mb
      puts "Row count: #{row_count.to_i}"
      puts "Column count: #{column_count.to_i}"
      puts "Reading entire file: %.2f ms (Memory: %.2f MB, CPU: %.1f%%)" % [entire_file_time, entire_file_memory, entire_file_cpu]
      puts "Reading line by line: %.2f ms (Memory: %.2f MB, CPU: %.1f%%)" % [line_by_line_time, line_by_line_memory, line_by_line_cpu]
      puts "\n"
      
      # Record results to CSV
      CSV.open(results_csv, 'a') do |csv|
        csv << [
          ruby_version,
          'entire_file',
          filename_base,
          row_count.to_i,
          column_count.to_i,
          '%.2f' % file_size_mb,
          '%.2f' % entire_file_time,
          '%.2f' % entire_file_memory,
          '%.1f' % entire_file_cpu
        ]
        csv << [
          ruby_version,
          'line_by_line',
          filename,
          row_count.to_i,
          column_count.to_i,
          '%.2f' % file_size_mb,
          '%.2f' % line_by_line_time,
          '%.2f' % line_by_line_memory,
          '%.1f' % line_by_line_cpu
        ]
      end
    end
  end
end

if ARGV.empty?
  puts "Usage: ruby main.rb <csv_file> [metadata] <results_csv>"
  exit 1
else
  Main.benchmark
end
