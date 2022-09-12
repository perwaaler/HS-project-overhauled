%% simplify cumbersome notation:
HSdata.id = HSdata.UNIKT_LOPENR;
% rename murmur grade for each location and annotator:
for aa=1:4
    s_old_ad = sprintf('MURMUR_%gGRADENR%s_T72',aa,'AD');
    s_old_sa = sprintf('MURMUR_%gGRADENR%s_T72',aa,'SA');
    s_new_ad = sprintf('murGrade%g_ad',aa);
    s_new_sa = sprintf('murGrade%g_sa',aa);
    HSdata = renamevars(HSdata,s_old_ad,s_new_ad);
    HSdata = renamevars(HSdata,s_old_sa,s_new_sa);
end

% generate new variable "mean murmur grade":
HSdata.murGrade1 = mean([HSdata.murGrade1_ad,HSdata.murGrade1_sa],2);
HSdata.murGrade2 = mean([HSdata.murGrade2_ad,HSdata.murGrade2_sa],2);
HSdata.murGrade3 = mean([HSdata.murGrade3_ad,HSdata.murGrade3_sa],2);
HSdata.murGrade4 = mean([HSdata.murGrade4_ad,HSdata.murGrade4_sa],2);

% diastolic murmur for each location:
HSdata.diastolicMur1 = HSdata.MURMUR_1DIA_REF_T72;
HSdata.diastolicMur2 = HSdata.MURMUR_2DIA_REF_T72;
HSdata.diastolicMur3 = HSdata.MURMUR_3DIA_REF_T72;
HSdata.diastolicMur4 = HSdata.MURMUR_4DIA_REF_T72;

% agreed noise for each location:
HSdata.noise1 = HSdata.MURMUR_1NOISE_REF_T72==1;
HSdata.noise2 = HSdata.MURMUR_2NOISE_REF_T72==1;
HSdata.noise3 = HSdata.MURMUR_3NOISE_REF_T72==1;
HSdata.noise4 = HSdata.MURMUR_4NOISE_REF_T72==1;

% rename grades:
HSdata = renamevars(HSdata,'ARGRADE_T72','ARgrade');
HSdata = renamevars(HSdata,'MRGRADE_T72','MRgrade');
HSdata = renamevars(HSdata,'ASGRADE_T72','ASgrade');
HSdata = renamevars(HSdata,'MSGRADE_T72','MSgrade');

% rename clinical variables:
HSdata = renamevars(HSdata,'DIABETES_T7','diabetes');
HSdata = renamevars(HSdata,'DYSPNEA_CALMLY_FLAT_T7','dyspneaCalmlyFlat');
HSdata = renamevars(HSdata,'DYSPNEA_FAST_UPHILL_T7','dyspneaFastUpphill');
HSdata = renamevars(HSdata,'DYSPNOE_REST_T7','dyspneaRest');
HSdata = renamevars(HSdata,'ANGINA_T7','angina');
HSdata = renamevars(HSdata,'PO2_T72','po2');
HSdata = renamevars(HSdata,'PULSESPIRO_T72','pulseSpiro');
HSdata = renamevars(HSdata,'CHEST_PAIN_NORMAL_T7','chestPainNormal');
HSdata = renamevars(HSdata,'CHEST_PAIN_FAST_T7','chestPainFast');
HSdata = renamevars(HSdata,'CHEST_PAIN_ACTION_T7','chestPainAction');
HSdata = renamevars(HSdata,'AGE_T7','age');
HSdata = renamevars(HSdata,'BMI_T7','bmi');
HSdata = renamevars(HSdata,'SEX_T7','sex');
HSdata = renamevars(HSdata,'AVMEANPG_T72','avmeanpg');
HSdata = renamevars(HSdata,'AVAVMAX_T72','avarea');
HSdata = renamevars(HSdata,'SMOKE_DAILY_Q2_T7','smoke');

%% generate convenience variables:
% VHD predictors:
HSdata.dyspneaRestOrFlat = myor(HSdata.dyspneaRest, HSdata.dyspneaCalmlyFlat,"and");
HSdata.anginaOrDyspnea   = myor(HSdata.angina, HSdata.dyspneaRestOrFlat,"and");
HSdata.chestPain = myor(HSdata.chestPainNormal, HSdata.chestPainFast,"and");
HSdata.highBP    = compare(HSdata.HIGH_BLOOD_PRESSURE_T7,'>',0);
% symptomatic regurgitation:
HSdata.ARsigSympt = and(HSdata.ARgrade>=3,HSdata.anginaOrDyspnea>0);
HSdata.MRsigSympt = and(HSdata.MRgrade>=3,HSdata.anginaOrDyspnea>0);

% create current smoker column:
HSdata.smokeCurrent = compare(HSdata.smoke,"==",1);
% create [previous or current smokers]:
HSdata.smoke    = compare(HSdata.smoke,"<=",2);
% combine those that have or have had angina pectoris:
HSdata.angina   = compare(HSdata.angina,">",0); 
% combine those who have or have had diabetes
HSdata.diabetes = compare(HSdata.diabetes,">",0); 

% find cases where all positions had noisy audio:
HSdata.noiseOnly = myand({HSdata.noise1,HSdata.noise2,HSdata.noise3,HSdata.noise4});
% find samples with at least one clean audio:
HSdata.atleastOneClean = ~HSdata.noiseOnly;
% diastolic murmur in atleast 1 position:
HSdata.diastMurAtLeastOne = myor({HSdata.diastolicMur1,...
                                  HSdata.diastolicMur2,...
                                  HSdata.diastolicMur3,...
                                  HSdata.diastolicMur4});
                           

HSdata.murGradeSum = sum([HSdata.murGrade1,HSdata.murGrade2,HSdata.murGrade3,HSdata.murGrade4],2);
HSdata.murGradeMax = max([HSdata.murGrade1,HSdata.murGrade2,HSdata.murGrade3,HSdata.murGrade4],[],2);

%% Redefining AS from mean-pressure-gradient:
% note: if avmeanpg was not available, then the original AS grade was used
% as as the grade for the participant. There were 23 such cases.
HSdata.ASgrade0 = HSdata.ASgrade;

Iavmpg_none     = HSdata.avmeanpg<15;
Iavmpg_mild     = and(15<=HSdata.avmeanpg, HSdata.avmeanpg<20);
Iavmpg_moderate = and(20<=HSdata.avmeanpg, HSdata.avmeanpg<40);
Iavmpg_severe   = and(40<=HSdata.avmeanpg, HSdata.avmeanpg<inf);

HSdata.ASgrade(Iavmpg_none) = 0;
HSdata.ASgrade(Iavmpg_mild) = 1;
HSdata.ASgrade(Iavmpg_moderate) = 2;
HSdata.ASgrade(Iavmpg_severe)   = 3;

%% add column with indicator variable for significant VHD (def. by grade)
T = [HSdata.ARgrade>=3,HSdata.MRgrade>=3,HSdata.ASgrade>=1,HSdata.MSgrade>=1];
T = sum(T,2)>0;
HSdata.sigVHD31 = T;

T = [HSdata.ARgrade>=4,HSdata.MRgrade>=4,HSdata.ASgrade>=1,HSdata.MSgrade>=1];
T = sum(T,2)>0;
HSdata.sigVHD41 = T;

%% add column with indicator variable for significant VHD (def. by grade and symptoms)
T = [HSdata.ARsigSympt>0,HSdata.MRsigSympt>0,HSdata.ASgrade>=1,HSdata.MSgrade>=1];
T = sum(T,2)>0;
HSdata.sigSymptVHD = T;

%% add column with indicator variable for significant assymptomatic VHD:
HSdata.sigAsymptVHD = myor({and(HSdata.ARgrade>2, HSdata.anginaOrDyspnea==0),...
                            and(HSdata.MRgrade>2, HSdata.anginaOrDyspnea==0),...
                            and(HSdata.ASgrade>0, HSdata.anginaOrDyspnea==0),...
                            and(HSdata.MSgrade>0, HSdata.anginaOrDyspnea==0)});

%% get rows with atleast one usable (non-noisy) recording:
I = unionIterated({HSdata.noise1==0,HSdata.noise2==0,...
                    HSdata.noise3==0,HSdata.noise4==0},"logical");
HSdata.atleastOneClean = I;
