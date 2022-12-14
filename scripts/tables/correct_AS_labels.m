% create a table-overwiew of AS-cases and non AS cases, which includes
% variables such as AVmeanPG, AV-area etc. Used to check if the AS-grades
% make sense, and if errors have been made in labelling them.

Ias = HSdata.ASgrade>0;

AStable = array2table([find(Ias),HSdata.ASgrade(Ias),HSdata.AVMEANPG_T72(Ias),...
    HSdata.AVAVMAX_T72(Ias),HSdata.AVAIVTI_T72(Ias),HSdata.AVVMEAN_T72(Ias),...
    HSdata.AVVMAX_T72(Ias), HSdata.LVSTROKEVOL_T72(Ias)],...
    'v',{'row','grade','AVmeanPG','AV-area(Vmax)(cm2)',...
    'AV-area(VTI)(cm2)','AV flow maximum velocity',...
    'AV flow mean velocity'...
    'LVstrokeVolume'});

[m,JmaxPG] = maxk(HSdata.AVMEANPG_T72(HSdata.ASgrade==0),30);
JnoAS = find(HSdata.ASgrade==0);
JnoAS = JnoAS(JmaxPG);
HSdata.AVMEANPG_T72(JnoAS)
noAShighAVMPGtable = array2table([JnoAS,HSdata.ASgrade(JnoAS),...
    HSdata.AVMEANPG_T72(JnoAS),HSdata.AVAVMAX_T72(JnoAS),...
    HSdata.AVAIVTI_T72(JnoAS),HSdata.AVVMEAN_T72(JnoAS),...
    HSdata.AVVMAX_T72(JnoAS), HSdata.LVSTROKEVOL_T72(JnoAS)],...
    'v',{'row','grade','AVmeanPG','AV-area(Vmax)(cm2)',...
    'AV-area(VTI)(cm2)','AV flow maximum velocity',...
    'AV flow mean velocity'...
    'LVstrokeVolume'});



AStable = sortrows(AStable,'grade');
noAShighAVMPGtable = sortrows(noAShighAVMPGtable,'AVmeanPG');

%% write to excel-file
writetable(noAShighAVMPGtable,'noAShighAVMPGtable.xlsx')
writetable(noAShighAVMPGtable,'AStable.xlsx')