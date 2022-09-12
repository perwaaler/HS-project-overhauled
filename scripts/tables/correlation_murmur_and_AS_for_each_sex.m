
I_male   = HSdata.sex==1;
I_female = HSdata.sex==0;

c_male = corr(HSdata.avmeanpg(I_male), HSdata.murGradeSum(I_male),'rows','complete')
c_female = corr(HSdata.avmeanpg(I_female), HSdata.murGradeSum(I_female),'rows','complete')

c_male = round(c_male,3);
c_female = round(c_female,3);
table(c_male,c_female,'var',["male" "female"],'row',"correlation AVmeanPG with avg. murmur")