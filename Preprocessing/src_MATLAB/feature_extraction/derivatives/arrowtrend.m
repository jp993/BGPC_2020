function arrow = arrowtrend(y)

arrow=zeros(size(y));

for ind=1:length(y)
    x=y(ind);
    
    %Scale trend to display an arrow
    if abs(x) <= 1
        arrow(ind) = 0;
    elseif x > 1 && x < 2
        arrow(ind) = 1;
    elseif x >= 2 && x <= 3
        arrow(ind) = 2;
    elseif x > 3 && x <= 8
        arrow(ind) = 3;
    elseif x < -1 && x > -2
        arrow(ind) = -1;
    elseif x <= -2 && x >= -3
        arrow(ind) = -2;
    elseif x < -3 && x >= -8
        arrow(ind) = -3;
    else
        arrow(ind) = NaN;  %too unreasonable
    end
    
end