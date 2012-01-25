% Compiles the code under MacOS or Linux
% add -largeArrayDims on 64-bit machines

cd ./features
mex -largeArrayDims -lm -O c_cmibsm.c
cd ../util/libsvm/
mex -O -largeArrayDims -I../ -c svm.cpp
mex -O -largeArrayDims -I../ -c svm_model_matlab.c
mex -O -largeArrayDims -I../ svmtrain.c svm.o svm_model_matlab.o
mex -O -largeArrayDims -I../ svmpredict.c svm.o svm_model_matlab.o
mex -O -largeArrayDims libsvmread.c
mex -O -largeArrayDims libsvmwrite.c