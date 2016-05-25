function [AIC, BIC, fp] = powerstats(t,sf,sem)

% count = ResidenceTimeStat(inpt,'ExposureTime',0.2);
% [t,sf,sem] = survivalFunction(269,0.2,count);

opt2 = fitoptions('power1','Weights',sem);

[fp,gofp] = fit(t,sf,'power1',opt2);

n = length(sf);
k = 3;
r = gofp.sse/n;

AIC = 2*k + n*log(r);
BIC = -2*log(r) + k*log(n);
% a = fp.a; b = fp.b;
end
