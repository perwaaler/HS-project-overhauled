function [B,N_segExtracted] = getSegments_deterministic(cycleLines,varargin)
% Finds segment endpoints, each of which contains N_cyclesPerSegment
% cycles. The overlap between adjacent segments is N_cycleOverlap cycles.
% Extracts N_segDesired segments if available. Extracts segments and shifts
% right until out of bounds, at which point it starts over again but makes
% a shift so that the segments are shifted 1 to the right of the
% segments from the first round. In this way the algorithm extracts as many
% "novel" segments as possible.
%% default arguments
N_cycleOverlap = 2;
N_cyclesPerSegmentDesired = 4;
N_segDesired = 10;

p = inputParser;
addOptional(p,'N_cycleOverlap',N_cycleOverlap)
addOptional(p,'N_cyclesPerSegmentDesired',N_cyclesPerSegmentDesired)
addOptional(p,'N_segDesired',N_segDesired)
parse(p,varargin{:})

N_cycleOverlap = p.Results.N_cycleOverlap;
N_cyclesPerSegmentDesired = p.Results.N_cyclesPerSegmentDesired;
N_segDesired = p.Results.N_segDesired;

%% example input
% cycleLines = (1:10);
% N_cycleOverlap = 3;
% N_cyclesPerSegmentDesired = 4;
% N_segDesired = 10;
% resampleIfNeeded = false;
%% body
N_stepSize = N_cyclesPerSegmentDesired - N_cycleOverlap;
N_segLines = numel(cycleLines);
N_segAvailable = N_segLines - 1;
B = zeros(N_segDesired,2);
shift_and_restart = false;
k = 1;

if N_segAvailable<N_cyclesPerSegmentDesired
    B = cycleLines([1,N_segLines]);
    c = 1;
else

    for i=1:N_segDesired

        if ~shift_and_restart
           l = N_stepSize*(k-1) + 1;
           u = l + N_cyclesPerSegmentDesired;

           if u>N_segLines
               shift_and_restart = true;
               c = k - 1;
               k = 1;
           else
               B(k,:) = cycleLines([l,u]);
               k = k + 1;
           end

        else
           l = N_stepSize*(k-1) + 2;
           u = l + N_cyclesPerSegmentDesired;

           if u>N_segLines
               B = B(1:c+k-1,:);
               break
           else
               B(c+k,:) = cycleLines([l,u]);
               k = k + 1;
           end
        end

    end
end

B = B(1:min(N_segDesired,c+k-1),:);
N_segExtracted = height(B);


end