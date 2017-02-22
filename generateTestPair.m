% generateTestPair
% Generates a fringe pattern and a distorted fringe pattern to test an
% implementation of FTP

refim = 1:(1920/100);
refim = 0.5 + 0.5 * cos(2*pi*(refim/1920)*100);
refim = repmat(refim,1080,100);

figure;
imshow(refim)

dataim = refim;
shift = dataim(400:600,400:600);
for i=1:6
    dataim(400:600,(400-i):(600-i)) = shift;
end

figure;
imshow(dataim)

imwrite(dataim,'dataim.png')
imwrite(refim,'refim.png')