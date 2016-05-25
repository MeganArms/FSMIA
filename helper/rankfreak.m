function [r,p] = rankfreak(trajs)

lengths = cellfun(@length,trajs);

p = sort(lengths,'descend');
r = 1:length(p);
p = p.*0.2;
end