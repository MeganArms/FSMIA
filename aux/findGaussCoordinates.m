function gaussCoordinates = findGaussCoordinates(obj)

% This function gets the Gaussian fitted coordinates of the molecule
% trajectories. 
%   Input: global variables MOLECULE, OPTION and RESULT 
%   Output: GAUSSCOORDINATES cell array in microns. 
% Each cell contains a matrix with the I and J coordinates of the points in
% the trajectory. Column 1 contains I, and column 2 contains J. For
% example, the 17th path is located in the 17th cell. The coordinates of
% this path are accessed as gaussCoordinates{17} if you want the coordinate
% values (e.g. [371, 124; 371, 123]), or as gaussCoordinates(17) if you
% want the matrix containing the coordinate values (e.g. [2x2 double]).

Molecule = obj.Molecule;
Option = obj.Option;
Result = obj.Result;
gaussCoordinates = cell(length(Result),1);
cs = Option.pixelSize/1000; % Coordinate scaling factor from pixels to microns
ps = 1/1000; % Parameter scaling factor from nanometers to microns

for i = 1:length(Result)
    moleculesInTrajectory = Result(i).trajectory; % Get molecular indices
    moleculeTrajectoryCoordinates = zeros(length(moleculesInTrajectory),2); % allocate array for the number of frames that the trajectory crosses
    for j = 1:length(moleculesInTrajectory)
        currentMolecule = moleculesInTrajectory(j); % Progress through each of the molecular indices
        if isnan(currentMolecule)
            currentMolecule = previousMolecule; % If the current molecule is too dim, use the coordinates of the previous molecule
        else
            previousMolecule = currentMolecule; % If the current molecule is bright enough, save it as the previous molecule in case it goes dim in the next frame
        end
        try
            % Save the precise coordinate for each of the molecules
            moleculeTrajectoryCoordinates(j,1) = cs*Molecule(currentMolecule).coordinate(1) ...
                + ps*Molecule(currentMolecule).fit.y0;
            moleculeTrajectoryCoordinates(j,2) = cs*Molecule(currentMolecule).coordinate(2) ...
                + ps*Molecule(currentMolecule).fit.x0;
        catch
            disp(num2str(currentMolecule))
        end
    end
    gaussCoordinates{i} = moleculeTrajectoryCoordinates;
end

end