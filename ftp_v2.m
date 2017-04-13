%FTP Code

%=========Experimental Parameters===========
L = 300; %distance fclrom camera to surface
p = 600; %period of fringes
D = 50; %distance between camera and projector

%=========Data Analysis Variables===========
hpWin = 1; %width of high pass Gaussian filter
padding = 300; %amount of periodic padding
cropping = 330; %amount of cropping
use_gpu = 0; %use gpu to store and process images
save_memory = 1; %save memory by reusing the dataim and refim arrays

%=========Read Images=============
if use_gpu == 1
    refim = gpuArray(rgb2gray(im2double(imread('refim.png'))));
    dataim = gpuArray(rgb2gray(im2double(imread('dataim.png'))));
else 
    refim = rgb2gray(im2double(imread('refim.png')));
    dataim = rgb2gray(im2double(imread('dataim.png')));
end

if (size(refim) ~= size(dataim))
    disp('dimensions must match')
end

% [vdim, hdim] = size(refim);

%========Rescale greyscale images===========
mingrey = min(min(refim));
maxgrey = max(max(refim));
refim = (refim - mingrey)/(maxgrey - mingrey);

mingrey = min(min(dataim));
maxgrey = max(max(refim));
dataim = (dataim - mingrey)/(maxgrey - mingrey);

dataim = padImagePeriodic(dataim,padding,use_gpu);
refim = padImagePeriodic(refim,padding,use_gpu);
%=========Plot Images=============
%figure;
%imshow(refim)
%title('Reference Image')

%figure;
%imshow(dataim)
%title('Deformed Image')

%=========Processing==============
[N,c] = size(refim);

%========Fourier Transform=========
Ffilter = fspecial('disk',3); %creates filter

if save_memory == 1
    refim = imfilter(refim, Ffilter); %filters reference image
    dataim = imfilter(dataim, Ffilter); %filters deformed image
else
    refimFiltered = imfilter(refim, Ffilter); %filters reference image
    dataimFiltered = imfilter(dataim, Ffilter); %filters deformed image    
end

%figure;
%imshow(refimFiltered);
%title('Filtered Reference Image')

%figure;
%imshow(dataimFiltered);
%title('Filtered Deformed Image')

if save_memory == 1
    refim = fft2(refim); %takes FFT of filtered reference image
    dataim = fft2(dataim); %takes FFT of filtered deformed image
else
    refimFFT = fft2(refimFiltered); %takes FFT of filtered reference image
    dataimFFT = fft2(dataimFiltered); %takes FFT of filtered deformed image
end
    
%figure;
%imshow(refimFFT);
%title('FFT of Filtered Reference Image')

%========Gaussian Window Data===========
if use_gpu == 1
    window = gpuArray(1-gausswin(N,hpWin));
    window = repmat(window,1,c);
else
    window = 1-gausswin(N,hpWin);
    window = repmat(window,1,c);
end


if save_memory == 1
    refim = refim .* window;
    dataim = dataim .* window;
else
    refimFFT = refimFFT .* window;
    dataimFFT = dataimFFT .*window;
end

%=========Inverse FFT=============
Ffilter2 = fspecial('disk',13);

if save_memory == 1
    refim = ifft2(refim);
    dataim = ifft2(dataim);
else
    refimReturned = ifft2(refimFFT);
    dataimReturned = ifft2(dataimFFT);
end

%figure;
%imshow(refimReturned)
%title('Reference Image IFFT')

%=========Calculate Phase Shift=========

if save_memory == 1
    phase = angle(dataim.*conj(refim));
else
    phase = angle(dataimReturned.*conj(refimReturned));
end

phase = imfilter(phase, Ffilter2);
phase = unwrap(phase);
phase = unwrap(phase')';

h = phase * L .* (phase - 2*pi*D/p).^-1;

% pat's fft scaling 
% L = 400; 
% 
% N = 2^7; 
% 
% dx = L/N;
% 
% x=dx*[-N/2:N/2-1]; %-L/2:L/N:L/2-L/N;
% 
% dk = 2*pi/L;
% 
% k= fftshift(dk*[-N/2:N/2-1]); %[0:N/2-1 -N/2:-1]*2*pi/L;

% end pat's fft scaling


fft_h = fft(h);
% max_amp = max(max(fft_h)
% fft_h(log(abs(fft_h))>100) = fft_h(log(abs(fft_h))>100).*exp(-1);
% h = ifft(fft_h);

% cropsize = round(1.5*padding);
cropsize = cropping;

[vdim, hdim] = size(h);

h = 1e0*h((1+cropsize):(vdim-cropsize), (1+cropsize):(hdim-cropsize));

% shifting x and y coordinates

[vdim, hdim] = size(h);
x = repmat(1:hdim,[vdim,1]);
y = repmat((1:vdim)',[1,hdim]);

 x = x - h .* x / L;
 y = y - h .* y / L;

% h = abs(fft2(h));


%=========Surface and Contour Plots======
figure;
% surf(1:(vdim-2*cropsize), 1:(hdim-2*cropsize), h,'edgecolor','none')
surf(1:hdim, 1:vdim, h, 'edgecolor','none')


figure;
% contourf(1:(vdim-2*cropsize), 1:(hdim-2*cropsize), h)   
contourf(1:hdim, 1:vdim, h)

figure;
plot(1:vdim,log(abs(fft(h(:,800)))))




