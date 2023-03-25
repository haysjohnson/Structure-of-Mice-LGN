function [xrs, tFlip, firstStimFlip] = resampleToFlipTimeTrial(x, tx, tFlip, p)

    x = double(x);
    x = x(:)';
    tx = tx(:)';
    tFlip = tFlip(:)';
    
    if nargin == 3
        p = 1;
    end
    p = round(p);
    
    if p > 1
        % upsample x by p
        nPad = 10;
        xp = [ones(1,nPad)*x(1) x ones(1,nPad)*x(end)];
        txp = (0 : length(xp)-1);
        
        xpus = resample(xp, p, 1);
        dtus = 1/p;
        txpus = (0 : length(xpus)-1) * dtus;
        
        xus = xpus(nPad*p+1 : end-(nPad*p+(p-1)));       
        txus = (0 : length(xus)-1) * dtus;
                
%         figure(1);
%         clf;
%         
%         plotLoc(2,2,1,1);
%         hold on
%         plot(txp, xp, '-*');
%         plot(txpus, xpus, '-');
% 
%         plotLoc(2,2,2,1);
%         hold on
%         plot(0:length(x)-1, x, '-*');
%         plot(txus, xus, '-');
        
        txus(1 : p : end) = tx;
        for jj = 2 : p : length(txus)-1
            txus(jj : jj+p-2) = txus(jj-1) + (1 : p-1)*(txus(jj-1+p) - txus(jj-1))/p;
        end
    else
        xus = x;
        txus = tx;
    end
    
%     plotLoc(2,2,1,2);
%     hold on
%     plot(tx, x, '-*');
%     plot(txus, xus, '-');

    stimFrameIntervalSec = mean(diff(tFlip));
    firstStimFlip = 1;
    if tFlip(1) >= txus(1)
        tBefore = fliplr(tFlip(1)-stimFrameIntervalSec : -stimFrameIntervalSec : txus(1));
        if ~isempty(tBefore)
            firstStimFlip = length(tBefore)+1;
        end   
    else
        tBefore = [];
    end
    if txus(end) > tFlip(end)
        tAfter = tFlip(end)+stimFrameIntervalSec : stimFrameIntervalSec : txus(end);
    else
        tAfter = [];
    end
    tFlip = [tBefore tFlip tAfter];
    xrs = interp1(txus, xus, tFlip);
    
%     dco(4);
%     plot([tBefore tFlip tAfter], xrs, '.', 'MarkerSize', 10);
end
