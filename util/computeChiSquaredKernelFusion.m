
function [kernelMatrix Aout1 Aout2]=computeChiSquaredKernelFusion(data1, training_data1, data2, training_data2, w1, w2, A1, A2)
%
% Function that applies chi-squared kernel to data, given training_data.
% This function computes the kernel by combining two kind of features
% (data1 and data2) in a weighted way (w1, w2).
% Input:  data is the training/testing data, depending on the stage
%         training_data is the data used to train the SVM. 
% Output: kernelMatrix is the matrix of distances to pass to libSVM
%
% Chi-Squared kernel K(a,b) is based on the paper "Local Features and 
% Kernels for Classication of Texture and Object Categories: A Comprehensive
% study" by Zhang et % al. following this equations
%
% K(a,b) = exp(-D(a,b)/A) is the kernel function
% D(a,b) = 1/2 * sum((a-b).^2 / (a+b)) is the chi-square distance between
%                                      histograms a and b

kernelMatrix = zeros(size(data1,1), size(training_data1,1));
tempMatrix = zeros(size(data1,1), size(training_data1,1));

parfor i=1:size(data1,1)
    sample = repmat(data1(i,:),size(training_data1,1),1);
    hInters = ((sample-training_data1).^2)./(sample+training_data1+1e-8);
    equalFeatures = (sample ~= training_data1);
    histIntersections = zeros(size(sample));
    histIntersections = histIntersections + equalFeatures.*hInters;
    dist = 0.5*sum(histIntersections, 2);
    tempMatrix(i,:) = dist;
end

parfor i=1:size(data2,1)   
    sample = repmat(data2(i,:),size(training_data2,1),1);
    hInters = ((sample-training_data2).^2)./(sample+training_data2+1e-8);
    equalFeatures = (sample ~= training_data2);
    histIntersections = zeros(size(sample));
    histIntersections = histIntersections + equalFeatures.*hInters;
    dist = 0.5*sum(histIntersections, 2);
    kernelMatrix(i,:) = dist;
end

% Set normalization factor to the mean chi-square distance, as done in
% Sande et al. on color descriptors
if nargin<7
	    A1 = mean(tempMatrix(:));
    A2 = mean(kernelMatrix(:));
end

kernelMatrix = exp(-(w1*(tempMatrix/A1)+w2*(kernelMatrix/A2)));

if nargout>1
    Aout1 = A1;
	Aout2 = A2;
end