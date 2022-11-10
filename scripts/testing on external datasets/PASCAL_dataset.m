path_murA = "G:\My Drive\data ML\PASCAL\Atraining_murmur\Atraining_murmur";

X = ls(path_murA);
X = string(X);
X(1:3, :) = [];

k = 2;
wav_path = strcat(path_murA, "\", X(k, :))
[x0, fs0] = wav2TS(wav_path);
x = downsample(x0, 10);
fs = fs0 / 10;

close all
scaleogramPlot(x, fs);


load('networksTrainingSet_valStop.mat', "net")
mur_pred = predictMurmur(x0, fs0, net)
playHS(wav_path);


