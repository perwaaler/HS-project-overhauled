clear all
addPaths

importingAndPreProcessingTUdata
renameAndDefineVariables_TUdata
loadHMMpar

% clear variables except those that are probably going to be used again:
initialVars = {'HMMpar' 'HSdata' 'HSdataTrain' 'murDataInfo' 'echoDataInfo' ...
               'Jtest0' 'Jtrain0' 'Jval0' 'stats' 'statsAll' 'initialVars'...
               'Paths'};
clearvars('-except',initialVars{:})
    