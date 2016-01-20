function [mobileDispl, mobile, immobile] = findMobileTraj(data, cf)

% FINDSTEPS finds the path distance, the path's total displacement and the
% number of steps in each path for the trajectories in DATA. If the average
% displacement is less than 200 nm, the molecule is considered "immobile."
% Input:
%   - DATA: a cell array with each cell containing coordinates in pixels
%   mapping out the trajectory of a particle
%   - CF: conversion factor to get to microns - must know what input and
%   output units you're dealing with!
% Output:
%   - MOBILEDISPL: A cell array with each cell representing all the data
%   available for a given "step size" for mobile molecules
%   - MOBILE: The number of mobile molecules found.
%   - IMMOBILE: The number of immobile molecules found.

% Find the lengths of each of the trajectories 
numSteps = zeros(1,length(data));
for i = 1:length(data) 
    [numSteps(i), ~] = size(data{i}); % Record the number of steps taken for all of the paths in the video
end

% Find the path-independent displacement for a given number of step sizes,
% for molecules of a desired range of path lengths and/or residence times
maxNumSteps = max(numSteps);
Displacement = cell(maxNumSteps,1);
EucDist = cell(size(data));
immobile = 0; mobile = 0;
% numLongPaths = 0; numShortPaths = 0;
for i = 1:length(data)
    % Find the Euclidean distance from the origin, with the origin moving
    % to the next molecule in the path after each summing is complete
    % Then convert this to a matrix so that each number at i, j is the
    % distance between points i and j
    EucDist{i} = squareform(pdist(data{i})); % Store the Euclidean distances of each trajectory in the cell array EucDist
    S = EucDist{i}; % Convert the distplacements into the squareform so that it's easier to extract the distances between a given number of points    
    if mean(mean(S)) < 0.2 % if the average displacement is less than 200 nm, it's immobile
        immobile = immobile + 1;
        continue
    else
        for j = 1:maxNumSteps
            try % Use try-catch for when j goes beyond the dimensions of the current trajectory
                if i > 1
                    Displacement{j} = [Displacement{j}; diag(S,j)*cf]; % Concatenate with the previous diagonal
                else
                    Displacement{j} = diag(S,j)*cf; % Each diagonal in S is the displacements for a number of time steps, and num steps increases with j
                end
            catch
                continue
            end
        end
    end
    mobile = mobile + 1;
end

mobileDispl = cell(size(Displacement));
for i = 1:length(mobileDispl)
mobileDispl{i} = Displacement{i}(Displacement{i} ~= 0);
end
