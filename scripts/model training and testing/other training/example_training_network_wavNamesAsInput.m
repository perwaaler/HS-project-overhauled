%% get audio names and other input data:
clear segLines audio_names
load('nodes_jointSeg_v2.mat','nodes')

aa = 1;

Jtrain = 1:30;
Jval = 40:60;
Jtest = 70:100;

N_train = numel(Jtrain);
N_val   = numel(Jval);
N_test  = numel(Jtest);

audio_names.train = strings(N_train,1);
audio_names.val = strings(N_val,1);
audio_names.test = strings(N_test,1);

annoGT.train = zeros(N_train,1);
annoGT.val = zeros(N_val,1);
annoGT.test = zeros(N_test,1);

segLines.train = nodes.seglines(Jtrain,aa);
segLines.val   = nodes.seglines(Jval,aa);
segLines.test  = nodes.seglines(Jtest,aa);

% get training data
for i=1:N_train
    kk = Jtrain(i);
    audio_names.train(i) = sprintf("%0.f_hjertelyd_%g",HSdata.id(kk),aa);
    annoGT.train(i) = HSdata.murGrade1(kk);
end
% get validation data
for i=1:N_val
    kk = Jval(i);
    audio_names.val(i) = sprintf("%0.f_hjertelyd_%g",HSdata.id(kk),aa);
    annoGT.val(i) = HSdata.murGrade1(kk);
end
% get test data
for i=1:N_test
    kk = Jtest(i);
    audio_names.test(i) = sprintf("%0.f_hjertelyd_%g",HSdata.id(kk),aa);
    annoGT.test(i) = HSdata.murGrade1(kk);
end

%% train network:

% load('networksCVnoNoiseDrOutMurRegAllPos_jointSegNonRandomSegExtraction.mat','networks')
% net = networks{1};
[net,activ,AUC,p,X,Y] = trainModel(audio_names, annoGT, segLines,...
                                    'N_validation_stoppage',2,'pretrainedNet',[],...
                                    'trainNet',true);


