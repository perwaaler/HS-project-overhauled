%% run cross validation
load nodes_jointSeg_v2.mat
load CVpartitions.mat
load('networksCVnoNoiseDrOutMurRegAllPos_jointSegNonRandomSegExtraction.mat','networks')
close all
saveNetFolder = 'C:\HS-project\scripts\model training and testing\CV training\net temporary storage 2';
[CVresults,AUCmat,p,Xtrain,Ytrain] = cross_validation_allPositions(CVpartitions,nodes,Paths,...
                                    'CV_set_indeces',1:8,...
                                    'save_net_folder',saveNetFolder,...
                                    'N_validation_stoppage',7,...
                                    'N_cycleOverlap',2,...
<<<<<<< HEAD
                                    'trainNet',false,...
                                    'getTrainData',true,...
                                    'balanceTrain',false,...
                                    'balanceVal',false,...
                                    'preTrainedNetworks',networks)
=======
                                    'trainNet',true,...
                                    'balanceTrain',true,...
                                    'balanceVal',true,...
                                    'trainOnlyOnClean',false)

>>>>>>> c7a02091bc171e38fbf52e9d07b747051794f4dd
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