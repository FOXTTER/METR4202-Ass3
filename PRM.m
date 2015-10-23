raw = imread('hand_mask.png');
hand = rgb2gray(raw) > 10;
%imshow(hand);
