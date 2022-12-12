% all folder paths which contain the relevant files for analysis ** NOTE:
% for this script to work, must be in the "set up" folder. NOTE: to run
% this script, user must first create a yaml file with two fields,
% "project" and "data", containing the paths to the project root folder and
% data storage location respectively.

% add path to the yaml utilities so that local yml file can be read:
addpath(genpath('..\functions\yaml utilities'));
% load local project and data paths from yml file (ignored by git):
paths_local = yaml.loadFile('local_paths.yml');

% Paths.project = paths_local.    
Paths.functions = fullfile(paths_local.project, 'scripts\functions');  
Paths.saveVar = fullfile(paths_local.project, 'saved matlab variables');
Paths.setUpScripts = fullfile(paths_local.project, 'scripts\set up');
Paths.murmurAlgorithm = fullfile(paths_local.project, 'scripts\T7 murmur algorithm');
Paths.dataFolder = paths_local.data;
Paths.T7data = fullfile(paths_local.data, 'Data - excel og text filer');
Paths.trainingAndTesting = fullfile(paths_local.project, 'scripts\model training and testing');
Paths.figures = fullfile(paths_local.project, 'scripts\figures');
Paths.tempSaveNets = fullfile(paths_local.project, 'saved matlab variables\trained networks\tempFiles');
Paths.savedNets = fullfile(paths_local.project, 'saved matlab variables\trained networks');  
