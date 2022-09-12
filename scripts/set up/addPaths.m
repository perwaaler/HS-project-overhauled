% get name of folders to put on path:
paths

% add paths:
pathNames = fieldnames(Paths);
for i=1:numel(pathNames)
    addpath(genpath(Paths.(pathNames{i})))
end
