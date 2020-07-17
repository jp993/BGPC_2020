function [IOB] = IOB_calculation(insulin,Ts)

% define 6 hour curve
k1 = 0.0173;
k2 = 0.0116;
k3 = 6.75;
for t = 1:360
    IOB_6h_curve(t)= 1 - ...
        0.75*((-k3/(k2*(k1-k2))*(exp(-k2*(t)/0.75)-1) + ...
        k3/(k1*(k1-k2))*(exp(-k1*(t)/0.75)-1))/(2.4947e4));
end
IOB_6h_curve = IOB_6h_curve(Ts:Ts:end);

% IOB is the convolution of insulin data with IOB curve
IOB = conv(insulin, IOB_6h_curve);
IOB = IOB(1:length(insulin));

end


