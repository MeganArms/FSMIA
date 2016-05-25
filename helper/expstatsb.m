%function [AIC, BIC, a1, a2, tau1, tau2, tau3] = expstats(t,sf,sem)
function [BIC, fexp] = expstatsb(t,sf,sem)

% count = ResidenceTimeStat(inpt,'ExposureTime',0.2);
% [t,sf,sem] = survivalFunction(269,0.2,count);

fitexp = fittype('a1*exp(-t/tau1)+a2*exp(-t/tau2)+a3*exp(-t/tau3)+(1-a1-a2-a3)*exp(-t/tau4)','independent','t','dependent','sf');
opt = fitoptions(fitexp);
ub = [1, 1, 1, Inf, Inf, Inf, Inf];
lb = [0, 0, 0, 0, 0, 0, 0];
sp = [0.2506,0.3843,0.4815,0.4564,0.8617,0.1366,0.9655];
opt.Weights = sem;
opt.Upper = ub;
opt.Lower = lb;
opt.StartPoint = sp;

[fexp, gofexp] = fit(t,sf,fitexp,opt);

n = length(sf);
k = length(ub)+1;
r = gofexp.sse/n;

%AIC = 2*k + n*log(r);
BIC = -2*log(r) + k*log(n);
% a1 = fexp.a1; a2 = fexp.a2;
% tau1 = fexp.tau1; tau2 = fexp.tau2; tau3 = fexp.tau3;

end


