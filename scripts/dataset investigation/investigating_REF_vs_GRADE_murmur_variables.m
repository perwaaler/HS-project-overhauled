% in this script, I do a quick check to see if the GRADE and REF
% murmur-variables are consistent.

if ~exist('HSdata','var')
    runMeAtStartUp
end

% P(MG>0 | agreed systolic murmur)
[mean(HSdata.MURMUR_1SYSSA_T72(HSdata.MURMUR_1SYS_REF_T72==1) >0 ),...
 mean(HSdata.MURMUR_2SYSSA_T72(HSdata.MURMUR_2SYS_REF_T72==1) >0 ),...
 mean(HSdata.MURMUR_3SYSSA_T72(HSdata.MURMUR_3SYS_REF_T72==1) >0 ),...
 mean(HSdata.MURMUR_4SYSSA_T72(HSdata.MURMUR_4SYS_REF_T72==1) >0 )]*100

% conclusion: grade and REF variables are not consistent.