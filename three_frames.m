Molecule = obj.Molecule;
Traj=obj.Result;

MoleculeIndices = (1:length(Molecule))';
MoleculesAnalyzed = zeros(length(Molecule),1); 
S = zeros(2*length(Traj),4);
L = length(Traj);
% S2=S1;

for i = 1:length(Traj)
    Size = zeros(length(Traj(i).trajectory),2);
    Width = zeros(length(Traj(i).trajectory),1);
    for j = 1:length(Traj(i).trajectory)
        if ~isnan(Traj(i).trajectory(j))
           mIndex = Traj(i).trajectory(j);
           if isfield(Molecule,'fit') %gaussian
               Width(j) = Molecule(mIndex).fit.sigma;
               [Size(j,1), Size(j,2)] = fitVolume(mIndex,Molecule);
               obj.Molecule(mIndex).volume = Size(j,1);
               obj.Molecule(mIndex).maxInt = Size(j,2);
           elseif isfield(Molecule,'area') %centroid -> fast
               a = Molecule(mIndex).area;
               Width(j) = sqrt(a/pi);
               Size(j,1) = Molecule(mIndex).volume;
               Size(j,2) = Molecule(mIndex).maxInt;
           end
           MoleculesAnalyzed = MoleculesAnalyzed + MoleculeIndices.*(MoleculeIndices == Traj(i).trajectory(j));
        end
    end
    if ge(length(Traj(i).trajectory),4)
    S(i,:) = [max(Size(:,1)), max(Size(:,2)), length(Traj(i).trajectory), mean(Width)];
    elseif length(Traj(i).trajectory)==3
    S(i+L,:) = [max(Size(:,1)), max(Size(:,2)), length(Traj(i).trajectory), mean(Width)];
    end
end

% for i = 1:length(Traj)
%     if length(Traj(i).trajectory)==3
%     Size = zeros(length(Traj(i).trajectory),2);
%     Width = zeros(length(Traj(i).trajectory),1);
%     for j = 1:length(Traj(i).trajectory)
%         if ~isnan(Traj(i).trajectory(j))
%            mIndex = Traj(i).trajectory(j);
%            if isfield(Molecule,'fit') %gaussian
%                Width(j) = Molecule(mIndex).fit.sigma;
%                [Size(j,1), Size(j,2)] = fitVolume(mIndex,Molecule);
%                obj.Molecule(mIndex).volume = Size(j,1);
%                obj.Molecule(mIndex).maxInt = Size(j,2);
%            elseif isfield(Molecule,'area') %centroid -> fast
%                a = Molecule(mIndex).area;
%                Width(j) = sqrt(a/pi);
%                Size(j,1) = Molecule(mIndex).volume;
%                Size(j,2) = Molecule(mIndex).maxInt;
%            end
%            MoleculesAnalyzed = MoleculesAnalyzed + MoleculeIndices.*(MoleculeIndices == Traj(i).trajectory(j));
%         end
%     end
%     S2(i,:) = [max(Size(:,1)), max(Size(:,2)), length(Traj(i).trajectory), mean(Width)];
%     end
% end
% 
% S=[S1;S2];
for i=size(S,1):-1:1
    if all(S(i,:))==0
        S(i,:)=[];
    end
end