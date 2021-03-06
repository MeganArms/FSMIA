function batchprocess
% load('/Users/MeganArmstrong 1/Documents/Hess Lab/BSA Project/Corina Data/20140514/80C/out/2014-05-14_BSA_flowcell_pluronic_80C_exp200ms_l10_EM200.mat');
% clearvars('-except','allDisplacements','allCounts','allLogCounts','allCoordinates','allSizes','allTraj');
clear
folderIn = uigetdir('/Users/MeganArmstrong 1/Documents/Hess Lab/Langmuir Communication/BSA Project/Corina Movies');
folderOut = [folderIn, '/out']; %filtered images + filtered
dirListing = dir(folderIn); %struct - nb of files+names
numFiles = length(dirListing);
exptime = 0.2; % seconds

allDisplacements = cell(298,1);%298 frames
allCounts = []; %histogram data, stacks vertically
allLogCounts = [];
allCoordinates = []; %all the individual trajectories 
allSizes = []; %gaussian or disk 
allTraj = []; %all molecular indices

initialvars = who; %all variables in the workspace

for i = 4:numFiles
    if dirListing(i).isdir %is directory -> next file
        break
    end
    clear obj
    % Initialize object
    obj = FSMIA([folderIn, '/', dirListing(i).name]);
    
    % Get threshold
    img = imread([folderIn, '/', dirListing(i).name],'Index',100);
    obj.Option.illumination = 'on';
    if strcmp(obj.Option.illumination,'on')
        % High pass filtering to remove uneven background
        [M,~] = size(img); %tilda to say don't care
        mid = floor(M/2)+1; %midpoint
        Img = fft2(img);
        Img1 = fftshift(Img); %low frequency in center
        Img2 = Img1;
        Img2(mid-9:mid+9,mid) = min(min(Img1)); %3x3 square around the midpoint
        Img2(mid,mid-13:mid+13) = min(min(Img1));
<<<<<<< HEAD
        Img2(257,257) = Img1(257,257);%fix
        img1 = ifft2(ifftshift(Img2));
        img12 = abs(img1);
=======
        Img2(257,257) = Img1(257,257); 
        img1 = ifft2(ifftshift(Img2)); % shifting back
        img12 = abs(img1); %magnitude
>>>>>>> thresholdfix2
        img13 = img12-min(min(img12));
        img14 = img13/max(max(img13)); %btw 0 and 1
        % Mulitply pixels by the sum of their 8-connected neighbors to increase
        % intensities of particles
        outImage = imadjust(colfilt(img14,[3 3],'sliding',@colsp));
<<<<<<< HEAD
        % outImage = imadjust(img14);
=======
        %outImage = imadjust(img14);
>>>>>>> thresholdfix2
    else
        outImage = imadjust(img);
    end
    imwrite(uint16(outImage),[folderOut,'/',dirListing(i).name]);
    figure(1),imshow(outImage), th = input('Set threshold: '); 
    bg = input('Set background: ');
    close(figure(1))
    
    % Set options
    obj.Option.threshold = th;
    obj.Option.spotR = 5; %radius in pixels
    obj.Option.pixelSize = 160;
    obj.Option.include = 0;
    obj.Option.exclude = 0;
    obj.Option.connectDistance = 5; %
    obj.Option.ds = 1;
    obj.Option.fitting = 'fast'; %gaussian or dist
    obj.Option.isolation = 'fast'; %always
    obj.Option.bg = bg;
    obj.Option.wavelength = 647;
    obj.Option.na = 1.49;
    
    % Begin stack analysis
    analyzestack(obj, obj.filename);
    % Save output
    save([folderOut,'/',dirListing(i).name(1:end-3),'mat']);
    
    % Perform analysis
    createTrajectories(obj);
    longTraj = connectShortTraj(obj,exptime);
    coords = getCoordinates(obj,'yes');
    sizes = particleSize(obj);
    [~,Displacement,~] = findSteps(coords,1);
    [msd,D] = Dcoeff(Displacement,exptime);
    logcount = logResidenceTimeStat(coords,'ExposureTime',exptime);
    [logT,logSF] = logSurvivalFunction(298,exptime,logcount);%not used
    count = ResidenceTimeStat(coords,'ExposureTime',exptime);
    [T,SF] = survivalFunction(298,exptime,count);
    dSF = diffSurvival(Displacement,exptime,1,1,100);
    
    % Save output
    save([folderOut,'/',dirListing(i).name(1:end-3),'mat']);
    
    % Collect results
    allTraj = [allTraj, longTraj];
    allCoordinates = [allCoordinates; coords];
    allSizes = [allSizes; sizes];
    for k = 1:length(Displacement)
        allDisplacements{k} = [allDisplacements{k}; Displacement{k}];
    end
    allCounts = [allCounts, count];
    allLogCounts = [allLogCounts, logcount];
    clearvars('-except',initialvars{:},'i','initialvars')
    fprintf('%d videos analyzed!\n',i-3);
end
save('CollectedResults.mat','allTraj','allCoordinates','allSizes','allDisplacements','allCounts','allLogCounts');

end

