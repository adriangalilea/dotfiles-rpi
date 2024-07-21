#!/usr/bin/env bash
# test_ex.sh - Test script for the ex command
# Author: Assistant
# Created: July 21, 2024
# Last Modified: July 21, 2024
#
# Description:
# This script creates various types of archive files and tests the ex command's
# ability to extract them correctly.

set -e  # Exit immediately if a command exits with a non-zero status.

# Function to create a test file
create_test_file() {
    echo "This is a test file for $1 archive." > test_file.txt
}

# Function to clean up test files
cleanup() {
    rm -f test_file.txt test_archive* extracted_file.txt
}

# Function to run a test
run_test() {
    local archive_type=$1
    local create_command=$2
    local expected_content=$3

    echo "Testing $archive_type extraction..."
    cleanup  # Clean up before each test
    create_test_file "$archive_type"
    eval "$create_command"
    rm test_file.txt
    ex test_archive.$archive_type
    
    # For bz2, gz, and xz, the extracted file will have the same name as the archive without the extension
    case "$archive_type" in
        bz2|gz|xz)
            mv test_archive extracted_file.txt
            ;;
        *)
            mv test_file.txt extracted_file.txt
            ;;
    esac

    if [ -f extracted_file.txt ] && grep -q "$expected_content" extracted_file.txt; then
        echo "  ✓ $archive_type test passed."
    else
        echo "  ✗ $archive_type test failed!"
        if [ -f extracted_file.txt ]; then
            echo "    Content of extracted file:"
            cat extracted_file.txt
        else
            echo "    Extracted file not found!"
        fi
    fi
    cleanup
}

# Test .tar.gz
run_test "tar.gz" "tar czf test_archive.tar.gz test_file.txt" "test file for tar.gz archive"

# Test .zip
run_test "zip" "zip test_archive.zip test_file.txt" "test file for zip archive"

# Test .bz2
run_test "bz2" "bzip2 -c test_file.txt > test_archive.bz2" "test file for bz2 archive"

# Test .gz
run_test "gz" "gzip -c test_file.txt > test_archive.gz" "test file for gz archive"

# Test .xz
run_test "xz" "xz -c test_file.txt > test_archive.xz" "test file for xz archive"

# Test .rar (if rar command is available)
if command -v rar &> /dev/null; then
    run_test "rar" "rar a test_archive.rar test_file.txt" "test file for rar archive"
else
    echo "rar command not found, skipping .rar test"
fi

# Test .7z (if 7z command is available)
if command -v 7z &> /dev/null; then
    run_test "7z" "7z a test_archive.7z test_file.txt" "test file for 7z archive"
else
    echo "7z command not found, skipping .7z test"
fi

echo "All tests completed."
