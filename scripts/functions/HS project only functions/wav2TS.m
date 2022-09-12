function [X,fs] = wav2TS(id,auscLoc)
% reads the audio file and CONVERTS it to numeric vector. id is the
% LOPENUMMER.
if nargin==1
    X = cell(1,4);
    for aa=1:4
        [X{aa},fs] = audioread(sprintf('%.0f_hjertelyd_%g.wav',id,aa));
    end
else
    [X,fs] = audioread(sprintf('%.0f_hjertelyd_%g.wav',id,auscLoc));
end
end