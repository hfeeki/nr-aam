function [v,iniPos,imCentroids,H,W] = cmibsm(im, k, infA, norm)

% This function computes the nrBSM method for a given image [im] using
% k*k number of focuses and a influence area set by [infA]

[H,W] = size(im);

dh = mod(H,k);
dw = mod(W,k);
if (dh~=0 || dw~=0)
	newH = H;
	newW = W;
	if (dh~=0)
		newH = newH + (k-dh);
	end
	if (dw~=0)
		newW = newW + (k-dw);
    end
	newIm = imresize(im, [newH, newW]);
	[v,iniPos,imCentroids,H,W]=cmibsm(newIm, k, infA, norm);
	return;
end

maxLevel = log2(k);
if mod(maxLevel,1)~=0
	fprintf('Error. The number of focuses selected is incorrect.\nk must be equal to 2^n where n is an integer.\n\n');
	v = NaN;
	iniPos = NaN;
	imCentroids = NaN;
	return;
end

[iniPos,imCentroids] = calculateInitialPositions(0, maxLevel, im, [], [1,1,H,W]);
v=c_cmibsm(double(im'), iniPos, H, W, k, infA, norm);
end