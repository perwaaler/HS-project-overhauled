%% run cross validation
load nodes_jointSeg_v2.mat
load nodes_jointSeg_v1.mat
load CVpartitions.mat
% load networksCVnoNoiseDrOutMurRegAllPos_SpringerSeg.mat
% load pretrained nets:
% load networksCVnoNoiseDrOutMurRegAllPosValStopOvertrain.mat
close all
saveFolder = 'C:\HS-project\scripts\model training and testing\CV training';
[CVresults,AUCmat,p] = cross_validation_allPositions(CVpartitions,nodes,Paths,...
                                'CV_set_indeces',1,...
                                'save_net_folder',saveFolder,...
                                'N_validation_stoppage',5,...
                                'trainNet',true)


%% save results
load CVresults_netMurRegAllPos_valStop_SpringerSeg.mat

% CVresults.train = renameField(CVresults.train,'activ','activations');
% CVresults.val = renameField(CVresults.val,'activ','activations');

CVresults.train.J = cell(8,4);
CVresults.val.J   = cell(8,4);
for i=1:8
    for j=1:4
        CVresults.train.J{i,j} = find(CVresults.train.I{i,j});
        CVresults.val.J{i,j}   = find(CVresults.val.I{i,j});
    end
end
%%
description = {'Used springers original segmentation algorithm',...
               'Extracted as many segments as was availabe',...
                'stopped training after 10 consecutive failed improvements',...
                'of validation loss or 50 epochs.'};
description = stackStrings(description);
settings = p.Results;
fileName = 'CVresults_netMurRegAllPos_valStop_SpringerSeg.mat';
save(fileName,'CVresults','description','settings')