clear rr

%% risk ratios
X = HSdata.murGradeMaxAP>=2;
Y = HSdata.avmeanpg>=10;



rr.mg2.men_avmeanpg10 = condProb(Y,and(X,HSdata.sex==1)) / condProb(Y,HSdata.sex==1)
rr.mg2.wom_avmeanpg10 = condProb(Y,and(X,HSdata.sex==0)) / condProb(Y,HSdata.sex==0)
Y = HSdata.avmeanpg>=15;
rr.mg2.men_avmeanpg15 = condProb(Y,and(X,HSdata.sex==1)) / condProb(Y,HSdata.sex==1)
rr.mg2.wom_avmeanpg15 = condProb(Y,and(X,HSdata.sex==0)) / condProb(Y,HSdata.sex==0)
Y = HSdata.avmeanpg>=20;
rr.mg2.men_avmeanpg20 = condProb(Y,and(X,HSdata.sex==1)) / condProb(Y,HSdata.sex==1)
rr.mg2.wom_avmeanpg20 = condProb(Y,and(X,HSdata.sex==0)) / condProb(Y,HSdata.sex==0)

rr.mg2
%%
corr(HSdata.murGrade1(HSdata.sex==1),HSdata.avmeanpg(HSdata.sex==1),'rows','complete')
corr(HSdata.murGrade1(HSdata.sex==0),HSdata.avmeanpg(HSdata.sex==0),'rows','complete')
%%
condProb(HSdata.ASgrade>1,and(HSdata.murGradeSum*0.25>2,HSdata.sex==0))...
        /condProb(HSdata.ASgrade>1,HSdata.sex==0)
    
condProb(HSdata.ASgrade>1,and(HSdata.murGradeSum*0.25>2,HSdata.sex==0))...
        /condProb(HSdata.ASgrade>0,HSdata.sex==0)