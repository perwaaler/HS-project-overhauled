function store_trainedNetsInArray(fileName,storageFolder,tempStorageFolder,description)
% cpllects the networks in the temporary storage folder in a cell array,
% and writes the array to a file in the base of the folder which contains
% all trained networks.
%%
net_names = ls(tempStorageFolder);
net_names = net_names(3:end,:);

N_nets = height(net_names);
networks = cell(1,8);
for i=1:N_nets
    load(net_names(i,:),'net_i')
    networks{i} = net_i;
end

description = stackStrings(description);
fileName = strcat(storageFolder,'/',fileName);

save(fileName,'networks','description')

end