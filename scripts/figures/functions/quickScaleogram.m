function quickScaleogram(id,aa)

if nargin==2

    [x,fs0] = wav2TS(id,aa);
    Nds = floor(fs0/2205);
    x = downsample(x,Nds);
    fs = fs0/Nds;
    scaleogramPlot(x,fs);

else
    
    for aa=1:4
        subplot(2,2,aa)
        [x,fs0] = wav2TS(id,aa);
        Nds = floor(fs0/2205);
        x = downsample(x,Nds);
        fs = fs0/Nds;
        scaleogramPlot(x,fs);
    end

end


end

