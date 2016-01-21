function count = logResidenceTimeStat(traj,varargin)
% LOGRESIDENCETIMESTAT calculates the distribution of residence time for
% logarithmic bin spacing.
%
% INPUT:
%   - TRAJ - input trajectory data in cell format (output of
%   GETCOORDINATES)
%   - VARARGIN: Pairwise values - 
%       - 'ExposureTime',0.05 sets the exposure time to 50 ms for bin
%       edges creation.
%       - 'Bin',vector, defines bin edges
% OUTPUT:
%   - COUNT - number of trajectories corresponding to specific residence
%   time.

reside = cellfun(@length,traj);
% Default bin edges
edges = (min(reside)-0.5):1:(max(reside)+0.5);

for pair = reshape(varargin,2,[])
    if strcmpi(pair{1},'ExposureTime') % In seconds, not milliseconds
        exposure = pair{2};
        edges = logspace(log10(2*exposure-0.5*exposure),log10(max(reside)*exposure+0.5*exposure),max(reside));
    end
    if strcmpi(pair{1},'Bin')
        edges = pair{2};
    end
end

count = histcounts(exposure*reside,edges,'Normalization','countdensity');