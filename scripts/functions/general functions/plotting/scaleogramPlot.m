function M = scaleogramPlot(x,fs,varargin)

%% optional name-value-pair arguments:
% default values:
f_range = [15,800];
plotIt  = true;
tidyAxis = true;
PseudoLog = false;
PseudoPar = [.7 .8];

p = inputParser;
addOptional(p, 'f_range',f_range,    @(x) isnumeric(x))
addOptional(p, 'plotIt', plotIt,       @(x) islogical(x))
addOptional(p, 'tidyAxis', tidyAxis,   @(x) islogical(x))
addOptional(p, 'PseudoLog', PseudoLog, @(x) islogical(x))
addOptional(p, 'PseudoPar',PseudoPar,@(x) isnumeric(x))
parse(p,varargin{:})

% detach varibles from structure:
f_range = p.Results.f_range;
plotIt = p.Results.plotIt;
tidyAxis = p.Results.tidyAxis;
PseudoLog = p.Results.PseudoLog;
PseudoPar = p.Results.PseudoPar;
%% script
[cfs,f] = cwt(x,'amor',fs);
M = abs(cfs);

if PseudoLog
    M = pseudoLog(M, PseudoPar(1), PseudoPar(2));
end

if plotIt
    
    Icrop = and(f>f_range(1), f<f_range(2));
    
    if tidyAxis
        f = f(Icrop);
        imagesc([0,width(M)/fs],[f(1),f(end)], abs(M(Icrop,:)))
        set(gca,'YDir','normal')
        xlabel 'time (s)'
        ylabel 'Frequenzy (Hz)'
    else
        imagesc([0,width(M)],[1,height(M)], abs(M(Icrop,:)))
        set(gca,'YDir','normal')
    end
end

end