function [segBorders,N_segExtracted] = getSegments(cycleLines,varargin)
% Finds segment endpoints, each of which contain N_cyclesPerSegment cycles.
% The overlap between adjacent segments is N_cycleOverlap cycles. Extracts
% N_segDesired segments. If there arent enough cycles to meet the desired
% number, segments are resampled randomly untill the number is met.
% Endpoints are stored as columns in segBorders.
%% default arguments
N_cycleOverlap = 2;
N_cyclesPerSegmentDesired = 4;
N_segDesired = 6;
resampleIfNeeded = false;

p = inputParser;
addOptional(p,'N_cycleOverlap',N_cycleOverlap)
addOptional(p,'N_cyclesPerSegmentDesired',N_cyclesPerSegmentDesired)
addOptional(p,'N_segDesired',N_segDesired)
addOptional(p,'resampleIfNeeded',resampleIfNeeded)
parse(p,varargin{:})

N_cycleOverlap = p.Results.N_cycleOverlap;
N_cyclesPerSegmentDesired = p.Results.N_cyclesPerSegmentDesired;
N_segDesired = p.Results.N_segDesired;
resampleIfNeeded = p.Results.resampleIfNeeded;

%% example input
% cycleLines = (1:2);
% N_cycleOverlap = 2;
% N_cyclesPerSegmentDesired = 4;
% N_segDesired = 6;
% resampleIfNeeded = false;
%% body

% ensure that the number of cardiac cycles per segment requested does not
% exceed the number of cardiac cycles available:
N_cycleLines = numel(cycleLines);
N_cyclesAvailable = N_cycleLines - 1;
N_cyclesPerSegment = min(N_cyclesPerSegmentDesired,...
                         N_cyclesAvailable);


if N_cyclesPerSegment==N_cyclesAvailable
    % instruct algorithm to resample 5 times:
    segBorders = [1,N_cycleLines];
    N_segExtracted = 1;
    
else
    % number of segments that can be extracted from the data:
    N_segExtracted = floor((N_cyclesAvailable - N_cycleOverlap)/...
                           (N_cyclesPerSegment - N_cycleOverlap));
    
    if N_segExtracted==1
        % few cycles availabe - change segment overlap to 1 less than
        % cycles per segment to etract as many non-identical segments as
        % possible:
        N_cycleOverlap = N_cyclesPerSegment-1;
        N_segExtracted = floor((N_cyclesAvailable -  N_cycleOverlap)/...
                               (N_cyclesPerSegment - N_cycleOverlap));
    end
    
    x = N_cyclesPerSegment - N_cycleOverlap;
    % compute right endpoints of segments:
    rk = N_cyclesPerSegment + 1 + (0:(N_segExtracted-1))*x;
    % compute left endpoints of segments:
    lk = rk - N_cyclesPerSegment;
    % collect endpoints in a matrix:
    segBorders = [lk',rk'];
    
end

% If there are not enough segments to meet the desired number, draw
% segments randomly N_cycles times untill desired number of segments is
% obtained:
N_randSeg = N_segDesired - N_segExtracted;

if N_randSeg>0 && resampleIfNeeded
    ind_randSeg = randi(N_cycleLines-N_cyclesPerSegment,N_randSeg,1);
    randSeg     = ind_randSeg + [0,N_cyclesPerSegment];
    segBorders  = [segBorders;randSeg];
    
else
    segBorders = segBorders(1:N_segExtracted,:);
end

% get true index:
segBorders = cycleLines(segBorders);

end