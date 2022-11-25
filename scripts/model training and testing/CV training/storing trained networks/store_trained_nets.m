% This script is run after CV-training to save networks and results.
% Navigate to the folder that contains the stored networks (temporary
% storage location) and run the below lines after naming and describing the
% file. After running the commands, move the two saved files from the
% temporary storage folder into their proper locations.

%% saving settings:

% describe the file:
trainingDescription = ["23-11-22. Trained on aortic pos. avpgmean as regression.", ...
    "Used joint segmentation."]
% navigate to folder with saved networks, and get directory with pwd command:
tempStorageFolder = pwd;
storageFolder = pwd;
% name the file:
fileName = 'networksCV_noNoise_avmeanpg_AorticOnly.mat';
% get training settings:
train_settings = p.Results;

%% collect trained net files in cell array:
networks = collectTrainedNetsInArray()

%% save network array in current folder
save(fileName, ...
    'networks', 'trainingDescription', 'train_settings')

%% save CVresults in current folder
save('CVresults_noise_murRegAllPos_jointSegNonRandomSegExtraction.mat', ...
    'CVresults', 'description', 'train_settings')
