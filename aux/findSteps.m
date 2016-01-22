function [Path, Displacement, numSteps] = findSteps(data,cf)

% FINDSTEPS finds the path distance, the path's total displacement and the
% number of steps in each path for the trajectories in DATA. 
% Input:
%   - DATA: a cell array with each cell containing coordinates in pixels
%   mapping out the trajectory of a particle
%   - CF: conversion factor to get to microns - must know what input and
%   output units you're dealing with!
% Output:
%   - PATH: cell array with the distance between each step in a trajectory
%   separated into cells by trajectory, and separated into columns by i and j
%   distances.
%   - DISPLACEMENT: A cell array with each cell representing all the data
%   available for a given "step size"
%   - NUMSTEPS: The number of steps in each trajectory, as a row vector

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
% numLongPaths = 0; numShortPaths = 0;
for i = 1:length(data)
    % Find the Euclidean distance from the origin, with the origin moving
    % to the next molecule in the path after each summing is complete
    % Then convert this to a matrix so that each number at i, j is the
    % distance between points i and j
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This block can be updated with the desired flow of analysis, i.e.
    % place the actual analysis in the if-blocks that give the desired
    % results
%     Path{i} = abs(diff(data{i},1,1))*160/1000;
%     if Path{i} < positionalAccuracy
%         % not moving
%     else
%         % moving
%     end
%     if length(data{i}) > maxNumSteps
%         numLongPaths = numLongPaths + 1;
%         % Do something with the data - analyze as normal or continue or
%         % analyze and store in a designated place
%     else
%         numShortPaths = numShortPaths + 1;
%         % Do something with the data - analyze as normal or continue
%     end
%     if ~isempty(numVirtualTrajectories) % If there is a range of desired steps, set maxNumSteps and minNumSteps
%         % set values as input
%     else
%         % continue as normal
%     end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % vvv Actual analysis below vvv
    EucDist{i} = squareform(pdist(data{i})); % Store the Euclidean distances of each trajectory in the cell array EucDist
    S = EucDist{i}; % Convert the distplacements into the squareform so that it's easier to extract the distances between a given number of points    
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

% Remove zeros that were preallocated space from the Displacement cell
% array
for i = 1:length(Displacement)
    Displacement{i} = Displacement{i}(Displacement{i} ~= 0);
    Displacement{i} = Displacement{i}(1:end-1);
end
Displacement = Displacement(~cellfun(@isempty,Displacement));

% Convert the coordinates to displacements and pixels to microns for paths
% in the desired range of paths
% positionalAccuracy = whoKnows;
Path = cell(size(data));
for i = 2:length(data)
    Path{i} = abs(diff(data{i},1,1))*cf; % Take the difference along each column (x and y coordinates) in data to find the displacements, and convert data into microns - pixels*(160 nm/pixel)/(1000 nm/um)
%     if Path{i} > positionalAccuracy
%         % Store somewhere else
%     else
%         % Store here
%     end
end
Path = Path(2:end);

end