function volIntegrals = intensitySigma(obj,varargin)

% Analyze the input Molecule file for the frequency of fluorescence intensities 
% Input data should be the Molecule file.
% Output data is the histogram of intensities for this Molecule file, and
% the volume integrals of all the molecules found in this video. The
% volIntegrals variable should be concatenated over all the trials (of one
% experimental condition) to get the overall histogram of intensities.

Molecule = obj.Molecule;
longTraj = obj.Result;
% Analyze molecules that appear on multiple frames and get their average
% intensities
MoleculeIndices = (1:length(Molecule))';
MoleculesAnalyzed = zeros(length(Molecule),1); volIntegrals = zeros(length(longTraj),4);
for i = 1:length(longTraj)
    individualIntegral = zeros(length(longTraj(i).trajectory),2);
    individualSigma = zeros(length(longTraj(i).trajectory),1);
    for j = 1:length(longTraj(i).trajectory)
        if ~isnan(longTraj(i).trajectory(j))
           mIndex = longTraj(i).trajectory(j);
           individualIntegral(j,:) = fitVolume(mIndex,Molecule);
           individualSigma(j) = Molecule(mIndex).fit.sigma;
           MoleculesAnalyzed = MoleculesAnalyzed + MoleculeIndices.*(MoleculeIndices == longTraj(i).trajectory(j));
        end
    end
    volIntegrals(i,:) = [max(individualIntegral(:,1)), max(individualIntegral(:,2)), length(longTraj(i).trajectory), mean(individualSigma)];
end

% Analyze molecules that appear on only one frame

MoleculesRemaining = MoleculeIndices(MoleculeIndices ~= MoleculesAnalyzed);
starti = length(volIntegrals)+1;
volIntegrals = [volIntegrals; zeros(length(MoleculesRemaining),4)];
for i = starti:length(volIntegrals)
    mIndex = MoleculesRemaining(i-starti+1);
    [volInt, maxInt] = fitVolume(mIndex, Molecule);
    volIntegrals(i,:) = [volInt, maxInt, 1, Molecule(mIndex).fit.sigma];
end

% Scale the intensities to counts from counts*um^2
[obj.Intensity, ~] = VItransform(volIntegrals, 190, 13);

    function [scaled, newVI] = VItransform(volIntegral, musigma, sdsigma)
        
        % Scale intensity integrals: Intensities were scaled over discrete bins of
        % 160 x 160 nm, so must be scaled down to a point, i.e. divided by 25600
        % nm^2. MEANSIGMA and SDSIGMA were manually determined by sampling
        % several image movie files, and this must done for each new
        % testing condition.
        
        scaled = volIntegral;
        scaled(:,1:2) = volIntegral(:,1:2)./25600;
        
        % Create a new matrix with only the molecules that are +/- three standard deviation from
        % the mean sigma fit value.
        % varname = inputname(1);
        % musigma = 150; sdsigma = 90;
        minsigma = -3*sdsigma + musigma;
        maxsigma = 3*sdsigma + musigma;
        rows2keep = scaled(:,4) > minsigma & scaled(:,4) < maxsigma;
        newVI = scaled(rows2keep,:);
        
    end

    function [volumeInt, maxInt] = fitVolume(M, Molecule)
        
        % Find the volume of the Gaussian fit for molecule M using the fit
        % f = A*exp(-((x-x_0)^2 + (y-y_0)^2)/2/sigma^2) + z_0
        % The units of the parameters are in distance (usually microns) and
        % intensity levels
        
        A = Molecule(M).fit.A;
        sigma = Molecule(M).fit.sigma;
        
        % UPDATE so as to not include the background, z_0 level
        % syms x y A x_0 y_0 sigma z_0
        % f = A*exp(-((x-x_0)^2 + (y-y_0)^2)/2/sigma^2);
        % int_fx = int(f, x, [x_0-3*sigma, x_0 + 3*sigma]);
        % int_f = int(int_fx, y, [y_0 - 3*sigma, y_0 + 3*sigma])
        %
        % int_f =
        %
        % 2*A*pi*sigma^2*erf((3*2^(1/2))/2)^2
        
        volumeInt = 2*A*pi*sigma^2*erf((3*2^(1/2))/2)^2;
        maxInt = A;
    end

% Plot intensity versus sigma and hist of intensities if plotting is on
if length(varargin) >= 1 && strcmp(varargin{1},'on')
    figure, 
    subplot(1,2,1), plot(obj.Intensity(:,4),obj.Intensity(:,1),'o');
    xlabel('Standard Deviation of Fits ({\mu}m)'), ylabel('Intensity (a.u.)');
    subplot(1,2,2), hist(obj.Intensity(:,1),100,'FaceColor','c');
    xlabel('Intensity (a.u.)'),ylabel('f(Intensity)');
    title(obj.filename(end-52:end-32));
%     edges = linspace(min(obj.Intensity(:,1)),max(obj.Intensity(:,1)));
%     counts = histc(obj.Intensity,edges);
%     subplot(1,2,2), plot(
end

% Get historgram of each fluorescence for each bin of visible time. Plot if
% plotting is on
% intensityDecayHist = hist3(volIntegrals,[100, 100]);
% if length(varargin) >= 1 && strcmp(varargin{1},'on')
%     v2plot = [volIntegrals(:,1)./length(volIntegrals), volIntegrals(:,2)*100];
%     figure, hist3(v2plot,[100, 100]);
%     xlabel('Fluorescence Intensity'), ylabel('Time Molecule Visible (ms)'), zlabel('Probability');
%     set(gcf,'renderer','opengl');
%     set(get(gca,'child'),'FaceColor','interp','CDataMode','auto');
% end

% % Get frequency (histogram) of each fluorescence intensity and plot, if 
% % plotting is on
% intensityHist = histc(volIntegrals(:,1), linspace(min(volIntegrals(:,1)),max(volIntegrals(:,1))));
% if length(varargin) >= 1 && strcmp(varargin{1},'on')
%     figure, bar(linspace(min(volIntegrals(:,1)),max(volIntegrals(:,1))), intensityHist, 'histc');
%     xlabel('Intensity Counts (a.u.)'); ylabel('Frequency of Intensity Counts');
% end
end