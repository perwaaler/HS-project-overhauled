function quickScaleogram(id,varargin)

P.displayMurGrade = false;
P.Pos = [];

p = inputParser;
addOptional(p,'displayMurGrade',P.displayMurGrade);
addOptional(p,'Pos',P.Pos);
parse(p,varargin{:})
P = updateOptionalArgs(P,p);

load('HSdata.mat','HSdata')

if ~isempty(P.Pos)

    [x,fs0] = wav2TS(id,P.Pos);
    Nds = floor(fs0/2205);
    x = downsample(x,Nds);
    fs = fs0/Nds;
    scaleogramPlot(x,fs);

    if P.displayMurGrade
        str = sprintf('murGrade%g',P.Pos);
        mg = HSdata.(str)(HSdata.id==id);
        title(sprintf("murGrade=%g", mg))
    end

else
    
    for aa=1:4
        subplot(2,2,aa)
        [x,fs0] = wav2TS(id,aa);
        Nds = floor(fs0/2205);
        x = downsample(x,Nds);
        fs = fs0/Nds;
        scaleogramPlot(x,fs);

        if P.displayMurGrade
            str = sprintf('murGrade%g',aa);
            mg = HSdata.(str)(HSdata.id==id);
            title(sprintf("murGrade=%g", mg))
        end
    end

end


end

