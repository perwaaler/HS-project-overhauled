function [segBorders,N_segExtracted] = getSegments_oldWay(cycleLines,varargin)
% function [segBorders,kmax] = getSegments(cycleLines,Nos,Ncs,NsegDesired)
% computes endpoints of the segments, each of which contain Ncs cycles and
% overlap with Nos cycles. Extracts NsegDesired segments. If there arent
% enough cycles to meed the desired number, segments are resampled randomly
% untill the number is met. Endpoints are stored as columns in segBorders.
%% optional arguments
N_cycleOverlap = 2;
N_cyclesPerSegmentDesired = 4;
N_segDesired = 6;

p = inputParser;
addOptional(p,'N_cycleOverlap',N_cycleOverlap)
addOptional(p,'N_cyclesPerSegmentDesired',N_cyclesPerSegmentDesired)
addOptional(p,'N_segDesired',N_segDesired)
parse(p,varargin{:})

N_cycleOverlap = p.Results.N_cycleOverlap;
N_cyclesPerSegmentDesired = p.Results.N_cyclesPerSegmentDesired;
N_segDesired = p.Results.N_segDesired;
%% example input
cycleLines = (1:4);
N_cycleOverlap = 2;
N_cyclesPerSegmentDesired = 4;
N_segDesired = 6;
resampleIfNeeded = false;
%% function body

% number of cycle lines (lines indicating start of new cycle):
N_segLines = numel(cycleLines);
N_cyclesPerSegment = min(N_cyclesPerSegmentDesired,N_segLines);

if N_segLines-1<N_cyclesPerSegment 
end

% Number of cycles per segment minus Number of cycles that overlap
x = N_cyclesPerSegment - N_cycleOverlap;
% number of segments that can be extracted from the data:
kmax = floor((N_segLines-N_cyclesPerSegment-1)/x + 1);

% compute right endpoints of segments:
rk = N_cyclesPerSegment+1+(0:(kmax-1))*x;
% compute left endpoints of segments:
lk = rk-N_cyclesPerSegment;
% collect endpoints in a matrix:
segBorders = [lk',rk'];

% If there are not enough segments to meet the desired number, draw
% segments randomly untill condition is met:
NrandSeg = N_segDesired - kmax;

if NrandSeg>0
    ind_randSeg = randi(N_segLines - N_cyclesPerSegment,NrandSeg,1);
    randSeg     = ind_randSeg + [0,N_cyclesPerSegment];
    segBorders  = [segBorders;randSeg];
    
else
    segBorders = segBorders((1:N_segDesired),:);
end

% get true index:
segBorders = cycleLines(segBorders);
N_segExtracted = 6;
end