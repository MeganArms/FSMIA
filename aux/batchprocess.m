function batchprocess
clear
folderIn = uigetdir('/Users/MeganArmstrong 1/Documents/Hess Lab/BSA Project/Corina Data');
folderOut = [folderIn, '/out'];
dirListing = dir(folderIn);
numFiles = length(dirListing);
exptime = 0.2; % seconds

allDisplacements = [];
allCounts = [];
allLogCounts = [];
allCoordinates = [];
allSizes = [];
allTraj = [];

initialvars = who;

for i = 4:numFiles
    clear obj
    % Initialize object
    obj = FSMIA([folderIn, '/', dirListing(i).name]);
    
    % Get threshold
    img = imread([folderIn, '/', dirListing(i).name],'Index',100);
    obj.Option.illumination = 'on';
    if strcmp(obj.Option.illumination,'on')
        % High pass filtering to remove uneven background
        [M,~] = size(img);
        mid = floor(M/2)+1;
        Img = fft2(img);
        Img1 = fftshift(Img);
        Img2 = Img1;
        Img2(mid-3:mid+3,mid-3:mid+3) = min(min(Img1));
        Img2(257,257) = Img1(257,257);
        img1 = ifft2(ifftshift(Img2));
        img12 = abs(img1);
        img13 = img12-min(min(img12));
        img14 = img13/max(max(img13));
        % Mulitply pixels by the sum of their 8-connected neighbors to increase
        % intensities of particles
        outImage = imadjust(colfilt(img14,[3 3],'sliding',@colsp));
    else
        outImage = imadjust(img);
    end
    imwrite(uint16(outImage),[folderOut,'/',dirListing(i).name]);
    figure(1),imshow(outImage), th = input('Set threshold: ');
    close(figure(1))
    
    % Set options
    obj.Option.threshold = th;
    obj.Option.spotR = 5;
    obj.Option.pixelSize = 160;
    obj.Option.include = 0;
    obj.Option.exclude = 0;
    obj.Option.connectDistance = 5;
    obj.Option.ds = 1;
    obj.Option.fitting = 'fast';
    obj.Option.isolation = 'fast';
    obj.Option.bg = 1000;
    obj.Option.wavelength = 647;
    obj.Option.na = 1.49;
    
    % Begin stack analysis
    analyzestack(obj, obj.filename);
    
    % Perform analysis
    createTrajectories(obj);
    longTraj = connectShortTraj(obj,exptime);
    coords = getCoordinates(obj,'yes');
    sizes = particleSize(obj);
    [~,Displacement,~] = findSteps(coords,1);
    [msd,D] = Dcoeff(Displacement,exptime);
    logcount = logResidenceTimeStat(coords,'ExposureTime',exptime);
    [logT,logSF] = logSurvivalFunction(obj,exptime,logcount);
    count = ResidenceTimeStat(coords,'ExposureTime',exptime);
    [T,SF] = survivalFunction(obj,exptime,count);
    [dSF, ~] = diffSurvival(Displacement,exptime,1,1,100);
    
    % Save output
    save([folderOut,'/',dirListing(i).name(1:end-3),'mat']);
    
    % Collect results
    allTraj = [allTraj, longTraj];
    allCoordinates = [allCoordinates; coords];
    allSizes = [allSizes; sizes];
    allDisplacements = [allDisplacements; Displacement];
    allCounts = [allCounts, count];
    allLogCounts = [allLogCounts, logcount];
    clearvars('-except',initialvars{:},'i','initialvars')
    fprintf('%d videos analyzed!\n',i-3);
end
save('CollectedResults.mat','allTraj','allCoordinates','allSizes','allDisplacements','allCounts','allLogCounts');

end

