function [ out ] = hasCollisionFast( p1, p2, image )
    p = bresenham(round(p1), round(p2));

    for pp=p'
        if image(pp(2), pp(1)) > 0
            out = true;
            return;
        end
    end
    out = false;
end

