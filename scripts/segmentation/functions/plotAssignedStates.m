function plotAssignedStates(assignedStates,varargin)
% function that plots the assigned states (expanded form) specified by
% states2plot using the colors specified in the string vector cols. Nds is
% the downsampling factor of the data. Assumes that you have already
% plotted the scaleogram of the data. If Nds==20 (the default), set Nds to
% 1. This does not make sense, but it works, and I am too lazy to fix this
% bug every single script where it is used...
%% default arguments
fs = 1;
states2plot = [2,4];
colors = ['r','b'];
level = 100;

p = inputParser;
addOptional(p,'fs',fs)
addOptional(p,'states2plot',states2plot)
addOptional(p,'colors',colors)
addOptional(p,'level',level)
parse(p,varargin{:})

fs = p.Results.fs;
states2plot = p.Results.states2plot;
colors = p.Results.colors;
level  = p.Results.level;

%% function body

if numel(assignedStates)<100
    for i=1:numel(states2plot)
        x = assignedStates;
        scatter(x/fs, ones(1,length(x))*level,'MarkerFaceColor','k');
    end
    
else
    for i=1:numel(states2plot)
        Jstate = find(assignedStates==states2plot(i));
        scatter(Jstate/fs, ones(1,length(Jstate))*level,colors(i),'.');
    end
end


end