
#!/bin/bash

echo "Compiling..."
make

echo "Creating output directory..."
mkdir -p output

echo "Running edge detection and restoration..."
./signal_processing > log.txt

echo "Done. Output saved in output/ and log.txt"
