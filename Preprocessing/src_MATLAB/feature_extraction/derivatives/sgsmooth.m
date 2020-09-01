function Yout = sgsmooth(Y,framelen,order)
%
% smoothing using savitzky-golay
%

[b,g]=sgolay(order,framelen);

ycenter = conv(Y,b((framelen+1)/2,:),'valid');

ybegin = b(end:-1:(framelen+3)/2,:) * Y(framelen:-1:1);

yend = b((framelen-1)/2:-1:1,:) * Y(end:-1:end-(framelen-1));

Yout = [ybegin; ycenter; yend];