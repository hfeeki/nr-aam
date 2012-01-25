function [iniPos,imCentroids] = calculateInitialPositions(cl, ml, im, imCentroids, imSubReg)

% This function computes the initial position of the focuses using a
% partition algorithm based on centroids

drawFlag = 0;
iniPos = zeros(4^cl*2,1);
imSubReg2 = zeros(4^(cl+1),4);

for i=1:4^cl
    sr = imSubReg(i,:);
    [r,c] = find(im(sr(1):sr(3),sr(2):sr(4))~=0);
    
    
    if (length(r)<=3)
        yc = round((sr(3)-sr(1))/2);
        xc = round((sr(4)-sr(2))/2);
    else
        yc = round(sum(r)/length(r));
        xc = round(sum(c)/length(c));
    end
    if yc == 0
        a = 1;
    end
    yc = yc + sr(1)-1;
    xc = xc + sr(2)-1;
    if yc == 0
        yL = 1;
    else
        yL = yc;
    end
    yR = yc+1;
    if xc == 0
        xL = 1;
    else
        xL = xc;
    end
    xR = xc+1;
    iniPos((i-1)*2+1:(i-1)*2+2) = [xc yc];
    imSubReg2((i-1)*4+1,:) = [sr(1),sr(2),yL,xL];
    imSubReg2((i-1)*4+2,:) = [sr(1),xR,yL,sr(4)];
    imSubReg2((i-1)*4+3,:) = [yR,sr(2),sr(3),xL];
    imSubReg2((i-1)*4+4,:) = [yR,xR,sr(3),sr(4)];
    if drawFlag
        % 		if mod(cl,4) == 0
        % 			color = 'b';
        % 		elseif mod(cl,4) == 1
        % 			color = 'g';
        % 		elseif mod(cl,4) == 2
        % 			color = 'magenta';
        % 		else
        % 			color = 'cyan';
        % 		end
        color = 'black';
        if cl == ml
            line([sr(2) sr(4)],[yc yc],'Color',color,'LineStyle',':','LineWidth',3);
            line([xc xc],[sr(1) sr(3)],'Color',color,'LineStyle',':','LineWidth',3);
        else
            line([sr(2) sr(4)],[yc yc],'Color',color,'LineStyle','-','LineWidth',3);
            line([xc xc],[sr(1) sr(3)],'Color',color,'LineStyle','-','LineWidth',3);
        end
        line([xc xc],[yc yc],'Color',color,'Marker','.','MarkerSize',20);
    end
end

imCentroids(length(imCentroids)+1:length(imCentroids)+length(iniPos)) = iniPos;
if cl == ml
    return
else
    [iniPos,imCentroids] = calculateInitialPositions(cl+1, ml, im, imCentroids, imSubReg2);
end
return
end

