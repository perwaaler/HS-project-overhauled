load('networksTrainingSet_valStop.mat')
%%
k = 3;
X = cell(1,4);
for aa=1:4
    [X{aa},fs0] = wav2TS(HSdata.id(k),aa);
end

[Y,A,Seg,fitInfo,X_net] = predictMurmur(X,fs0,net);
Y'
[HSdata.murGrade1(k),HSdata.murGrade2(k),...
 HSdata.murGrade3(k),HSdata.murGrade4(k)]