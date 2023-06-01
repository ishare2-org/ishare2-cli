#!/usr/bin/env python3
import csv
import os

def checkFilesIntegrity(path, filename):
    file_path = os.path.join(path, filename)

    # Check if the file exists
    if not os.path.exists(file_path):
        return False

    # Check if the file is empty
    if os.path.getsize(file_path) == 0:
        return False

    # Check if the file content is a valid CSV
    with open(file_path, 'r') as file:
        try:
            csv_reader = csv.reader(file)
            for row in csv_reader:
                # Check if each row has at least 4 columns
                if len(row) < 4:
                    return False

            # Check if the number of rows is at least 5
            file.seek(0)  # Reset file pointer to the beginning
            num_rows = sum(1 for _ in csv_reader)
            if num_rows < 5:
                return False

        except csv.Error:
            return False

    # All checks passed, file is valid
    return True
