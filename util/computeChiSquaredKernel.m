
function [kernelMatrix Aout]=computeChiSquaredKernel(data, training_data, A)
%
% Function that applies chi-squared kernel to data, given training_data
% Input:  data is the training/testing data, depending on the stage
%         training_data is the data used to train the SVM
% Output: kernelMatrix is the matrix of distances to pass to libSVM
%
% Chi-Squared kernel K(a,b) is based on the paper "Local Features and 
% Kernels for Classication of Texture and Object Categories: A Comprehensive
% study" by Zhang et % al. following this equations
%
% K(a,b) = exp(-D(a,b)/A) is the kernel function
% D(a,b) = 1/2 * sum((a-b).^2 / (a+b)) is the chi-square distance between
%                                      histograms a and b

kernelMatrix = zeros(size(data,1), size(training_data,1));

parfor i=1:size(data,1)
%     display(['Processing sample ' num2str(i)])
    
    sample = repmat(data(i,:),size(training_data,1),1);
    hInters = ((sample-training_data).^2)./(sample+training_data+1e-8);
    equalFeatures = (sample ~= training_data);
    histIntersections = zeros(size(sample));
    histIntersections = histIntersections + equalFeatures.*hInters;
    dist = 0.5*sum(histIntersections, 2);
    kernelMatrix(i,:) = dist;
end

% Set normalization factor to the mean chi-square distance, as done in
% Sande et al. on color descriptors
if nargin<3
    A = mean(kernelMatrix(:));
end

kernelMatrix = exp(-kernelMatrix/A);

if nargout>1
    Aout = A;
end