%function [RSSexp,BICse,RSSp,BICsp] = traintest

% Target pdf
f = @(t) 0.73*exp(-t/0.59) + 0.19*exp(-t/2.6) + 0.069*exp(-t/10.6) + 0.0135*exp(-t/69);
M = 1; N = 1e5; B = 2*[1,150];
idcs = 1:N;

ntest = .3*N; ntrain = .7*N;
nstrap = 10;
BICse = zeros(nstrap,1); BICsp = zeros(nstrap,1);
d = zeros(nstrap,4); db = zeros(nstrap,4); steps = 2:2:300;
for i = 1:1
    % Simulate lifetime data
    X = sampleDist(f,M,N,B,false);
    
    % Get testing and training sets
    trainsetidx = randsample(N,ntrain);
    testsetidx = idcs(~ismember(idcs,trainsetidx));
    trainset = X(trainsetidx);
    testset = X(testsetidx);
    tncount = histcounts(trainset,150,'Normalization','probability');
    ttcount = histcounts(testset,150,'Normalization','probability');    

    % db contains the average and SD for the BIC for each bootstrapping
    % attempt on the training set - want the parameters for the fit of
    % each, but why? Can't just take the mean of the values...
    estattrainb = bootstrp(nstrap,@expstatsb,steps',tncount',sqrt(tncount)');
    pstattrainb = bootstrp(nstrap,@powerstatsb,steps',tncount',sqrt(tncount)');
    db(i,1) = mean(estattrainb); db(i,2) = std(estattrainb)/sqrt(nstrap);
    db(i,3) = mean(pstattrainb); db(i,4) = std(pstattrainb)/sqrt(nstrap);

    [trainpb, fp] = powerstatsb(steps',tncount',sqrt(tncount)');
    [traineb, fexp] = expstatsb(steps',tncount',sqrt(tncount)');

    figure, loglog(steps,tncount,'bo'), hold, plot(fp,'r-'), plot(fexp,'g-')
    loglog(steps,ttcount,'k^'), hold
    legend({'Training data - 70%','Power law fit','Exponential fit','Test data - 30%'},'Location','best')

    % Evaluate the predictive quality
    a1 = fexp.a1; a2 = fexp.a2; a3 = fexp.a3;
    tau1 = fexp.tau1; tau2 = fexp.tau2; tau3 = fexp.tau3; tau4 = fexp.tau4;
    F = a1*exp(-steps/tau1)+a2*exp(-steps/tau2)+a3*exp(-steps/tau3)+(1-a1-a2-a3)*exp(-steps/tau4);
    RSSexp = sum((F - ttcount).^2);
    BICse(i) = -2*log(RSSexp/ntrain) + 7*log(ntrain);

    a = fp.a; b = fp.b;
    g = a*steps.^b;
    RSSp = sum((g - ttcount).^2);
    BICsp(i) = -2*log(RSSp/ntrain) + 2*log(ntrain);
end
