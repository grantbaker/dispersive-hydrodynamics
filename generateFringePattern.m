% generateFringePattern
% Generates a sinusoidal fringe pattern, mimicking the original in
% GenerateFringePattern.nb

% horizontal and vertical dimensions of pattern
hdim = 1920;
vdim = 1080;

% grayscale values for the high and low color
% 0<x<1
lcolor = 0;
hcolor = 1;

% also generates the inverse image. For optimal projector usage, it is
% helpful to switch between both.
genInv = 1;

% phase frequency across image
freq = 200;

% chooses to display image after generation
dispImg = 1;

% saving options
% 0: don't save
% 1: save with generic name
% 2: save with specific name
saveImg = 2;

% generate image
iim = 1:(hdim/freq);
iim = (hcolor - lcolor) * (.5 + 0.5*cos(2*pi*(iim/hdim)*freq)) + lcolor;
iim = repmat(iim,vdim,freq);

if (dispImg == 1)
    figure;
    imshow(iim)
end

switch saveImg
    case 1
        if (genInv == 1)
            imwrite(iim,'fringe1.png');
            imwrite(invim,'fringe2.png');
        else
            imwrite(iim,'fringe.png');
        end
        
    case 2
        id = num2str(1e12*rand(1,1));
        id = id(1:12);
        if (genInv == 1)
            imwrite(iim,strcat('fringe1-',id,'.png'));
            imwrite(invim,strcat('fringe2-',id,'.png'));
        else
            imwrite(iim,strcat('fringe-',id','.png'));
        end
end

if (genInv == 1) 
    invim = 1:(hdim/freq);
    invim = (lcolor - hcolor) * (.5 + 0.5*cos(2*pi*(invim/hdim)*freq)) + hcolor;
    invim = repmat(invim,vdim,freq);
    
    if (dispImg == 1)
        figure;
        imshow(invim)
    end
end