%% import T7 data:
import_T7_variables

%% Extract the rows for which auscultation was performed
HSdata = TUdata(~isnan(TUdata.MURMUR_1NORMAD_T72),:); 

%% Correct for the fact that ausc-location ordering was changed during data collection:
% correct for the fact that the ordering of the auscultation areas was
% reversed after week 34:
load('idAuscOrder.mat')
correctOrderOfMurmurData

%% Extract and describe ECHO-data and save as separate table
% Remove row with incomplete Echo data:
HSdata(HSdata.UNIKT_LOPENR==10492521,:) = [];

% Grade 0 appears to have been encoded as missing. Therefore, convert nan
% to 0:
HSdata.ARGRADE_T72(isnan(HSdata.ARGRADE_T72)) = 0;
HSdata.MRGRADE_T72(isnan(HSdata.MRGRADE_T72)) = 0;
HSdata.ASGRADE_T72(isnan(HSdata.ASGRADE_T72)) = 0;
HSdata.MSGRADE_T72(isnan(HSdata.MSGRADE_T72)) = 0;

%% Remove rows that have incomplete audio data
load 'usableRows.mat'
HSdata0 = HSdata;
HSdata = HSdata0(usableRows,:);
% discardedRows = setdiff(1:height(HSdata0),usableRows);
% Nusable rows = 2124
% Ntotal = 2129
% Ndiscarded = 5

%% split into validation set and training set
% note that cross-validation/model-developement-set set is the original
% {training set} + {original validation set}:
load('dataSplitJ.mat')
load('dataSplitID.mat')
HSdataTrain = HSdata(union(Jtrain0,Jval0),:);

