function quickScaleogram(id,aa)
[x,fs0] = wav2TS(id,aa);
Nds = floor(fs0/2205);
x = downsample(x,Nds);
fs = fs0/Nds;
scaleogramPlot(x,fs);
end

