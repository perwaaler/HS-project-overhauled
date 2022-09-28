function store_trainedNetsInArray(fileName,storageFolder,tempStorageFolder,description,train_settings)
% cpllects the networks in the temporary storage folder in a cell array,
% and writes the array to a file in the base of the folder which contains
% all trained networks.
%% preliminary
if isempty(storageFolder) || storageFolder=="here"
    storageFolder = pwd;
end
if isempty(tempStorageFolder) || tempStorageFolder=="here"
    tempStorageFolder = pwd;
end
%% body
net_names = ls(tempStorageFolder);
net_names = net_names(3:end,:);

N_nets = height(net_names);
networks = cell(1,8);
for i=1:N_nets
    load(net_names(i,:),'net')
    networks{i} = net;
end

description = stackStrings(description);
fileName = strcat(storageFolder,'/',fileName);

save(fileName,'networks','description','train_settings')

end