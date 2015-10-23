clear
raw = imread('hand_mask.png');
hand = rgb2gray(raw) > 10;
n = 20;
samples = zeros(n+2,2);
start = [1210 10];
stop = [1710 1040];
samples(1,:) = start;
samples(2,:) = stop;
for i = 3 : n
    x = round(random('unif',1, size(hand,2)));
    y = round(random('unif',1, size(hand,1)));
    samples(i,:) = [x y];
end
%[hand, out] = hasCollision([1210 10], [1710 1040], hand);
%disp(out);
%
%figure
%imshow(hand);
%hold on
%plot([1210 1710], [10 1040], 'o');
%hold off
%%
Cmatrix = zeros(n);
for i = 1 : n
    for k = 1 : n
        if (i ~= k)
            Cmatrix(i,k) = (hasCollision(samples(i,:), samples(k,:), hand) == 0);
        end
    end
end
graph = biograph(Cmatrix);
current = sample(1,:);
for i = 1 : n