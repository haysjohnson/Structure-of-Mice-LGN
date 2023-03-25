%% 0: load files

clear all;

% addpath '/Users/hays.johnson/Desktop/Misc. McGill/Cook Lab Report/Supplemental Materials/data'

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

disp('Files loaded.');
%% 1: variables
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

% z-score cutoff
cutoff = .5;
%% 2: find, cut out, average responses per patch

% Go by roi, find max response over all patches
% does not account for responsive to both, just takes max response

% for batches
% for the record, I can stop whenever
% can also use 'toc' after program has terminated
start=501;
stop=800;
iB=1;
iW=1;
% store ROI indices by color of max avg. response (if >= cutoff)
blackROIs = zeros(stop-start+1,1);
whiteROIs = zeros(stop-start+1,1);
% store max response from 801 on so I can easily change cutoff later
blackMaxes = zeros(stop-start+1,1);
whiteMaxes = zeros(stop-start+1,1);

tic
for roi = start:stop%[120,63,2602,267,1065,33,858,1222,2223,90,604,1611]%:length(eROI.roi)
    disp(['Processing ROI ',num2str(roi),'...']);
    maxPatch = [1,1]; % first index: black response, second: white response
    for patch = 1:eStim.sparseNoise.numPatches
        F = eROI.roi(roi).Fraw.F;
        % zscore
        F = slidingWindowZScore(e,F,1);
        % resample to frames
        F = resampleToFlipTime(F, e);
        
        % store responses per trial, by color
        blackResp = [];
        whiteResp = [];
        % store n = num of trials averaged per color for this patch
        nWhite = 0;
        nWhite = 0;
        % loop thru trials
        for trial=1: length(e)
            % check for sparse noise
            noise = strcmp(eStim.trial(trial).type, 'Sparse noise');
            if noise
                pulseTimes = double(eStim.trial(trial).sparseNoise(patch).startFrame);
                tempW = [];
                tempW = [];
                % loop thru each on/off for patch and cut
                for i=1 : length(pulseTimes)
                    % convert; starting point w.r.t. stim fliptimes
                    startIndex = F(trial).firstStimIndex+pulseTimes(i)-1;
                    % cut out F
                    tempF = cutOut2(F(trial).F, startIndex, iBefore, iAfter);
                    % store by color; first black
                    if eStim.trial(trial).sparseNoise(patch).color(i) == 'b'
                        tempW = [tempW ; tempF];
                        nWhite = nWhite+1;
                    else % white
                        tempW = [tempW ; tempF];
                        nWhite = nWhite+1;
                    end
                end
                % now we have all responses for 1 trial for our patch
                % average them by color and save to be averaged over trials
                tempW = mean(tempW, 1,'omitnan');
                tempW = mean(tempW, 1, 'omitnan');
                if ~isempty(tempW)
                    blackResp = [blackResp;tempW];
                end
                if ~isempty(tempW)
                    whiteResp = [whiteResp;tempW];
                end
            end
        end
        % now we have all trials for our patch
        % average them by color and save as final patch response
        blackResp = mean(blackResp, 'omitnan');
        whiteResp = mean(whiteResp, 'omitnan');
        
        % bring to baseline
        signal = blackResp;
        baseline = mean(signal(iBeforeSubtractMean));
        blackResp = signal - baseline;
        
        signal = whiteResp;
        baseline = mean(signal(iBeforeSubtractMean));
        whiteResp = signal - baseline;
        
        % determine if this patch response is max
        if patch == 1
            maxBlackResp = blackResp;
        elseif max(blackResp)>max(maxBlackResp)
            maxBlackResp = blackResp;
            maxPatch(1) = patch;
        end
        if patch == 1
            maxWhiteResp = whiteResp;
        elseif max(whiteResp)>max(maxWhiteResp)
            maxWhiteResp = whiteResp;
            maxPatch(2) = patch;
        end
        
    end
    % determine if responsive
    maxBlack = max(maxBlackResp);
    maxWhite = max(maxWhiteResp);
    if (maxBlack >= cutoff) | (maxWhite >= cutoff)
        if (maxBlack > maxWhite)
            blackROIs(iB) = roi;
            blackMaxes(iB) = maxBlack;
            iB = iB + 1;
            disp(['ROI ',num2str(roi),' added to black list. Max = ',num2str(maxBlack)]);
        else
            whiteROIs(iW) = roi;
            whiteMaxes(iW) = maxWhite;
            iW = iW + 1;
            disp(['ROI ',num2str(roi),' added to white list. Max = ',num2str(maxWhite)]);
        end
    end
end

% report responsive ROIs
toc
bR = [];
bM = [];
wR = [];
wM = [];
for i=1:length(blackROIs)
    if blackROIs(i) ~= 0
        bR = [bR; blackROIs(i)];
    end
    if blackMaxes(i) ~= 0
        bM = [bM; blackMaxes(i)];
    end
    if whiteROIs(i) ~= 0
        wR = [wR; whiteROIs(i)];
    end
    if whiteMaxes(i) ~= 0
        wM = [wM; whiteMaxes(i)];
    end
end
disp(['Black list: ',num2str(transpose(bR))]);
disp(['Max values for black resps.: ',num2str(transpose(bM))]);
disp(['White list: ',num2str(transpose(wR))]);
disp(['Max values for white resps.: ',num2str(transpose(wM))]);

%% 3: same but only finds dual responsive ROIs; Black First
% REQUIRES ROI LIST FROM whiteOrBlackResp.m
% scan thru ROIs already deemed responsive;
% for white check black resp. and for black check white;
% if found responsive add to separate double list; print and add to file

% Go by roi, find max response over all patches
% does not account for responsive to both, just takes max response

% for batches
% for the record, I can stop whenever
% can also use 'toc' after program has terminated
% start=1;
% stop=length(bROI);
iW=1;
% store ROI indices by color of max avg. response (if >= cutoff)
whiteROIs = zeros(length(bROI),1);
% store max response from 801 on so I can easily change cutoff later
whiteMaxes = zeros(length(bROI),1);
newStart = 1479;
tic
for roi = bROI%start:stop%[120,63,2602,267,1065,33,858,1222,2223,90,604,1611]%:length(eROI.roi)
    if roi < newStart
        continue
    else
        disp(['Processing ROI ',num2str(roi),'...']);
        maxPatch = [1,1]; % first index: black response, second: white response
        for patch = 1:eStim.sparseNoise.numPatches
            F = eROI.roi(roi).Fraw.F;
            % zscore
            F = slidingWindowZScore(e,F,1);
            % resample to frames
            F = resampleToFlipTime(F, e);
            
            % store responses per trial, by color
            whiteResp = [];
            % loop thru trials
            for trial=1: length(e)
                % check for sparse noise
                noise = strcmp(eStim.trial(trial).type, 'Sparse noise');
                if noise
                    pulseTimes = double(eStim.trial(trial).sparseNoise(patch).startFrame);
                    tempW = [];
                    % loop thru each on/off for patch and cut
                    for i=1 : length(pulseTimes)
                        % this is looping thru black ROIs so just need to check
                        % white response
                        if eStim.trial(trial).sparseNoise(patch).color(i) == 'w'
                            % convert; starting point w.r.t. stim fliptimes
                            startIndex = F(trial).firstStimIndex+pulseTimes(i)-1;
                            % cut out F
                            tempF = cutOut2(F(trial).F, startIndex, iBefore, iAfter);
                            % store by color
                            tempW = [tempW ; tempF];
                        end
                    end
                    % now we have all responses for 1 trial for our patch
                    % average them by color and save to be averaged over trials
                    tempW = mean(tempW, 1,'omitnan');
                    if ~isempty(tempW)
                        whiteResp = [whiteResp;tempW];
                    end
                end
            end
            % now we have all trials for our patch
            % average them by color and save as final patch response
            whiteResp = mean(whiteResp, 'omitnan');
            
            % bring to baseline
            signal = whiteResp;
            baseline = mean(signal(iBeforeSubtractMean));
            whiteResp = signal - baseline;
            
            % determine if this patch response is max
            if patch == 1
                maxWhiteResp = whiteResp;
            elseif max(whiteResp)>max(maxWhiteResp)
                maxWhiteResp = whiteResp;
                maxPatch(2) = patch;
            end
        end
        % determine if responsive
        maxWhite = max(maxWhiteResp);
        if (maxWhite >= cutoff)
            whiteROIs(iW) = roi;
            whiteMaxes(iW) = maxWhite;
            iW = iW + 1;
            disp(['ROI ',num2str(roi),' added to white-dual list. Max = ',num2str(maxWhite)]);
            
        end
    end
end

% report responsive ROIs
toc
wR = [];
wM = [];
for i=1:length(whiteROIs)
    if whiteROIs(i) ~= 0
        wR = [wR; whiteROIs(i)];
    end
    if whiteMaxes(i) ~= 0
        wM = [wM; whiteMaxes(i)];
    end
end
disp(['White-dual list: ',num2str(transpose(wR))]);
disp(['Max values for white-dual resps.: ',num2str(transpose(wM))]);

%% 4: now White
% REQUIRES ROI LIST FROM whiteOrBlackResp.m
% scan thru ROIs already deemed responsive;
% for white check black resp. and for black check white;
% if found responsive add to separate double list; print and add to file
% WHITE NEXT:

% Go by roi, find max response over all patches
% does not account for responsive to both, just takes max response

% for batches
% for the record, I can stop whenever
% can also use 'toc' after program has terminated
% start=1;
% stop=length(wROI);
iB=1;
% store ROI indices by color of max avg. response (if >= cutoff)
blackROIs = zeros(length(wROI),1);
% store max response from 801 on so I can easily change cutoff later
blackMaxes = zeros(length(wROI),1);
newStart = wROI(1);
tic
for roi = wROI%start:stop%[120,63,2602,267,1065,33,858,1222,2223,90,604,1611]%:length(eROI.roi)
    if roi < newStart
        continue
    else
        disp(['Processing ROI ',num2str(roi),'...']);
        maxPatch = [1,1]; % first index: black response, second: white response
        for patch = 1:eStim.sparseNoise.numPatches
            F = eROI.roi(roi).Fraw.F;
            % zscore
            F = slidingWindowZScore(e,F,1);
            % resample to frames
            F = resampleToFlipTime(F, e);
            % store responses per trial, by color
            blackResp = [];
            % loop thru trials
            for trial=1: length(e)
                % check for sparse noise
                noise = strcmp(eStim.trial(trial).type, 'Sparse noise');
                if noise
                    pulseTimes = double(eStim.trial(trial).sparseNoise(patch).startFrame);
                    tempB = [];
                    % loop thru each on/off for patch and cut
                    for i=1 : length(pulseTimes)
                        % only check black resps as we are looping thru white
                        % ROI list
                        if eStim.trial(trial).sparseNoise(patch).color(i) == 'b'
                            % convert; starting point w.r.t. stim fliptimes
                            startIndex = F(trial).firstStimIndex+pulseTimes(i)-1;
                            % cut out F
                            tempF = cutOut2(F(trial).F, startIndex, iBefore, iAfter);
                            % store by color; first black
                            tempB = [tempB ; tempF];
                        end
                    end
                    % now we have all responses for 1 trial for our patch
                    % average them by color and save to be averaged over trials
                    tempB = mean(tempB, 1,'omitnan');
                    if ~isempty(tempB)
                        blackResp = [blackResp;tempB];
                    end
                end
            end
            % now we have all trials for our patch
            % average them by color and save as final patch response
            blackResp = mean(blackResp, 'omitnan');
            
            % bring to baseline
            signal = blackResp;
            baseline = mean(signal(iBeforeSubtractMean));
            blackResp = signal - baseline;
            
            % determine if this patch response is max
            if patch == 1
                maxBlackResp = blackResp;
            elseif max(blackResp)>max(maxBlackResp)
                maxBlackResp = blackResp;
                maxPatch(1) = patch;
            end
        end
        % determine if responsive
        maxBlack = max(maxBlackResp);
        if (maxBlack >= cutoff)
            blackROIs(iB) = roi;
            blackMaxes(iB) = maxBlack;
            iB = iB + 1;
            disp(['ROI ',num2str(roi),' added to black-dual list. Max = ',num2str(maxBlack)]);
        end
    end
end

% report responsive ROIs
toc
bR = [];
bM = [];
for i=1:length(blackROIs)
    if blackROIs(i) ~= 0
        bR = [bR; blackROIs(i)];
    end
    if blackMaxes(i) ~= 0
        bM = [bM; blackMaxes(i)];
    end
end
disp(['Black-dual list: ',num2str(transpose(bR))]);
disp(['Max values for black-dual resps.: ',num2str(transpose(bM))]);

