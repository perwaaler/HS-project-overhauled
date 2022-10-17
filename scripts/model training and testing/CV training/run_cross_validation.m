%% run cross validation
load nodes_jointSeg_v2.mat
load CVpartitions.mat
load('networksCVnoNoiseDrOutMurRegAllPos_jointSegNonRandomSegExtraction.mat','networks')
close all
saveNetFolder = 'C:\HS-project\scripts\model training and testing\CV training\net temporary storage';
[CVresults,AUCmat,p,Xtrain,Ytrain] = cross_validation_allPositions(...
                                    CVpartitions,nodes,Paths,...
                                    'HSdata',HSdata,...
                                    'CV_set_indeces',5:7,...
                                    'save_net_folder',saveNetFolder,...
                                    'N_validation_stoppage',7,...
                                    'trainNet',true,...
                                    'getTrainData',true,...
                                    'preTrainedNetworks',false,...
                                    'balanceTrain',true,...
                                    'balanceVal',true,...
                                    'trainOnlyOnClean',false,...
                                    'target_type','murGrade_weighted',...
                                    'thr_resample',1,...
                                    'thr_testTarget',1,...
                                    'test_target','ASgrade')
