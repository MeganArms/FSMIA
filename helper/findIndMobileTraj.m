function [mIndDisp] = findIndMobileTraj(data,cf)

% Find and store individual trajectories
% Input:
%   - DATA: cell array containing all the coordinates for trajectories
%   - CF: Coversion factor to bring the units into um/s
% Output:
%   - MINDDISP: cell array with each cell containing all of the
%   displacements of virtual trajectories only for mobile molecules. Each
%   array corresponds to a different lag time, beginning with 1*delta_t and
%   increasing until the limit of the trajectory's length.

mIndDisplacement = cell(size(data));
for i = 1:length(data)
    [mIndDisplacement{i},~,~] = findMobileTraj(data(i),cf);
end

% Get rid of zeros - nested
mIndDisp = cell(size(mIndDisplacement));
for i = 1:length(data)
    mIndDisp{i} = mIndDisplacement{i}(~cellfun('isempty',mIndDisplacement{i}));
end

% Get rid of empty cells
mIndDisp = mIndDisp(~cellfun('isempty',mIndDisp));

%save(['mIndDisp',num2str(pH),'.mat'],'mIndDisp')

end