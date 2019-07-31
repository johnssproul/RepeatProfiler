#!/bin/bash

cd /Volumes/SamsungUSB/RP_test/Validation_310719/

refPath='../../RP_data/BeetleReads/'
readsPath='../../RP_data/BeetleReads/'

./repeatprof clean

echo "default"
./repeatprof profile -p $refPath $readsPath
mv *RepeatProfiler* beetles-default
./repeatprof clean

echo "very-sensitive"
./repeatprof profile -p $refPath $readsPath --very-sensitive
mv *RepeatProfiler* beetles-very-sensitive
./repeatprof clean

echo "sensitive"
./repeatprof profile -p $refPath $readsPath --sensitive
mv *RepeatProfiler* beetles-sensitive
./repeatprof clean

echo "fast"
./repeatprof profile -p $refPath $readsPath --fast
mv *RepeatProfiler* beetles-fast
./repeatprof clean

echo "very-fast"
./repeatprof profile -p $refPath $readsPath --very-fast
mv *RepeatProfiler* beetles-very-fast
./repeatprof clean

echo "local"
./repeatprof profile -p $refPath $readsPath --local
mv *RepeatProfiler* beetles-local
./repeatprof clean

echo "very-sensitive-local"
./repeatprof profile -p $refPath $readsPath --very-sensitive-local
mv *RepeatProfiler* beetles-very-sensitive-local
./repeatprof clean

echo "sensitive-local"
./repeatprof profile -p $refPath $readsPath --sensitive-local
mv *RepeatProfiler* beetles-sensitive-local
./repeatprof clean

echo "fast-local"
./repeatprof profile -p $refPath $readsPath --fast-local
mv *RepeatProfiler* beetles-fast-local
./repeatprof clean

echo "very-fast-local"
./repeatprof profile -p $refPath $readsPath --very-fast-local
mv *RepeatProfiler* beetles-very-fast-local
./repeatprof clean
