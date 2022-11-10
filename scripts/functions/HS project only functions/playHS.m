function player = playHS(id,aa)

if isnumeric(id)
    [x,fs] = audioread(sprintf('%.0f_hjertelyd_%g.wav',id,aa));
    player = audioplayer(x,fs);
    play(player);
else
    if contains(id,"wav")
        [x, fs] = audioread(sprintf('%s', id));
    else
        [x, fs] = audioread(sprintf('%s.wav', id));
    end
    player = audioplayer(x,fs);
    play(player);
end

end