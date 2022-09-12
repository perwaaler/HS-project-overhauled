
I_fat  = HSdata.bmi>=30;
I_thin = ~I_fat;

Y_avmeanpg = HSdata.avmeanpg;
Y_murGrade = HSdata.murGradeSum;
corr(Y_avmeanpg(I_fat),Y_murGrade(I_fat),'row','complete')
corr(Y_avmeanpg(I_thin),Y_murGrade(I_thin),'row','complete')
%%
mean(Y_avmeanpg(I_fat),'o')
mean(Y_avmeanpg(I_thin),'o')