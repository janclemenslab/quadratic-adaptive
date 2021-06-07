function y = spike_dead(x, dead);
% y=spike_dead(x,dead) - remove spikes preceded by interspike interval
% shorter than dead time (refractory effects)

first = x(1);		% save time of first spike
z = diff(x);		% transform to intervals
n = size(z, 2);

% take all intervals shorter than dead, add them to next interval
% and set them to zero so they can be removed

zz = find(z<dead);
for i = zz
	 if (z(i) < dead) 
	 	if (i <n)
			z(i+1) = z(i+1) + z(i);
		end
		z(i) = 0;
	 end;
end

z = nonzeros(z)';
y = [first, cumsum(z)+first];