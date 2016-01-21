function [count, edges] = ResidenceTimeStat(traj,varargin)
% RESIDENCETIMESTAT calculates the distribution of residence time.
%
% INPUT:
%   - TRAJ - input trajectory data in cell format (output of
%   GETCOORDINATES)
% OUTPUT:
%   - COUNT - number of trajectories corresponding to specific residence
%   time.

reside = cellfun(@length,traj);
% Default bin edges
edges = (min(reside)-0.5):1:(max(reside)+0.5);

for pair = reshape(varargin,2,[])
    if strcmpi(pair{1},'ExposureTime') % In seconds, not milliseconds
        exposure = pair{2};
        edges = 2*exposure-0.5*exposure:exposure:exposure*max(reside)+0.5*exposure;
    end
    if strcmpi(pair{1},'Bin')
        edges = pair{2};
    end
end

count = histcounts(reside*exposure,edges);