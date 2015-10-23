function [out ] = hasCollision(pt1, pt2, image)
    out = false;
    dp = max(abs(pt2(1)-pt1(1)), abs(pt2(2)-pt1(2)));
    delta_x = (pt2(1)-pt1(1));
    delta_y = (pt2(2)-pt1(2));
    dx = delta_x/dp;
    dy = delta_y/dp;
    x = pt1(1);
    y = pt1(2);
    %hand = image;
    while(abs(x - pt2(1)) > 2 || abs(y - pt2(2)) > 2)
        if (image(round(y),round(x)) == 1)
            out = true;
            return;
        end
        %hand(round(y),round(x)) = 1;
        x = x + dx;
        y = y + dy;
    end
end

