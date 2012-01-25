function computeDescriptorsNicIcon(imsize,K,infA,samples,WID,normInFunction)

path = 'D:\MATLAB\Datasets\NicIcon';
load(fullfile(path,['nicicon' WID num2str(imsize) '.mat']));
numK = K*K;
numImTr=0;
numImVal=0;
numImTe=0;

for i=1:length(Itrain)
	numImTr = numImTr + length(Itrain{i});
end
for i=1:length(Ival)
	numImVal = numImVal + length(Ival{i});
end
for i=1:length(Itest)
	numImTe = numImTe + length(Itest{i});
end

descriptorsTr = zeros(numImTr,numK);
descriptorsVal = zeros(numImVal,numK);
descriptorsTe = zeros(numImTe,numK);
initialPositionsTr = zeros(numImTr,numK*2);
initialPositionsVal = zeros(numImVal,numK*2);
initialPositionsTe = zeros(numImTe,numK*2);
labelsTr = zeros(numImTr,1);
labelsVal = zeros(numImVal,1);
labelsTe = zeros(numImTe,1);

fprintf('Computing descriptors for K=%d, infA=%1.1f and norm=%d. Please wait...\n',K,infA,normInFunction);
count = 1;

for i=1:length(Itrain)
	for j=1:length(Itrain{i})
		[descriptorsTr(count,:),initialPositionsTr(count,:)] = cmibsm(Itrain{i}{j}, K, infA, normInFunction);
		labelsTr(count) = i;
		count = count+1;
	end
end
count = 1;
for i=1:length(Ival)
	for j=1:length(Ival{i})
		[descriptorsVal(count,:),initialPositionsVal(count,:)] = cmibsm(Ival{i}{j}, K, infA, normInFunction);
		labelsVal(count) = i;
		count = count+1;
	end
end
count = 1;
for i=1:length(Itest)
	for j=1:length(Itest{i})
		[descriptorsTe(count,:),initialPositionsTe(count,:)] = cmibsm(Itest{i}{j}, K, infA, normInFunction);
		labelsTe(count) = i;
		count = count+1;
	end
end

[~,~,~,H,~] = cmibsm(Itest{1}{1}, K, infA, 0);

% Normalizing coordinates with image size.
% H and W have the same value in the case of the NicIcon
% so it is not necessary to normalize separately
initialPositionsTr = initialPositionsTr / H;
initialPositionsVal = initialPositionsVal / H;
initialPositionsTe = initialPositionsTe / H;

% for i=1:numImTr
% 	iP = reshape(initialPositionsTr(i,:),2,numK)';
% 	iP(:,1) = iP(:,1)/W;
% 	iP(:,2) = iP(:,2)/H;
% 	initialPositionsTr(i,:) = reshape(iP',1,numK*2);
% end
% for i=1:numImVal
% 	iP = reshape(initialPositionsVal(i,:),2,numK)';
% 	iP(:,1) = iP(:,1)/W;
% 	iP(:,2) = iP(:,2)/H;
% 	initialPositionsVal(i,:) = reshape(iP',1,numK*2);
% end
% for i=1:numImTe
% 	iP = reshape(initialPositionsTe(i,:),2,numK)';
% 	iP(:,1) = iP(:,1)/W;
% 	iP(:,2) = iP(:,2)/H;
% 	initialPositionsTe(i,:) = reshape(iP',1,numK*2);
% end

save(samples,'descriptorsTr', 'initialPositionsTr', 'labelsTr', ...
	'descriptorsVal', 'initialPositionsVal', 'labelsVal', ...
	'descriptorsTe', 'initialPositionsTe', 'labelsTe', ...
	'numImTr', 'numImVal', 'numImTe');

end