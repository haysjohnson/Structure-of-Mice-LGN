function FFlip = resampleToFlipTime(F, e)

    p = 10;
    for ti = 1 : length(e)
        [FFlip(ti).F, FFlip(ti).t, FFlip(ti).firstStimIndex] = resampleToFlipTimeTrial(F(e(ti).firstFrameRS : e(ti).lastFrameRS), e(ti).frameTimesRS, e(ti).flipTimes, p);
    end

%     ti = 10;
%     figure(5);
%     clf;
%     plotLoc(1,1,1,1);
%     plot(e(ti).frameTimesRS, F(e(ti).firstFrameRS : e(ti).lastFrameRS));
%     dco(1);
%     plot(e(ti).frameTimesRS, F(e(ti).firstFrameRS : e(ti).lastFrameRS), '.', 'MarkerSize', 20);
%     plot(FFlip(ti).t, FFlip(ti).F, '.', 'MarkerSize', 10);
%     xline(FFlip(ti).t(FFlip(ti).firstStimIndex));
%     plot(e(ti).flipTimes, max(FFlip(ti).F), 'k.', 'MarkerSize', 10);
%     xx
end