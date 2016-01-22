function [T, SF] = logSurvivalFunction(numFrames,exptime,count)

% LOGSURVIVIALFUNCTION finds the survival function (complement of the
% cumulative distribution) for the residence time information for a log-log
% plot.
% 
% INPUT:
%   - OBJ - FSMIA object.
%   - EXPTIME - exposure time of each frame + interval time between frames
%   - COUNT - output of LOGRESIDENCETIMESTAT.
% OUTPUT:
%   - T - logarithmic time vector used to create survival function.
%   - SF - survival function. SF(t) = P(t >= T(t)) with correction for
%   finite video length.

% Frame = obj.Frame;
% numFrames = length(Frame);
maxT = exptime*(numFrames);
deltaT = exptime;

T = logspace(log10(2*deltaT),log10(maxT),length(count));

c = 1./(heaviside(maxT-[0,T]).*(1-([0,T]/maxT)));
c = c(1:end-1);
if length(c) ~= length(count)
    n = padarray(count,[0 abs(length(c) - length(count))],0,'post')';
    SF = 1-cumsum(n.*c/sum(n.*c));
else
    SF = 1-cumsum(count.*c/sum(count.*c));
end

end