Max=max(sizes(:,1));
binedge = linspace(0,Max,100);
counts=zeros(100,1);

for i=1:length(sizes)
    for j=1:100
        if le(sizes(i,1),binedge(j)) 
            if ge(sizes(i,1),binedge(j-1))
            counts(j)= counts(j)+1;
            end
        end
    end
end

plot (binedge,counts)

        