function longTraj = connectShortTraj(obj,exp_time)

Result = obj.Result;
Molecule = obj.Molecule;

% exp_time = exp_time/1000; % Convert ms into seconds
numTrajectories = length(Result);

% Get the coordinates of the first molecule in each trajectory
firstMolecsCoords = zeros(numTrajectories,2);
for i = 1:numTrajectories
    % Test to make sure that the trajectory file is strictly increasing
    if issorted(Result(i).trajectory)
        molecIndex = Result(i).trajectory(1);
        firstMolecsCoords(i,:) = Molecule(molecIndex).coordinate(1:2);
    else
        disp([num2str(i),' is not strictly increasing'])
    end
end

% Find the distance from the origin of the x-y coordinates for the sake of 
% sorting
distFromOriginCoords = sqrt(sum(firstMolecsCoords.^2,2));

% Get the sorted indices
[~, sortedIndices] = sort(distFromOriginCoords, 1, 'ascend');

% Sort the coordinates of the first molecules in each trajectory according
% to their coordinates
sortedFirstMolecs = firstMolecsCoords(sortedIndices,:);

% Save the trajectory number that the coordinates come from. Does this need
% to be saved in the same matrix???? no.
% sortedFirstMolecs = [sortedFirstMolecs, sortedIndices]; 

% Find the difference between each consecutive coordinate pair
diffsMatrix = zeros(length(sortedFirstMolecs),2);
diffsMatrix(2:end,:) = abs(diff(sortedFirstMolecs,1,1));
% EucDistMatrix = diffsMatrix; 
EucDistMatrix = sqrt(sum(diffsMatrix.^2,2));

j = 0; k = 1; prev_i = 1;
closeTrajs = cell(1); 
for i = 2:length(diffsMatrix)
    % If the indices are close to each other, put the close trajectories in
    % the same cell, otherwise put them in a different cell. The measure
    % for this is how much greater the current index is than the size of
    % the last index that was input into the close trajectories
    if EucDistMatrix(i) <= sqrt(2) && abs(i - prev_i) == 1
        if k == 1 % Then this is the first entry in the cell. Advance j by one to create a new cell.
            j = j + 1;
            closeTrajs{1,j}(1,k) = sortedIndices(i-1); %index
            closeTrajs{1,j}(1,k+1) = sortedIndices(i);
            closeTrajs{1,j}(2:3,k) = sortedFirstMolecs(i-1,:)'; %coordinates of molecule where it was/where it is going
            closeTrajs{1,j}(2:3,k+1) = sortedFirstMolecs(i,:)';
            k = k+2;
        else % Fill the cell with the closest trajectories
            % Test the current close coordinate against all the others
            % already stored to make sure that it's close to all the rest
            % as well, otherwise just continue to the next coordinate
            [~,N] = size(closeTrajs{1,j});
            for f = N:-1:1
                if pdist([sortedFirstMolecs(i,:); (closeTrajs{1,j}(2:3,f))']) > sqrt(2)
                    store = 0;
                    break % if ANY are not close enough, do not store this molecule, go to next trajectory index
                else
                    store = 1; % set store to 1 so that this molecule coordinate is stored
                end
            end
            if store == 1 % If the molecule is close enough to all the other molecules, store it in the trajectory!
                closeTrajs{1,j}(1,k) = sortedIndices(i);
                closeTrajs{1,j}(2:3,k) = sortedFirstMolecs(i,:)';
                k = k + 1;
            else
            end
        end
        prev_i = i;
    elseif EucDistMatrix(i) <= sqrt(2) && abs(i - prev_i) > 1 % Create a new cell if the current index is too far from the prev
        k = 1; % Reset k for each cell, since the part of the if-statement will be repeated many times
        j = j+1;
        % This is the first input into this cell, so the first and second coordinates need to be stored
        closeTrajs{1,j}(1,k) = sortedIndices(i-1);
        closeTrajs{1,j}(1,k+1) = sortedIndices(i);
        closeTrajs{1,j}(2:3,k) = sortedFirstMolecs(i-1,:)';
        closeTrajs{1,j}(2:3,k+1) = sortedFirstMolecs(i,:)';
        k = k+2;
        prev_i = i;
    end
end


% Now that we have found which trajectories are actually a single
% trajectory, we must connect them!

% First, order the close trajectories according to their trajectory number,
% and keep only the trajectory numbers from the closeTrajs file
traj2connect = cell(length(closeTrajs),1);
for i = 1:length(traj2connect)
    traj2connect{i} = sort(closeTrajs{i}(1,:),2,'ascend');
end

% Now, make new trajectories out of the trajectories that are to be connected
longTraj = Result;
trajComplete = traj2connect;
traj2connect_withUpdates = traj2connect;
% Subtract the number of trajectories that the linked trajectories were
% consolidated into
% numTrajs2Remove = sum(cellfun('length',traj2connect)) - length(traj2connect);
emptyTrajNums = [];
J = 0;
i = 1;
while i <= length(traj2connect_withUpdates)
    n = length(traj2connect_withUpdates{i}); %trajectory we're at
    N = length(traj2connect_withUpdates); %Number traj left to be done
    trajComplete{i} = (Result(traj2connect_withUpdates{i}(1)).trajectory)'; % Transpose because the trajectories are in columns
    % longTraj(traj2connect{i}(1)).trajectory = []; % Set the consolidated trajectories to empty
    % replacementTrajNums(i) = traj2connect{i}(1);
    for j = 2:n;
        % Find the frame of the last molecular index of the previous
        % trajectory, and the frame of the first molecular index of the
        % current trajectory. Fill the frames inbetween with NaNs in
        % keeping with the precedent set in analyzeshorttraj.m. Start at 2
        % because the cell is initialized above.
        molInd = Result(traj2connect_withUpdates{i}(j-1)).trajectory(end);
        prevFrame = Molecule(molInd).frame;
        endmolInd = Result(traj2connect_withUpdates{i}(j)).trajectory(1);
        currentFrame = Molecule(endmolInd).frame;
        if (currentFrame - prevFrame)*exp_time <= 1 % second
            gap = currentFrame - prevFrame - 1;
            trajComplete{i} = [trajComplete{i}, NaN(1,gap), (Result(traj2connect_withUpdates{i}(j)).trajectory)'];
            % Store the trajectories that have been consolidated into the
            % first one to remove later. Do not store the trajectory number
            % into which the trajectories have been consolidated!
            emptyTrajNums(J+j-1) = traj2connect_withUpdates{i}(j);
        elseif (currentFrame - prevFrame)*exp_time > 1 && (n-j) >= 2
            % Create a new cell in the cell array for the trajectory
            % indices whose frames are far from each other, as long as
            % there are more than 2 trajectories to connect, otherwise do
            % not include this trajectory in the trajectories to connect!
            traj2connect_withUpdates{N+1} = traj2connect_withUpdates{i}(2:n);
            traj2connect_withUpdates{i}(2:n) = [];
            break
        else
            break % Go to next cell of trajectories to connect
        end
    end
    J = J + j - 2;
    % Replace the original trajectory at the current trajectory number
    % with the new complete trajectory
    longTraj(traj2connect_withUpdates{i}(1)).trajectory = trajComplete{i};
    % Advance the iteration index
    i = i + 1;
end

if ~isempty(emptyTrajNums)
    % Remove the trajectories that have been consolidated into another
    % trajectory. Must sort the empty trajectory numbers in descending order
    % otherwise that need to be deleted will change as the for-loop continues
    sortedEmptyTrajNums = sort(emptyTrajNums,'descend');
    jPrevious = 0;
    for i = 1:length(sortedEmptyTrajNums)
        j = sortedEmptyTrajNums(i);
        if j == jPrevious
            continue
        else
            longTraj(j) = [];
        end
        jPrevious = j;
    end
end

% Check for any overlapping trajectories and make consistent the dimensions
sortedTrajectories = [];
for i = 1:length(longTraj)
    [m, ~] = size(longTraj(i).trajectory);
    if m ~= 1
        longTraj(i).trajectory = longTraj(i).trajectory';
    end 
    notNAN = ~isnan(longTraj(i).trajectory); % Find the real values
    % If the real values are not sorted, then go through doubles-deleting
    if ~issorted(longTraj(i).trajectory(notNAN)) 
        hold = [0, longTraj(i).trajectory];
        differences = diff(hold);
        n = length(differences);
        indices = 1:n;
        whereNegative = indices(differences <= 0); % Negative difference indicates start of phantom trajectory
        for j = 1:length(whereNegative)
            f = whereNegative(j);
            while f < length(differences) && ~isnan(differences(f)) % NaN indicates end of phantom trajectory
                if f == length(differences)
                    f = length(differences) + 1;
                    break
                elseif j < length(whereNegative) && f == whereNegative(j + 1); % Second stop condition if there are no NaNs between this and the next traj.
                    f = whereNegative(j + 1) + 1;
                    break
                else
                    f = f+1; 
                end
            end
            indices(whereNegative(j):f-1) = []; % Delete the indices of the phantom trajectory
            differences(whereNegative(j):f-1) = []; % Delete the differences corresponding to the phantom trajectory
            numDeletedIndices = f - 1 - whereNegative(j);
            if j < length(whereNegative)
                whereNegative(j+1:end) = whereNegative(j+1:end) - numDeletedIndices;
            end
        end
        longTraj(i).trajectory = longTraj(i).trajectory(indices);
        sortedTrajectories = [sortedTrajectories; i];
    end
end

for i = 1:length(longTraj)
    obj.Molecule(longTraj(i).trajectory(1)).connectedResult = longTraj(i).trajectory';
end

disp(sortedTrajectories)

end


