% generateTestPair
% Generates a fringe pattern and a distorted fringe pattern to test an
% implementation of FTP

% set the test you want to generate
im_test = 3;

hdim = 4000;
vdim = 4000;
freq = 200;


refim = 1:(hdim/freq);
refim = 0.5 + 0.5 * cos(2*pi*(refim/hdim)*freq);
refim = repmat(refim,vdim,freq);

figure;
imshow(refim)

switch im_test
    case 1
        dataim = refim;
        shift = dataim(400:600,400:600);
        for i=1:7
            dataim(400:600,(400-i):(600-i)) = shift;
        end
        
    case 2
        dataim = refim;
        for i=1:12
            dataim((400+30*i):(429+30*i),400:800) = dataim((400+30*i):(429+30*i),(400+i):(800+i));
        end
        
    case 3
        L = 300;
        p = hdim/freq;
        D = 50;
%         x = linspace(1,1920);
%         y = linspace(1,1080);
        [X,Y] = meshgrid(1:hdim,1:vdim);
%         z = 30*sin(10*(X+Y)/100);
        z = 100*exp(-((X-(hdim/2)).^2)/(hdim^2/10)-((Y-(vdim/2)).^2)/(hdim^2/10));
        figure;
        surf(1:hdim,1:vdim,z,'edgecolor','none')
        phi = (2*pi*D*z/p).*(z-L).^-1;
        dataim = .5+.5*cos(2*pi*(X/hdim)*freq + phi);
        
        
end

figure;
imshow(dataim)

dataim  = repmat(dataim,[1,1,3]);
refim = repmat(refim, [1,1,3]);

imwrite(dataim,'dataim.png')
imwrite(refim,'refim.png')