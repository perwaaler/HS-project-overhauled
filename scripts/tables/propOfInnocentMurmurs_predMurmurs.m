load CVresults_netMurRegAllPos_valStop_overTrain

% *** how many murmurs detected where innocent? ***
activ_all = reshape(CVresults.val.activations,[8*4,1]);
J_all     = reshape(CVresults.val.J,[8*4,1]);

activ_all = cell2mat(activ_all);
J_all     = cell2mat(J_all);

Y_AR = HSdata.ARgrade(allJs);
Y_MR = HSdata.MRgrade(allJs);
Y_AS = HSdata.ASgrade(allJs);
Y_MS = HSdata.MSgrade(allJs);

I_innocent_1 = myand({Y_AR<=1,Y_MR<=1,Y_AS==0,Y_MS==0});
I_innocent_2 = myand({Y_AR<=2,Y_MR<=2,Y_AS==0,Y_AS==0});

thr = 2;
P(1,1) = round(condProb(I_innocent_1,activ_all>2)*100,1)
P(2,1) = round(condProb(I_innocent_1,activ_all>3)*100,1)
P(1,2) = round(condProb(I_innocent_2,activ_all>2)*100,1)
P(2,2) = round(condProb(I_innocent_2,activ_all>3)*100,1)

array2table(P,...
    'var',{'regurg. < 2 and stenosis==0','regurg. < 3 and stenosis==0'},...
    'r',["P(innocent|pred. mur. grade>2)","P(innocent|pred. mur. grade>3)"])


