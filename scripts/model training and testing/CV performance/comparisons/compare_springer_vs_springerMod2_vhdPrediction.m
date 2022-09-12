load CVresults_netMurRegAllPos_valStop_overTrain.mat
CVresults1 = CVresults;
load CVresults_netMurRegAllPos_valStop_SpringerSeg.mat
CVresults2 = CVresults;

targetType = "AS";
classThr = 2;
[predPerf1,S1,All1] = CV_VHDpred_performanceSummary(CVresults1,targetType,classThr,HSdata)
[predPerf2,S2,All2] = CV_VHDpred_performanceSummary(CVresults2,targetType,classThr,HSdata)


AUC1 = predPerf1.murPred.allPos.(targetType).g2.auc;
AUC2 = predPerf2.murPred.allPos.(targetType).g2.auc;

D = (AUC1-AUC2)*100
pValue(D)

c1 = corr(All1.activ,HSdata.avmeanpg(All1.J),'rows','complete')
c2 = corr(All2.activ,HSdata.avmeanpg(All2.J),'rows','complete')

(c1-c2)*100