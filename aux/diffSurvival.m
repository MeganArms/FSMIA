 function SF = diffSurvival(displ, lagtime, varargin)

% DIFFSURVIVAL finds the cumulated square displacement distribution,
% or survival function, as described in Kastantin & Schwartz 2012.
% 
% INPUT
%   DISPL - File with sub-diffraction displacements for each lag time (time
%   step) at a new cell.
%   LAGTIME - Exposure time + delay between exposures
%   VARARGIN - Specify the fraction of possible lag times to analyze
%   (NUMLAGS), specify the minimum residence time of a molecule in seconds
%   (MINLIFE), specify the maximum number of points to output in each CSDD
%   for plotting (NUMPLOT). Default values are (0.1,1,50) respectively.
% 
% OUTPUT
%   SF - Reliability function of squared displacements. This a cell, in
%   which each cell corresponds to a different lag time. All points are
%   output to this file for analysis.
%   SFPLOT - Reliability function of squared displacements with a sample of
%   points for faster plotting and fitting.
displ = displ(~cellfun(@isempty,displ));
numFrames = length(displ);
T = numFrames*lagtime;
if ~isempty(varargin)
    numlags = varargin{1}; minlife = varargin{2}; numplot = varargin{3};
else
    numlags = 0.1; minlife = 1; numplot = 50;
end

timelags = minlife:lagtime:T;
L = length(timelags);
lags2analyze = round(linspace(1,L,numlags*L));
idxs = 1:length(lags2analyze);

SF = cell(length(lags2analyze)-1,1); SFplot = SF;
for i = 1:length(lags2analyze)-1
    % dt = lags2analyze(i);
    idx = idxs(i);
    % Get square displacements over lag time
    % sqdispl = displ{idx}.^2/4/dt;
    sqdispl = displ{idx}.^2;
    SF{idx}(:,1) = sort(sqdispl);
    % Get cumulated square displacement distribution
    M = length(sqdispl);
    k = 1:M;
    SF{idx}(:,2) = 1 - k/M;
    % Save points for faster plotting
    if numplot < M
        pts2plot = round(linspace(1,M,numplot));
    else
        pts2plot = M;
    end
    SFplot{idx} = SF{idx}(pts2plot,:);
    SFplot{idx} = SFplot{idx}(SFplot{idx}(:,1)~=0,:);
end
