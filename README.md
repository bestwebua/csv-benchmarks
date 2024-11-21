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
Reading entire file: 34.26 ms (Memory: 39.16 MB, CPU: 4.7%)
Reading line by line: 22.59 ms (Memory: 0.42 MB, CPU: 2.4%)

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
Reading entire file: 329.24 ms (Memory: 28.24 MB, CPU: 32.8%)
Reading line by line: 258.19 ms (Memory: 0.27 MB, CPU: 25.8%)


Benchmarks completed!

===== Overall Statistics =======

File: tmp_input.csv
Size: 25.18MB
Rows: 40000
Columns: 20

Go 1.23.0 Statistics:
  entire_file:
    Duration: 34.26ms
    Memory: 39.16MB
    CPU: 4.7%
  line_by_line:
    Duration: 22.59ms
    Memory: 0.42MB
    CPU: 2.4%

Ruby 3.3.5 Statistics:
  entire_file:
    Duration: 329.24ms
    Memory: 28.24MB
    CPU: 32.8%
  line_by_line:
    Duration: 258.19ms
    Memory: 0.27MB
    CPU: 25.8%

==== Performance Comparison ====

Entire_file:
  Go 1.23.0: 34.26ms (🏆 Fastest)
    Memory: 39.16MB
    CPU: 4.7%
  Ruby 3.3.5: 329.24ms (9.61x slower)
    Memory: 28.24MB
    CPU: 32.8%

Line_by_line:
  Go 1.23.0: 22.59ms (🏆 Fastest)
    Memory: 0.42MB
    CPU: 2.4%
  Ruby 3.3.5: 258.19ms (11.43x slower)
    Memory: 0.27MB
    CPU: 25.8%
```

## Contributing

Bug reports and pull requests are welcome on GitHub at <https://github.com/bestwebua/csv-benchmarks>. Please check the [open tickets](https://github.com/bestwebua/csv-benchmarks/issues).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Credits

- [The Contributors](https://github.com/bestwebua/csv-benchmarks/graphs/contributors) for code and awesome suggestions
- [The Stargazers](https://github.com/bestwebua/csv-benchmarks/stargazers) for showing their support
