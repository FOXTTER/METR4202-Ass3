function [pathPoints] = PRM(imgRaw, raw)
hand = raw;
se = strel('disk',3);
se2 = strel('disk',3);
hand = imerode(hand,se);
hand = imdilate(hand,se2);
n = 300;
start = [1210 10];
stop = [1710 1040];
disp('Choose two points with mouse');
figure
imshow(hand);
[x, y] = getpts;
start(1) = x(1);
start(2) = y(1);
stop(1) = x(2);
stop(2) = y(2);
samples(1) = struct('pt', start, 'pre', []);
samples(2) = struct('pt', stop, 'pre', []);
%%
for i = 3 : n
    x = round(random('unif',1, size(hand,2)));
    y = round(random('unif',1, size(hand,1)));
    while(hand(y,x) == 1)
        x = round(random('unif',1, size(hand,2)));
        y = round(random('unif',1, size(hand,1)));
    end
    samples(i) = struct('pt',[x y], 'pre',[]);
end
%[hand, out] = hasCollision([1210 10], [1710 1040], hand);
%disp(out);
%
%%
Cmatrix = zeros(n);
for i = 1 : n
    for k = i : n
        if (i ~= k)
            if (hasCollision(samples(i).pt, samples(k).pt, hand) == 0) 
                Cmatrix(i,k) = norm(samples(i).pt - samples(k).pt);
                Cmatrix(k,i) = Cmatrix(i,k);
            end
        end
    end
    clc
    disp(i);
end
CM = sparse(Cmatrix);
%%
[dist, path, pred] = graphshortestpath(CM, 1, 2);
for i = 1 : length(path)
    pathPoints(i,:) = samples(path(i)).pt;
end