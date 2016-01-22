function [msd, D] = Dcoeff(Displacements, exptime)

Displacements = Displacements(~cellfun(@isempty,Displacements));
msd = zeros(length(Displacements),1); sem = msd;
delta_t = (1:length(Displacements))*exptime;

for i = 1:length(msd)
    msd(i) = mean(Displacements{i}.^2);
    sem(i) = mean(Displacements{i})/sqrt(length(Displacements{i}));
end
f = fit(delta_t',msd,'poly1','Weight',sem);
D = f.p1/4;
figure,errorbar(delta_t,msd,sem,'ko')
hold on, plot(f,'k-'), hold off 
legend({'MSD';['D = ',num2str(D),' µm^2/s']})
title('Mean Squared Displacement vs. Time Step')
xlabel('Time (s)'),ylabel('Displacement (µm^2/s)')

end