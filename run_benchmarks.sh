#!/bin/bash

# If no arguments provided, generate test CSV file
TEST_CSV="tmp_input.csv"
RESULTS_CSV="tmp_benchmark_results.csv"

if [ $# -eq 0 ]; then
    echo "No input files provided. Generating $TEST_CSV with 40000 rows and 20 columns..."
    ruby tools/csv_file_generator.rb "$TEST_CSV" 40000 20
    CSV_FILES=("$TEST_CSV")
else
    CSV_FILES=("$@")
fi

# Create fresh results file with headers
echo "language,method,filename,rows,columns,file_size_mb,duration_ms,memory_mb,cpu_percent" > "$RESULTS_CSV"

# Run benchmarks for each input file
for CSV_FILE in "${CSV_FILES[@]}"; do
    echo -e "\nBenchmarking $CSV_FILE..."
    
    # Run Go benchmark and capture metadata
    GO_OUTPUT=$(go run main.go "$CSV_FILE" "$RESULTS_CSV")
    METADATA=$(echo "$GO_OUTPUT" | grep "^METADATA:" || echo "")
    echo "$GO_OUTPUT" | grep -v "^METADATA:"

    # Run Ruby benchmark with metadata
    ruby main.rb "$CSV_FILE" "$METADATA" "$RESULTS_CSV"
done

echo -e "\nBenchmarks completed!"
ruby tools/analyze_results.rb "$RESULTS_CSV"
if [ $# -eq 0 ]; then
    rm -f "$TEST_CSV"
fi
rm -f "$RESULTS_CSV"
