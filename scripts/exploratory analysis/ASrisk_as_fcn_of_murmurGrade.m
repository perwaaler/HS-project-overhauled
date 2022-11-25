I = HSdata.avmeanpg >= 15;

close all
subplot(121)
histogram(HSdata.murGrade1_ad(I))
subplot(122)
histogram(HSdata.murGrade1_sa(I))

x = HSdata.murGradeMaxAP;
y = HSdata.avmeanpg;

thrs = 0:0.5:4;
N = numel(thrs);
Y = zeros(1, N)
for i = 1:N
    Y(i) = mean(y(x >= thrs(i)) >= 15);
end

figure
plot(thrs, Y, '-*')
title('Prob(AS | max-murmur-grade >= x)')
xlabel("x (murmur-grade threshold)")
ylabel("risk AS")

% fitglm(HSdata,"AS ~ murGrade1", )

%%
MGsa = max([HSdata.murGrade1_sa, HSdata.murGrade2_sa], [], 2);
MGad = max([HSdata.murGrade1_ad, HSdata.murGrade2_ad], [], 2);
MG = MGsa;
mean(HSdata.avmeanpg(MG == 1) >= 15) / mean(HSdata.avmeanpg(MG == 0) >= 15)
