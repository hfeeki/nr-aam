function model = train_nrAAMModel(samples, norm, K, infA, PCAparams, normInFunction)

load(samples);

% Output model
modelsEigenvFocuses = cell(1,length(Itrain));
modelsMeanFocuses = cell(1,length(Itrain));
modelsEigenvBsm = cell(1,length(Itrain));
modelsMeanBsm = cell(1,length(Itrain));
modelsEigenvB = cell(1,length(Itrain));
modelsMeanB = cell(1,length(Itrain));
normalizationBe = zeros(1,length(Itrain));
vectorNumEigF = zeros(length(Itrain),1);
vectorNumEigBSM = zeros(length(Itrain),1);
vectorNumEigB = zeros(length(Itrain),1);

% PCA parameters
percentEig = PCAparams.percentEig;

for symbol=1:length(Itrain)
	numTr = length(Itrain{symbol});
	focusesMatrix = zeros(numTr, K*K*2);
	bsmMatrix = zeros(numTr, K*K);
	
	for i=1:numTr
		im = Itrain{symbol}{i};
		[bsm,f,~,H,~] = cmibsm(im, K, infA, normInFunction);
		f = f'/H; % Because W and H have the same value
		if norm == 1
			f = f / sum(f);
			bsm = bsm / sum(bsm);
		elseif norm == 2
			f = f / sqrt(sum(f.^2));
			bsm = bsm / sqrt(sum(bsm.^2));
		elseif norm == 3
			f = sqrt(f / sum(f));
			bsm = sqrt(bsm / sum(bsm));
		end
		focusesMatrix(i,:) = f;
		bsmMatrix(i,:) = bsm;
	end
	% drawPlotsPCA(focusesMatrix, colors(symbol+1,:));
	
	
	[pc, score, latent] = princomp(focusesMatrix);
	if (percentEig ~= 0)
		fi = find(cumsum(latent)./sum(latent)>percentEig);
		vectorNumEigF(symbol) = fi(1);
	else
		vectorNumEigF(symbol) = PCAparams.numEigVF;
	end
	numEigVF = vectorNumEigF(symbol);
	Pf = zeros(numEigVF, K*K*2);
	Pf(:,:) = pc(:,1:numEigVF)';
	meanF = mean(focusesMatrix);
	[pc, score, latent] = princomp(bsmMatrix);
	if (percentEig ~= 0)
		fi = find(cumsum(latent)./sum(latent)>percentEig);
		vectorNumEigBSM(symbol) = fi(1);
	else
		vectorNumEigBSM(symbol) = PCAparams.numEigVBSM;
	end
	numEigVBSM = vectorNumEigBSM(symbol);
	Pe = zeros(numEigVBSM, K*K);
	Pe(:,:) = pc(:,1:numEigVBSM)';
	meanE = mean(bsmMatrix);
	
	modelsEigenvFocuses{symbol} = Pf;
	modelsMeanFocuses{symbol} = meanF;
	modelsEigenvBsm{symbol} = Pe;
	modelsMeanBsm{symbol} = meanE;
	
	bfMatrix = zeros(numTr, numEigVF);
	beMatrix = zeros(numTr, numEigVBSM);
	bfeMatrix = zeros(numTr, numEigVF+numEigVBSM);
	for i=1:numTr
		bfMatrix(i,:) = Pf*(focusesMatrix(i,:)-meanF)';
		beMatrix(i,:) = Pe*(bsmMatrix(i,:)-meanE)';
	end
	% drawPlotsPCA(bfMatrix, colors(symbol+1,:));
	
	vbf = var(bfMatrix(:));
	vbe = var(beMatrix(:));
	normalizationBe(symbol) = sqrt(vbf/vbe);
	bfeMatrix(:,1:numEigVF) = bfMatrix(:,:);
	bfeMatrix(:,numEigVF+1:numEigVF+numEigVBSM) = beMatrix(:,:)*normalizationBe(symbol);
	% bfeMatrix(:,1:numEigV) = bfMatrix(:,:);
	% bfeMatrix(:,numEigV+1:numEigV*2) = beMatrix(:,:);
	
	[pc, score, latent] = princomp(bfeMatrix);
	if (percentEig ~= 0)
		fi = find(cumsum(latent)./sum(latent)>percentEig);
		vectorNumEigB(symbol) = fi(1);
	else
		vectorNumEigB(symbol) = PCAparams.numEigVB;
	end
	numEigVB = vectorNumEigB(symbol);
	Pb = zeros(numEigVB, numEigVF+numEigVBSM);
	Pb(:,:) = pc(:,1:numEigVB)';
	meanB = mean(bfeMatrix);
	modelsEigenvB{symbol} = Pb;
	modelsMeanB{symbol} = meanB;
	
	aux = zeros(numTr, numEigVB);
	for i=1:numTr
		aux(i,:) = Pb*(bfeMatrix(i,:)-meanB)';
	end
	% drawPlotsPCA(aux, colors(symbol+1,:));
end

model = struct();
model.modelsEigenvFocuses = modelsEigenvFocuses;
model.modelsMeanFocuses = modelsMeanFocuses;
model.modelsEigenvBsm = modelsEigenvBsm;
model.modelsMeanBsm = modelsMeanBsm;
model.modelsEigenvB = modelsEigenvB;
model.modelsMeanB = modelsMeanB;
model.normalizationBe = normalizationBe;
model.vectorNumEigF = vectorNumEigF;
model.vectorNumEigBSM = vectorNumEigBSM;
model.vectorNumEigB = vectorNumEigB;

end