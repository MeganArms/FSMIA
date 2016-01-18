function connectMolecule(obj,m1,m2)
% Connect molecules in different frames
Option = obj.Option;
MovePixel = ceil(Option.connectDistance/Option.pixelSize);
coordinate1 = obj.Molecule(m1).coordinate;
x0 = coordinate1(1);
y0 = coordinate1(2);
coordinate2 = obj.Molecule(m2).coordinate;
x = coordinate2(1);
y = coordinate2(2);

% search nearby region of molecule m1
if le(x,x0+MovePixel) && ge(x,x0-MovePixel) && le(y,y0+MovePixel) && ge(y,y0-MovePixel)
    if ~isfield(obj.Molecule(m1),'To')
        obj.Molecule(m1).To = [];
    end
    if ~isfield(obj.Molecule(m1),'From')
        obj.Molecule(m1).From = [];
    end
    if ~isfield(obj.Molecule(m2),'To')
        obj.Molecule(m2).To = [];
    end   
    if ~isfield(obj.Molecule(m2),'From')
        obj.Molecule(m2).From = [];
    end
    
    if isempty(obj.Molecule(m1).To) && isempty(obj.Molecule(m2).From)
        obj.Molecule(m1).To = m2;
        obj.Molecule(m2).From = m1;
    else
        % m1 connects to two successive molecules
        if ~isempty(obj.Molecule(m1).To)
            % if there are two neighbors, find the closer one
            m3 = obj.Molecule(m1).To;
            if isfield(obj.Molecule,'fit')
                para1 = coeffvalues(obj.Molecule(m1).fit);
                p1 = obj.Molecule(m1).coordinate*Option.pixelSize + [para1(3) para1(4)];
                para2 = coeffvalues(obj.Molecule(m2).fit);
                p2 = obj.Molecule(m2).coordinate*Option.pixelSize + [para2(3) para2(4)];
                para3 = coeffvalues(obj.Molecule(m3).fit);
                p3 = obj.Molecule(m3).coordinate*Option.pixelSize + [para3(3) para3(4)];
            elseif isfield(obj.Molecule,'area')
                para1 = obj.Molecule(m1).centroid;
                p1 = obj.Molecule(m1).coordinate*Option.pixelSize + [para1(1) para1(2)];
                para2 = obj.Molecule(m2).centroid;
                p2 = obj.Molecule(m2).coordinate*Option.pixelSize + [para2(1) para2(2)];
                para3 = obj.Molecule(m3).centroid;
                p3 = obj.Molecule(m3).coordinate*Option.pixelSize + [para3(1) para3(2)];
            end
            if pdist([p1;p2]) < pdist([p1;p3])
                obj.Molecule(m1).To = m2;
                obj.Molecule(m2).From = m1;
                obj.Molecule(m3).From = [];
            end
        % m2 connect to two previous molecules    
        else
            m3 = obj.Molecule(m2).From;
            if isfield(obj.Molecule,'fit')
                para1 = coeffvalues(obj.Molecule(m1).fit);
                p1 = obj.Molecule(m1).coordinate*Option.pixelSize + [para1(3) para1(4)];
                para2 = coeffvalues(obj.Molecule(m2).fit);
                p2 = obj.Molecule(m2).coordinate*Option.pixelSize + [para2(3) para2(4)];
                para3 = coeffvalues(obj.Molecule(m3).fit);
                p3 = obj.Molecule(m3).coordinate*Option.pixelSize + [para3(3) para3(4)];
            elseif isfield(obj.Molecule,'area')
                para1 = obj.Molecule(m1).centroid;
                p1 = obj.Molecule(m1).coordinate*Option.pixelSize + [para1(1) para1(2)];
                para2 = obj.Molecule(m2).centroid;
                p2 = obj.Molecule(m2).coordinate*Option.pixelSize + [para2(1) para2(2)];
                para3 = obj.Molecule(m3).centroid;
                p3 = obj.Molecule(m3).coordinate*Option.pixelSize + [para3(1) para3(2)];
            end
            if pdist([p1;p2]) < pdist([p3;p2])
                obj.Molecule(m1).To = m2;
                obj.Molecule(m2).From = m1;
                obj.Molecule(m3).To = [];
            end
        end
    end
end

end