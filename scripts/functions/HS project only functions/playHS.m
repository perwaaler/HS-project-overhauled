function player = playHS(id,aa)
[x,fs] = audioread(sprintf('%.0f_hjertelyd_%g.wav',id,aa));
player = audioplayer(x,fs);
play(player);
end