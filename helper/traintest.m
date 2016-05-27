%function [RSSexp,BICse,RSSp,BICsp] = traintest

ntest = round(length(allCoordinates)*.3);
ntrain = length(allCoordinates) - ntest;
idcs = 1:length(allCoordinates);

nstrap = 10; nsamp = 100;
BICse = zeros(nstrap,1); BICsp = zeros(nstrap,1);
d = zeros(nstrap,4); db = zeros(nstrap,4); steps = 2:2:300;
% Iteratively divide up the coordinates into different train/test sets and
% bootstrap the training data to determine the accuracy of the fit to the
% training data.
for i = 1:nstrap
    count = ResidenceTimeStat(allCoordinates,'ExposureTime',0.2);
    [t,sf,sem] = survivalFunction(269,0.2,count);
    
    % Separate train and test trajectory sets
    traincoordsidx = randsample(length(allCoordinates),ntrain);
    testcoordsidx = idcs(~ismember(idcs,traincoordsidx));
    traincoords = allCoordinates(traincoordsidx);
    testcoords = allCoordinates(testcoordsidx);

    % Get the data to be fit
    traincount = ResidenceTimeStat(traincoords,'ExposureTime',0.2);
    [traint, trainsf, trainsem] = survivalFunction(269,0.2,traincount);
    tntcrop = traint(17:end); tnsfcrop = trainsf(17:end); tnsemcrop = trainsem(17:end);
   
    testcount = ResidenceTimeStat(testcoords,'ExposureTime',0.2);
    [testt, testsf, testsem] = survivalFunction(269,0.2,testcount);
    tttcrop = testt(17:end); ttsfcrop = testsf(17:end); ttsemcrop = testsem(17:end);
    
    % db contains the average and SD for the BIC for each bootstrapping
    % attempt on the training data
    estat = bootstrp(nsamp,@expstats,tntcrop',tnsfcrop',tnsemcrop');
    pstat = bootstrp(nsamp,@powerstats,tntcrop',tnsfcrop',tnsemcrop');
    d(i,1) = mean(estat); d(i,2) = std(estat)/sqrt(nsamp);
    d(i,3) = mean(pstat); d(i,4) = std(pstat)/sqrt(nsamp);

    [trainpb, fp] = powerstatsb(tntcrop',tnsfcrop',tnsemcrop');
    [traineb, fexp] = expstatsb(tntcrop',tnsfcrop',tnsemcrop');

    figure, loglog(tntcrop,tnsfcrop,'bo'), hold, plot(fp,'r-'), plot(fexp,'g-')
    loglog(tttcrop,ttsfcrop,'k^'), hold
    legend({'Training data - 70%','Power law fit','Exponential fit','Test data - 30%'},'Location','best')

    % Evaluate the predictive quality by comparing the fit on training data
    % to test data
    a1 = fexp.a1; a2 = fexp.a2; a3 = fexp.a3;
    tau1 = fexp.tau1; tau2 = fexp.tau2; tau3 = fexp.tau3; tau4 = fexp.tau4;
    f = a1*exp(-tau1*tttcrop) + a2*exp(-tau2*tttcrop) + (1-a1-a2)*exp(-tau3*tttcrop);
    RSSexp = sum((f - ttsfcrop).^2);
    BICse(i) = -2*log(RSSexp/ntrain) + 7*log(ntrain);

    a = fp.a; b = fp.b;
    g = a*tttcrop.^b;
    RSSp = sum((g - ttsfcrop).^2);
    BICsp(i) = -2*log(RSSp/ntrain) + 2*log(ntrain);
end
