function createTrajectories(obj)
% CREATETRAJECTORIES Connects molecules between frames to create a path
% described by the molecule index number.
% INPUT
% - 

Molecule = obj.Molecule;
Frame = obj.Frame;
obj.Result = struct([]);

NumMoleculeLastFrame = length(Frame(end).MoleculeIndex);
N_frame = length(Frame);

N2 = length(Molecule) - NumMoleculeLastFrame;
k = 1;
for i = 1:N2
    % Judge if the molecule is the start of trajectory
    if ~isempty(Molecule(i).To) && isempty(Molecule(i).From)
        temp = zeros(1,N_frame);
        temp(1) = i;
        current = i;
        j = 2;
        while ~isempty(Molecule(current).To)
            temp(j) = Molecule(current).To;
            current = Molecule(current).To;
            j = j+1;
        end
        path = nonzeros(temp);
        obj.Result(k).trajectory = path;
        k = k+1;
    end
end
end
