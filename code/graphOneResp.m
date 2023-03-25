%% load files

clear all;

expFileName = '18X12-revcor4-2P-3X-Erik-AxonG-8442-28Sep2021-clean';

fn = expFileName;
disp(['Loading ' fn]);
load(fn);

fn = [expFileName '-ROI'];
disp(['Loading ' fn]);
load(fn);

fn = [expFileName '-Stim'];
disp(['Loading ' fn]);
load(fn);

%% general variables
% time variables
stimFrameIntervalSec = mean(diff(e(1).flipTimes));
tBeforeSec = -4;
tAfterSec = 4;
tBeforeSubtractMean = -2;

iBefore = round(tBeforeSec / stimFrameIntervalSec);
iAfter = round(tAfterSec / stimFrameIntervalSec);
x = (iBefore : iAfter) * stimFrameIntervalSec;
iBeforeSubtractMean = (-iBefore + round(tBeforeSubtractMean / stimFrameIntervalSec)) : -iBefore;
iBefore = cast(iBefore, 'int16');
iAfter = cast(iAfter, 'int16');
%% find 1 response
% specific trial vars
roi = 20;
trial = 144;
myPatch = 151;
whichPulse = 6;

% SET UP F : cut out raw fluor., zscore, resample
F = eROI.roi(roi).Fraw.F;
% F = slidingWindowZScore(e,F,1);
F = resampleToFlipTime(F, e);

% find stimulus onsets
stim = zeros(1,length(eStim.trial(trial).flipTimes));
for frame = 1 : length(eStim.trial(trial).sparseNoise(myPatch).startFrame)
    i0 = eStim.trial(trial).sparseNoise(myPatch).startFrame(frame);
    k = eStim.trial(trial).sparseNoise(myPatch).durationFrame(frame);
    i1 = i0+k-1;
    if i1 > length(stim)
        i1 = length(stim);
    end
    if eStim.trial(trial).sparseNoise(myPatch).color(frame) == 'w'
        stim(i0:i1) = 1;
    else
        stim(i0:i1) = -1;
    end
end

% find event we want
pulseTimes = double(eStim.trial(trial).sparseNoise(myPatch).startFrame);

% find starting point w.r.t. stim fliptimes and cut out
startIndex = F(trial).firstStimIndex+pulseTimes(whichPulse)-1;
graphF = cutOut2(F(trial).F, startIndex, iBefore, iAfter);

% cut stim to match F^
start = cast(eStim.trial(trial).sparseNoise(myPatch).startFrame(whichPulse),'like',iBefore);
graphStim = cutOut2(stim, start, iBefore, iAfter);

% bring to baseline
baseline = mean(graphF);
graphF = graphF - baseline;

%% graph
% video file
v = VideoWriter(['roi',num2str(roi),'trial',num2str(trial),'patch',...
    num2str(myPatch),'pulse',num2str(whichPulse)]);
open(v);
for fi = 1 : 480
    figure(3);
    fullLandscapePaperSize;
    clf;
    plotCellName(['ROI = ',num2str(roi), ', Trial = ',num2str(trial), ...
        ', Spare noise patch = ',num2str(myPatch), ', Pulse = ',num2str(whichPulse)]);
    
    stimPlot = subplot(3,1,1);
    ylabel('Stimulus');
    set(gca, 'YTick', [-1 0 1], 'YTickLabel', {'Black' 'Gray' 'White'});
    hold on;
    axis([-4 4 -2 2]);
    grid on;
    % First plot mirrors Erik's code (whole trial)
    % plot(eStim.trial(trialIndex).flipTimes, stim, 'LineWidth', 2);
    % Second plot is just one pulse onset, with +/- 4sec window
    plot(x(1:fi), graphStim(1:fi), 'LineWidth', 2);
    drawnow
    
    respPlot = subplot(3,1,2);
    hold on;
    % First plot mirrors Erik's code (whole trial)
    % plot(F(trial).t, F(trial).F, 'LineWidth', 2);
    % Second plot is just one pulse onset, with +/- 4sec window
    plot(x(1:fi), graphF(1:fi), 'LineWidth', 2);
    xline(0);
    yline(0);
    xlabel('Time relative to patch noise on');
    ylabel('Raw F');
    axis([-4 4 -1000 1000]);
    grid on;
    drawnow
    hold off;
    
    patchPlot = subplot(3,1,3);
    patchCenters = eStim.patchMotion.patchCenter;
    for patch = 1 : length(patchCenters)
        rectangle('Position', [patchCenters(patch).azimuthDeg - eStim.patchMotion.patchWidthDeg/2, ...
            patchCenters(patch).elevationDeg - eStim.patchMotion.patchWidthDeg/2, ...
            eStim.patchMotion.patchWidthDeg, eStim.patchMotion.patchWidthDeg], 'EdgeColor', [.5 .5 .5]);
    end
    rectangle('Position', [patchCenters(myPatch).azimuthDeg - eStim.patchMotion.patchWidthDeg/2, ...
        patchCenters(myPatch).elevationDeg - eStim.patchMotion.patchWidthDeg/2, ...
        eStim.patchMotion.patchWidthDeg, eStim.patchMotion.patchWidthDeg], 'FaceColor', dco(2));
    rectangle('Position', [-e(1).screenParams.widthDeg/2 -e(1).screenParams.heightDeg/2 e(1).screenParams.widthDeg e(1).screenParams.heightDeg]);
    xline(0);
    yline(0);
    axis tight;
    xlabel('Deg');
    ylabel('Deg');
    title(['Patch at ' num2str([patchCenters(myPatch).azimuthDeg patchCenters(myPatch).elevationDeg])]);
    
    writeVideo(v,getframe(gcf));
    
end
close(v);
