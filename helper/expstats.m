%function [AIC, BIC, a1, a2, tau1, tau2, tau3] = expstats(t,sf,sem)
function [AIC, BIC, fexp] = expstats(t,sf,sem)

% count = ResidenceTimeStat(inpt,'ExposureTime',0.2);
% [t,sf,sem] = survivalFunction(269,0.2,count);

fitexp = fittype('a1*exp(-tau1*t)+a2*exp(-tau2*t)+(1-a1-a2)*exp(-tau3*t)','independent','t','dependent','sf');
opt = fitoptions(fitexp);
ub = [Inf, Inf, Inf, Inf, Inf];
lb = [0, 0, 0, 0, 0];
sp = [0.0133,0.2853,0.6793,0.5895,0.3325];
opt.Weights = sem;
opt.Upper = ub;
opt.Lower = lb;
opt.StartPoint = sp;

[fexp, gofexp] = fit(t,sf,fitexp,opt);

n = length(sf);
k = length(ub)+1;
r = gofexp.sse/n;

AIC = 2*k + n*log(r);
BIC = -2*log(r) + k*log(n);
a1 = fexp.a1; a2 = fexp.a2;
tau1 = fexp.tau1; tau2 = fexp.tau2; tau3 = fexp.tau3;

end


