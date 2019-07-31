#!/bin/bash

#make refs and reads a variables

./repeatprof clean

echo "default"
./repeatprof profile -p ../../RP_data/BeetleReads/ ../../RP_data/BeetleReads/
mv *RepeatProfiler* beetles-default
./repeatprof clean

echo "very-sensitive"
./repeatprof profile -p ../../RP_data/BeetleReads/ ../../RP_data/BeetleReads/ --very-sensitive
mv *RepeatProfiler* beetles-very-sensitive
./repeatprof clean

echo "sensitive"
./repeatprof profile -p ../../RP_data/BeetleReads/ ../../RP_data/BeetleReads/ --sensitive
mv *RepeatProfiler* beetles-sensitive
./repeatprof clean

echo "fast"
./repeatprof profile -p ../../RP_data/BeetleReads/ ../../RP_data/BeetleReads/ --fast
mv *RepeatProfiler* beetles-fast
./repeatprof clean

echo "very-fast"
./repeatprof profile -p ../../RP_data/BeetleReads/ ../../RP_data/BeetleReads/ --very-fast
mv *RepeatProfiler* beetles-very-fast
./repeatprof clean

echo "local"
./repeatprof profile -p ../../RP_data/BeetleReads/ ../../RP_data/BeetleReads/ --local
mv *RepeatProfiler* beetles-local
./repeatprof clean

echo "very-sensitive-local"
./repeatprof profile -p ../../RP_data/BeetleReads/ ../../RP_data/BeetleReads/ --very-sensitive-local
mv *RepeatProfiler* beetles-very-sensitive-local
./repeatprof clean

echo "sensitive-local"
./repeatprof profile -p ../../RP_data/BeetleReads/ ../../RP_data/BeetleReads/ --sensitive-local
mv *RepeatProfiler* beetles-sensitive-local
./repeatprof clean

echo "fast-local"
./repeatprof profile -p ../../RP_data/BeetleReads/ ../../RP_data/BeetleReads/ --fast-local
mv *RepeatProfiler* beetles-fast-local
./repeatprof clean

echo "very-fast-local"
./repeatprof profile -p ../../RP_data/BeetleReads/ ../../RP_data/BeetleReads/ --very-fast-local
mv *RepeatProfiler* beetles-very-fast-local
./repeatprof clean
