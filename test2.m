Max=max(S(:,1));
binedge = linspace(0,Max,100);
counts=zeros(100,1);

for i=1:length(S)
    for j=1:100
        if le(S(i,1),binedge(j)) 
            if ge(S(i,1),binedge(j-1))
            counts(j)= counts(j)+1;
            end
        end
    end
end

plot (binedge,counts)

        