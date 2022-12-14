function networks = collectTrainedNetsInArray(tempStorageFolder)
% collects the networks in the temporary storage folder in a cell array,
% and writes the array to a file in the base of the folder which contains
% all trained networks. Either provide the path to the temporary storage
% directory, or move to that directory and provide no argument.
%% preliminary
if nargin==0
    tempStorageFolder = pwd;
end
%% body
net_names = ls(tempStorageFolder);
net_names = net_names(3:end,:);

N_nets = height(net_names);
networks = cell(8,1);
for i=1:N_nets
    load(net_names(i,:),'net')
    networks{i} = net;
end

end