%% predict murmur grades and plot scaleograms and segmentation

% set sample counter to zero:
k = 0;
% define subset to plot from:
J = find(HSdata.murGrade1>=3);

%% manually plot results for each sample:
X = cell(1,4);
k = k+1;
kk = J(k);
id = HSdata.id(kk);

for aa=1:4
    [X{aa},fs0] = wav2TS(id,aa);
end

load networksTrainingSet_valStop.mat

[Y,A,S,fitInfo] = predictMurmur(X,fs0,net);

figure
for aa=1:4
    annotation = HSdata.(sprintf('murGrade%g',aa))(kk);
    subplot(2,2,aa)
        quickScaleogram(id,aa);
        hold on
        plotAssignedStates(S{aa},fs0/20)
        title(sprintf('pred: %g   anno: %g',round(Y(aa),1),annotation))
end
