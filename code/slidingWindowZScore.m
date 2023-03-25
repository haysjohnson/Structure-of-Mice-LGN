function FNorm = slidingWindowZScore(e, FRaw, winTrialsOnEitherSide)

    FRaw = single(FRaw);
    
    if nargin < 3
        winTrialsOnEitherSide = 0;
    end
    
    if winTrialsOnEitherSide == 0
        FNorm = (FRaw - mean(FRaw)) / std(FRaw);
        return;
    end
    
    FNorm = zeros(size(FRaw));
    for ti = 1 : length(e)
        ti0 = ti - winTrialsOnEitherSide;
        if ti0 < 1
            ti0 = 1;
        end
        ti1 = ti + winTrialsOnEitherSide;
        if ti1 > length(e)
            ti1 = length(e);
        end
        k0 = e(ti0).firstFrameRS;
        k1 = e(ti1).lastFrameRS;
        i0 = e(ti).firstFrameRS;
        i1 = e(ti).lastFrameRS;
        FNorm(i0:i1) = (FRaw(i0:i1) - mean(FRaw(k0:k1))) / std(FRaw(k0:k1));
    end
end
