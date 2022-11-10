close all
subplot(211)
plot(HSdata.avmeanpg,'.')
xlim([1,2124])
title('AVPGmean')

subplot(212)
plot(sqrt(HSdata.avmeanpg),'.')
xlim([1,2124])
title('sqrt(AVPGmean)')