# CSV Benchmark: Ruby vs Go

This project benchmarks CSV file reading performance between Ruby and Go implementations. It measures and compares:

- Reading entire file at once
- Reading line by line
- Duration
- Memory usage
- CPU utilization

## Prerequisites

### Ruby

- Ruby 3.3.5
- Go 1.23

## Usage

### Install dependencies
```bash
bundle install
go mod tidy
```

### Run benchmarks

#### With default dummy CSV file

```bash
./run_benchmarks.sh
```

#### Build custom dummy CSV file

```bash
# ruby tools/csv_file_generator.rb <filename> <rows> <columns>

ruby tools/csv_file_generator.rb custom_test.csv 10000 10
```

#### Run benchmarks with custom CSV file/files

```bash
# ./run_benchmarks.sh <filename1> <filename2> <filename3>

./run_benchmarks.sh custom_test_1.csv custom_test_2.csv custom_test_3.csv
```

### The results

```bash
No input files provided. Generating tmp_input.csv with 40000 rows and 20 columns...

Benchmarking tmp_input.csv...

Running benchmarks (3 runs)...
  Entire file run 1/3
  Entire file run 2/3
  Entire file run 3/3
  Line by line run 1/3
  Line by line run 2/3
  Line by line run 3/3

Go CSV Benchmarks (Go 1.23.0):
File: tmp_input.csv
File size: 25.18 MB
Row count: 40000
Column count: 20
Reading entire file: 33.64 ms (Memory: 39.16 MB, CPU: 4.6%)
Reading line by line: 23.18 ms (Memory: 0.44 MB, CPU: 2.5%)

Running benchmarks (3 runs)...
  Entire file run 1/3
  Entire file run 2/3
  Entire file run 3/3
  Line by line run 1/3
  Line by line run 2/3
  Line by line run 3/3

Ruby CSV Benchmarks (Ruby 3.3.5):
File: tmp_input.csv
File size: 25.18 MB
Row count: 40000
Column count: 20
Reading entire file: 329.86 ms (Memory: 28.12 MB, CPU: 32.9%)
Reading line by line: 263.56 ms (Memory: 0.31 MB, CPU: 26.3%)


Benchmarks completed!

=================================
|| File Analysis ||
|| Filename      || tmp_input.csv ||
|| File size     || 25.18 MB      ||
|| Rows          || 40000         ||
|| Columns       || 20            ||
=================================
+------------+--------------+---------------+-------------+---------+
| Language   | Method       | Duration (ms) | Memory (MB) | CPU (%) |
+------------+--------------+---------------+-------------+---------+
| Go 1.23.0  | entire_file  | 33.64         | 39.16       | 4.6     |
| Ruby 3.3.5 | entire_file  | 329.86        | 28.12       | 32.9    |
+------------+--------------+---------------+-------------+---------+
| Go 1.23.0  | line_by_line | 23.18         | 0.44        | 2.5     |
| Ruby 3.3.5 | line_by_line | 263.56        | 0.31        | 26.3    |
+------------+--------------+---------------+-------------+---------+

Performance Comparison:

Entire_file:
  Go 1.23.0: 33.64ms (🏆 Fastest)
    Memory: 39.16MB
    CPU: 4.6%
  Ruby 3.3.5: 329.86ms (9.81x slower)
    Memory: 28.12MB
    CPU: 32.9%

Line_by_line:
  Go 1.23.0: 23.18ms (🏆 Fastest)
    Memory: 0.44MB
    CPU: 2.5%
  Ruby 3.3.5: 263.56ms (11.37x slower)
    Memory: 0.31MB
    CPU: 26.3%

=== Overall Statistics ===

File: tmp_input.csv
Size: 25.18MB
Rows: 40000
Columns: 20

Go 1.23.0 Statistics:
  entire_file:
    Duration: 33.64ms
    Memory: 39.16MB
    CPU: 4.6%
  line_by_line:
    Duration: 23.18ms
    Memory: 0.44MB
    CPU: 2.5%

Ruby 3.3.5 Statistics:
  entire_file:
    Duration: 329.86ms
    Memory: 28.12MB
    CPU: 32.9%
  line_by_line:
    Duration: 263.56ms
    Memory: 0.31MB
    CPU: 26.3%
```

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/bestwebua/csv-benchmarks>. Please check the [open tickets](https://github.com/bestwebua/csv-benchmarks/issues).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Credits

- [The Contributors](https://github.com/bestwebua/csv-benchmarks/graphs/contributors) for code and awesome suggestions
- [The Stargazers](https://github.com/bestwebua/csv-benchmarks/stargazers) for showing their support
