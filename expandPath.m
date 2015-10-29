function [ outPath ] = expandPath( startPath )
lineLength = 0.02;
outPath = startPath(1,:);
for i = 2:length(startPath)
    dist = norm(startPath(i-1,:) - startPath(i,:));
    numOfSegments = floor(dist/lineLength);
    px = linspace(startPath(i-1,1), startPath(i,1),numOfSegments);
    py = linspace(startPath(i-1,2), startPath(i,2),numOfSegments);
    pz = linspace(startPath(i-1,3), startPath(i,3),numOfSegments);
    tempPath = [px' py' pz'];
    outPath = [outPath; tempPath];
end
end

