function connectFrame(obj,f1,f2)

MoleculeIndices1 = obj.Frame(f1).MoleculeIndex;
MoleculeIndices2 = obj.Frame(f2).MoleculeIndex;
for i = 1:length(MoleculeIndices1)
    molecule1 = MoleculeIndices1(i);
    for j = 1:length(MoleculeIndices2)
        molecule2 = MoleculeIndices2(j);
        connectMolecule(obj,molecule1,molecule2);
    end
end