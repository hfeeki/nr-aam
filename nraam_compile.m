% add -largeArrayDims on 64-bit machines

cd ./features
mex -largeArrayDims -lm -O c_cmibsm.c
cd ..