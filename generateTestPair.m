% generateTestPair
% Generates a fringe pattern and a distorted fringe pattern to test an
% implementation of FTP

% set the test you want to generate
im_test = 2;

refim = 1:(1920/100);
refim = 0.5 + 0.5 * cos(2*pi*(refim/1920)*100);
refim = repmat(refim,1080,100);

figure;
imshow(refim)

switch im_test
    case 1
        dataim = refim;
        shift = dataim(400:600,400:600);
        for i=1:1
            dataim(400:600,(400-i):(600-i)) = shift;
        end
    case 2
        dataim = refim;
        for i=1:12
            dataim((400+30*i):(429+30*i),400:800) = dataim((400+30*i):(429+30*i),(400+i):(800+i));
        end
end

figure;
imshow(dataim)

imwrite(dataim,'dataim.png')
imwrite(refim,'refim.png')