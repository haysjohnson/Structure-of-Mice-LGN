function [avgRawLamWeighted, xROIBoundry, yROIBoundry] = computeFLamWeighted(roiIndex, f, stat, somaCropFlag, includeOverlapFlag, noLamFlag)

%     somaCropFlag = false;
%     includeOverlapFlag = false;
%     noLamFlag = false;
    if somaCropFlag && includeOverlapFlag
        k = stat{roiIndex}.soma_crop;
    elseif ~somaCropFlag && includeOverlapFlag
        k = true(size(stat{roiIndex}.soma_crop));
    elseif somaCropFlag && ~includeOverlapFlag
        k = stat{roiIndex}.soma_crop & ~stat{roiIndex}.overlap;
    elseif ~somaCropFlag && ~includeOverlapFlag
        % This is default F
        k = ~stat{roiIndex}.overlap;
    end
    x = double(stat{roiIndex}.xpix(k)+1)';
    y = double(stat{roiIndex}.ypix(k)+1)';
    lam = double(stat{roiIndex}.lam(k));
    if noLamFlag
        % do not weigth flourescence
        lam = ones(size(lam));
    end
    B = boundary(x,y);
    xROIBoundry = x(B);
    yROIBoundry = y(B);
%     plotLoc(3,3,1,2);
%     plot(xROIBoundry, yROIBoundry, 'g');
    
    avgRawLamWeighted = zeros(1,size(f,3));
    for k = 1 : length(x)
        avgRawLamWeighted = avgRawLamWeighted + lam(k) * double(squeeze(f(y(k),x(k),:)))';
    end
    avgRawLamWeighted = avgRawLamWeighted / sum(lam);
    avgRawLamWeighted = single(avgRawLamWeighted);
end
