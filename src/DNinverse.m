function pred = DNinverse(pred, gc, x)

% tau = x(1);    % time scale of adaptation
off = x(2);    % baseline gain control - determines steady state firing rate
r0 =     0;    % baseline firing rate
r1 =     x(3); % response scale
n  =     1;    % exponent

pred = (pred-r0)/r1/power(off,1/n).*(power(off,1/n)+ power(gc,1/n));
