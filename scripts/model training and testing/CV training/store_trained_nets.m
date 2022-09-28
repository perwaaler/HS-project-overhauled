% This script is run after CV-training to save networks and results.
% Navigate to the folder that contains the stored networks (temporary
% storage location) and run the below lines after naming and describing the
% file. After running the commands, move the two saved files from the
% temporary storage folder into their proper locations.
%% saving settings:

% describe the file:
trainingDescription = {'Used joint segmentation (version whith min cycle duration)',...
    'set to 0.5s and fixed code for setting HR-peak integer-fraction search interval.',...
    'Used new, non-stochastic method for extracting training segments. Trained on'...
    'all data, inlcuding noise annotated files.'};

trainingDescription = stackStrings(trainingDescription);
% navigate to folder with saved networks, and get directory with pwd command:
tempStorageFolder = pwd;
storageFolder = pwd;
% name the file:
fileName = 'networksCV_noise_DrOutMurRegAllPos_jointSegNonRandomSegExtraction.mat';
% get training settings:
train_settings = p.Results;

%% collect trained net files in cell array:
networks = collectTrainedNetsInArray()
%% save network array in current folder
save('networksCV_noise_DrOutMurRegAllPos_jointSegNonRandomSegExtraction.mat',...
    'networks','trainingDescription','train_settings')
%% save CVresults in current folder
save('CVresults_noise_murRegAllPos_jointSegNonRandomSegExtraction.mat',...
    'CVresults','description','train_settings')

