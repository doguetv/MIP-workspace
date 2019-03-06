%% Comments
%Function that reverses position signal from contrex when 0 degrree has
%been reached.
%Author: V. Doguet (28/2/2019)
%Updates:
%% Function
function outSignal = reverseContrexPosition(inSignal, rate)

diffPos = diff(inSignal);
arbitraryGap = .1*max(abs(diffPos));
gap = find(abs(diffPos) > arbitraryGap);

indexes = find(diff(gap) > .1*rate) + 1;
starts = [1; gap([indexes-1; end])+(rate/50)];
stops = [gap([1; indexes]) - (rate/50); length(inSignal)];

newPosition = nan(length(inSignal), 1);
for i = 1:length(starts)
    if inSignal(stops(i)) > 0
        newPosition(starts(i):stops(i)) = inSignal(starts(i):stops(i));
    else
        newPosition(starts(i):stops(i)) = inSignal(starts(i):stops(i))+360;
    end
end

outSignal = interp1(find(~isnan(newPosition)), newPosition(~isnan(newPosition)), 1:length(newPosition))';

end