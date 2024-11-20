package main

import (
	"encoding/csv"
	"fmt"
	"os"
	"path/filepath"
	"runtime"
	"syscall"
	"time"
)

func getMemoryUsage() float64 {
	var m runtime.MemStats
	runtime.ReadMemStats(&m)
	return float64(m.Alloc) / 1024 / 1024
}

func getCPUTime() float64 {
	var rusage syscall.Rusage
	syscall.Getrusage(syscall.RUSAGE_SELF, &rusage)
	return float64(rusage.Utime.Sec+rusage.Stime.Sec) +
		float64(rusage.Utime.Usec+rusage.Stime.Usec)/1e6
}

func benchmarkReadFile(filename string) (time.Duration, float64, float64) {
	runtime.GC()
	memBefore := getMemoryUsage()
	cpuBefore := getCPUTime()

	start := time.Now()
	file, _ := os.Open(filename)
	defer file.Close()

	reader := csv.NewReader(file)
	reader.ReuseRecord = true
	_, _ = reader.ReadAll()

	memAfter := getMemoryUsage()
	cpuAfter := getCPUTime()
	return time.Since(start), memAfter - memBefore, cpuAfter - cpuBefore
}

func benchmarkReadFileLines(filename string) (time.Duration, float64, float64) {
	runtime.GC()
	memBefore := getMemoryUsage()
	cpuBefore := getCPUTime()

	start := time.Now()
	file, _ := os.Open(filename)
	defer file.Close()

	reader := csv.NewReader(file)
	reader.ReuseRecord = true

	for {
		record, err := reader.Read()
		if err != nil {
			break
		}
		_ = record
	}

	memAfter := getMemoryUsage()
	cpuAfter := getCPUTime()
	return time.Since(start), memAfter - memBefore, cpuAfter - cpuBefore
}

func main() {
	if len(os.Args) < 3 {
		fmt.Println("Usage: go run main.go <csv_file> <results_csv>")
		os.Exit(1)
	}
	filename := os.Args[1]
	resultsCsv := os.Args[2]

	file, _ := os.Open(filename)
	defer file.Close()

	// Get row and column counts
	lineCount := 0
	var columnCount int
	scanner := csv.NewReader(file)

	// Read first row to get column count
	firstRow, _ := scanner.Read()
	columnCount = len(firstRow)
	lineCount++ // Count the header row

	// Count remaining rows
	for {
		_, err := scanner.Read()
		if err != nil {
			break
		}
		lineCount++
	}

	fileInfo, _ := file.Stat()
	fileSizeMB := float64(fileInfo.Size()) / (1024 * 1024)

	// Output metadata first for Ruby to consume
	fmt.Printf("METADATA:%d,%d,%.2f\n", lineCount, columnCount, fileSizeMB)

	// Run benchmarks multiple times
	runs := 3
	fmt.Printf("\nRunning benchmarks (%d runs)...\n", runs)

	// Update variables to include CPU
	var entireFileTimeTotal, entireFileMemoryTotal, entireFileCPUTotal float64
	var lineByLineTimeTotal, lineByLineMemoryTotal, lineByLineCPUTotal float64

	for i := 0; i < runs; i++ {
		fmt.Printf("  Entire file run %d/%d\n", i+1, runs)
		duration, memory, cpu := benchmarkReadFile(filename)
		entireFileTimeTotal += float64(duration.Microseconds()) / 1000
		entireFileMemoryTotal += memory
		entireFileCPUTotal += cpu * 100
	}

	for i := 0; i < runs; i++ {
		fmt.Printf("  Line by line run %d/%d\n", i+1, runs)
		duration, memory, cpu := benchmarkReadFileLines(filename)
		lineByLineTimeTotal += float64(duration.Microseconds()) / 1000
		lineByLineMemoryTotal += memory
		lineByLineCPUTotal += cpu * 100
	}

	// Calculate averages including CPU
	entireFileTime := entireFileTimeTotal / float64(runs)
	entireFileMemory := entireFileMemoryTotal / float64(runs)
	entireFileCPU := entireFileCPUTotal / float64(runs)

	lineByLineTime := lineByLineTimeTotal / float64(runs)
	lineByLineMemory := lineByLineMemoryTotal / float64(runs)
	lineByLineCPU := lineByLineCPUTotal / float64(runs)

	goVersion := "Go " + runtime.Version()[2:]
	filenameBase := filepath.Base(filename)

	// Print results to stdout
	fmt.Printf("\nGo CSV Benchmarks (%s):\n", goVersion)
	fmt.Printf("File: %s\n", filenameBase)
	fmt.Printf("File size: %.2f MB\n", fileSizeMB)
	fmt.Printf("Row count: %d\n", lineCount)
	fmt.Printf("Column count: %d\n", columnCount)
	fmt.Printf("Reading entire file: %.2f ms (Memory: %.2f MB, CPU: %.1f%%)\n",
		entireFileTime, entireFileMemory, entireFileCPU)
	fmt.Printf("Reading line by line: %.2f ms (Memory: %.2f MB, CPU: %.1f%%)\n\n",
		lineByLineTime, lineByLineMemory, lineByLineCPU)

	f, _ := os.OpenFile(resultsCsv, os.O_APPEND|os.O_CREATE|os.O_WRONLY, 0644)
	defer f.Close()

	writer := csv.NewWriter(f)
	defer writer.Flush()

	writer.Write([]string{
		goVersion,
		"entire_file",
		filenameBase,
		fmt.Sprintf("%d", lineCount),
		fmt.Sprintf("%d", columnCount),
		fmt.Sprintf("%.2f", fileSizeMB),
		fmt.Sprintf("%.2f", entireFileTime),
		fmt.Sprintf("%.2f", entireFileMemory),
		fmt.Sprintf("%.1f", entireFileCPU),
	})
	writer.Write([]string{
		goVersion,
		"line_by_line",
		filenameBase,
		fmt.Sprintf("%d", lineCount),
		fmt.Sprintf("%d", columnCount),
		fmt.Sprintf("%.2f", fileSizeMB),
		fmt.Sprintf("%.2f", lineByLineTime),
		fmt.Sprintf("%.2f", lineByLineMemory),
		fmt.Sprintf("%.1f", lineByLineCPU),
	})
}
