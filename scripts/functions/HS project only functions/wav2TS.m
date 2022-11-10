function [X, fs] = wav2TS(id, auscLoc)
% reads the audio file and CONVERTS it to numeric vector. id is the
% LOPENUMMER, or alternatively it can be the name of the audiofile, with or
% without .wav extension.


if isnumeric(id)

    if nargin == 1
        X = cell(1, 4);
        for aa = 1:4
            [X{aa}, fs] = audioread(sprintf('%.0f_hjertelyd_%g.wav', id, aa));
        end
    else
        [X, fs] = audioread(sprintf('%.0f_hjertelyd_%g.wav', id, auscLoc));
    end

else
    % id is interpereted to be a string
    if contains(id,"wav")
        [X, fs] = audioread(sprintf('%s', id));
    else
        [X, fs] = audioread(sprintf('%s.wav', id));
    end
end

end