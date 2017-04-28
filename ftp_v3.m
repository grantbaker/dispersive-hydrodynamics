%FTP Code
close all; 
%=========Experimental Parameters===========
L = 1435; %distance from camera to surface
p = 100; %period of fringes
D = 380; %distance between camera and projector

%=========Data Analysis Variables===========
hpWin = 10; %width of high pass Gaussian filter
padding = 0; %amount of periodic padding
cropping = 0; %amount of cropping
use_gpu = 0; %use gpu to store and process images
save_memory = 1; %save memory by reusing the dataim and refim arrays

%=========Read Images=============
if use_gpu == 1
    refim = gpuArray(rgb2gray(im2double(imread('refim.png'))));
    dataim = gpuArray(rgb2gray(im2double(imread('dataim.png'))));
else 
    refim = rgb2gray(im2double(imread('refim.png')));
    refim = refim';
    refim = refim(1:3648,1824:5471);
    dataim = im2double(imread('dataim.png'));
    dataim = dataim(1:3648,1824:5471);
%     dataim = rgb2gray(im2double(imread('dataim.png')));
end

if (size(refim) ~= size(dataim))
    disp('dimensions must match')
end

mask = refim > .7; % whatever value works.
refim = regionfill(refim, mask);

% mask = dataim > .99;
% dataim = regionfill(dataim,mask);

% refim = refim';
% dataim = dataim';

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

%%%Some random additions that should be placed in a more natural place
% 
% [r,c] = size(refim);
% clc
% w = window2(r,c,@hanning);
% 
% refim = w.*refim; 
% dataim = w.*dataim; 
% 
figure;
imshow(refim)
title('Reference Image')

figure;
imshow(dataim)
title('Deformed Image')


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
% if use_gpu == 1
%     window = gpuArray(1-gausswin(N,hpWin));
%     window = repmat(window,1,c);
% else
%     window = 1-gausswin(N,hpWin);
%     window = repmat(window,1,c);
% end

%%%Some random additions that should be placed in a more natural place

[r,c] = size(refim);
window = window2(r,c,@gausswin);

% refim = window.*refim; 
% dataim = w.*dataim; 


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
L = 100; 
dx = L/N;

x=dx*[-N/2:N/2-1]; %-L/2:L/N:L/2-L/N; 
y = x; 
dk = 2*pi/L;

figure;
kx= fftshift(dk*[-N/2:N/2-1]); %[0:N/2-1 -N/2:-1]*2*pi/L;
ky = fftshift(dk*[-N/2:N/2-1]);
K = meshgrid(kx,ky); 




fft_h = fft(h);
% max_amp = max(max(fft_h)
% fft_h(log(abs(fft_h))>100) = fft_h(log(abs(fft_h))>100).*exp(-1);
% h = ifft(fft_h);

% cropsize = round(1.5*padding);
cropsize = cropping;

[vdim, hdim] = size(h);

% shifting x and y coordinates

[vdim, hdim] = size(h);
x = repmat(1:hdim,[vdim,1]);
y = repmat((1:vdim)',[1,hdim]);

 x = x - h .* x / L;
 y = y - h .* y / L;

% h = abs(fft2(h));


%=========Low pass filtering in Fourier Domain======
L = 100; 
dx = L/N;
x=dx*[-N/2:N/2-1]; %-L/2:L/N:L/2-L/N; 
y = x; 
dk = 2*pi/L;
k = (dk*[-N/2:N/2-1]); 

[kx,ky] = meshgrid(k,k); %[0:N/2-1 -N/2:-1]*2*pi/L;
rad = sqrt(kx.^2 + ky.^2); %%define polar radius

band = 1; %1/2 bandwidth of filter
l = 3; %steepness of transition of filter, making this too large will result in some aliasing. 
filter = 0.5*(tanh(l*(rad + band)) - tanh(l*(rad - band))); 
surf(filter,'edgecolor','none')
F = fftshift(fft2(h)).*filter;  

figure;
surf(abs(F),'edgecolor','none') % in case you want to
% check decay of the fft
h = real(ifft2(fftshift(F),'symmetric'));

%=========Surface and Contour Plots======
figure;
% surf(1:(vdim-2*cropsize), 1:(hdim-2*cropsize), h,'edgecolor','none')
surf(1:hdim, 1:vdim, h, 'edgecolor','none')
xlabel('$x$','Interpreter','latex')
ylabel('$y$','Interpreter','latex')
zlabel('$u(x,y)$','Interpreter','latex')


cropsize = 0;

h = 1e0*h((1+cropsize):(vdim-cropsize), (1+cropsize):(hdim-cropsize));

figure;
contourf(1:(hdim-2*cropsize),1:(vdim-2*cropsize),log(h - 1.5*min(min(h))))
contourf(1:(hdim-2*cropsize),1:(vdim-2*cropsize),h)




% figure;
% contourf(1:(vdim-2*cropsize), 1:(hdim-2*cropsize), h)   
% contourf(1:hdim, 1:vdim, h, 'edgecolor','none')
% 
% figure;
% plot(1:vdim,log(abs(fft(h(:,800)))))






