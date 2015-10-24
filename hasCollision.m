function [out ] = hasCollision(pt1, pt2, image)
    dp = max(abs(pt2(1)-pt1(1)), abs(pt2(2)-pt1(2)));
    dp = dp;
    delta_x = (pt2(1)-pt1(1));
    delta_y = (pt2(2)-pt1(2));
    dx = delta_x/dp;
    dy = delta_y/dp;
    x1 = pt1(1);
    y1 = pt1(2);
    x2 = pt2(1);
    y2 = pt2(2);
    %if (norm(pt2-pt1) > 0.15) 
    %    out = true;
    %    return
    %end
    %hand = image;
    if (image(floor(min(y1,y2)):floor(max(y1,y2)),floor(min(x1,x2)):floor(max(x1,x2))) == 0)
        out = false;
        return;
    end
    out = false;
    while(abs(x1 - x2) > 2 || abs(y1 - y2) > 2)
        if (image(round(y1),round(x1)) == 1)
            out = true;
            return;
        end
        %hand(round(y),round(x)) = 1;
        x1 = x1 + dx;
        y1 = y1 + dy;
    end
end

