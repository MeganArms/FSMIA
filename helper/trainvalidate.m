%function [RSSexp,BICse,RSSp,BICsp] = traintest
legnths = cellfun(@length,allCoordinates);
numdatapoints = max(lengths)-1;
ntest = round(numdatapoints*0.3);
ntrain = numdatapoints - ntest;
idcs = 1:numdatapoints;

nstrap = 4; nsamp = numdatapoints; % nsamp must be <= datapoints
BICse = zeros(nstrap,1); BICsp = zeros(nstrap,1);
d = zeros(nstrap,4); db = zeros(nstrap,4); steps = 2:2:300;
% Iteratively divide up the coordinates into different train/test sets and
% bootstrap the training data to determine the accuracy of the fit to the
% training data.
for i = 1:nstrap
    count = ResidenceTimeStat(allCoordinates,'ExposureTime',0.2);
    [t,sf,sem] = survivalFunction(numdatapoints,0.2,count);
    t = t(17:end); sf = sf(17:end); sem = sem(17:end);
    idcs = 1:length(t);
    
    % Separate train and test trajectory sets
    tnidx = randsample(length(t),ntrain);
    ttidx = idcs(~ismember(idcs,tnidx));
    tnsf = sf(tnidx); tnt = t(tnidx); tnsem = sem(tnidx);
    ttsf = sf(ttidx); ttt = t(ttidx); ttsem = sem(ttidx);

    % Get the data to be fit
    % tntcrop = traint(17:end); tnsfcrop = trainsf(17:end); tnsemcrop = trainsem(17:end);
    % tttcrop = testt(17:end); ttsfcrop = testsf(17:end); ttsemcrop = testsem(17:end);
    
    % db contains the average and SD for the BIC for each bootstrapping
    % attempt on the training data
    estat = bootstrp(nsamp,@expstats,tnt',tnsf',tnsem');
    pstat = bootstrp(nsamp,@powerstats,tnt',tnsf',tnsem');
    d(i,1) = mean(estat); d(i,2) = std(estat)/sqrt(nsamp);
    d(i,3) = mean(pstat); d(i,4) = std(pstat)/sqrt(nsamp);

    [trainpb, fp] = powerstatsb(tnt',tnsf',tnsem');
    [traineb, fexp] = expstatsb(tnt',tnsf',tnsem');
    
    % Evaluate the predictive quality by comparing the fit on training data
    % to test data
    a1 = fexp.a1; a2 = fexp.a2; a3 = fexp.a3;
    tau1 = fexp.tau1; tau2 = fexp.tau2; tau3 = fexp.tau3; tau4 = fexp.tau4;
    f = a1*exp(-tau1*ttt) + a2*exp(-tau2*ttt) + (1-a1-a2)*exp(-tau3*ttt);
    RSSexp = sum((f - ttsf).^2);
    BICse(i) = -2*log(RSSexp/ntrain) + 7*log(ntrain);

    a = fp.a; b = fp.b;
    g = a*ttt.^b;
    RSSp = sum((g - ttsf).^2);
    BICsp(i) = -2*log(RSSp/ntrain) + 2*log(ntrain);
    
    % Visualize Results
    if i <= 4
        figure, semilogy(tnt,tnsf,'o','MarkerSize',10,'MarkerFaceColor',[0.5,0.5,0.5],'MarkerEdgeColor',[0.5,0.5,0.5]), hold, plot(fp,'r-'), plot(fexp,'r--')
        semilogy(ttt,ttsf,'k^','MarkerSize',10,'MarkerFaceColor','k'), hold
        legend({'Training data - 70%','Power law fit','Exponential fit','Test data - 30%'},'Location','best')
        title(['BIC_{exp} = ',num2str(mean(BICse)),', BIC_p = ',num2str(mean(BICsp)),' for cropped sf']);
        h = gca; h.XLabel.String = 'Time (s)'; h.YLabel.String = 'p(t)'; h.FontSize = 16;
        h.Children(2).LineWidth = 2; h.Children(3).LineWidth = 2;
    end
    if i == 1
        figure,qqplot(f-ttsf),h = gca;
        h.Children(1).MarkerSize = 10; h.Children(1).LineWidth = 3;
        h.Children(2).LineWidth = 3; h.Children(3).LineWidth = 3;
        h.FontSize = 16; h.Title = []; h.YLabel.String = 'Exponential Fit Quantiles';
        figure,qqplot(g-ttsf),h = gca;
        h.Children(1).MarkerSize = 10; h.Children(1).LineWidth = 3;
        h.Children(2).LineWidth = 3; h.Children(3).LineWidth = 3;
        h.FontSize = 16; h.Title = []; h.YLabel.String = 'Power Law Fit Quantiles';
        fsave = fexp;
        gsave = fp;
    end
end
