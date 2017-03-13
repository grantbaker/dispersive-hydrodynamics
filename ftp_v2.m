%FTP Code

%=========Experimental Parameters===========
L = 300; %distance from camera to surface
p = 70; %period of fringes
D = 50; %distance between camera and projector

%=========Data Analysis Variables===========
hpWin = 3; %width of high pass Gaussian filter
use_gpu = 0; %use gpu to store and process images

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

dataim = padimage(dataim,1000,use_gpu);
refim = padimage(refim,1000,use_gpu);
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
refimFiltered = imfilter(refim, Ffilter); %filters reference image
dataimFiltered = imfilter(dataim, Ffilter); %filters deformed image

%figure;
%imshow(refimFiltered);
%title('Filtered Reference Image')

%figure;
%imshow(dataimFiltered);
%title('Filtered Deformed Image')

refimFFT = fft(refimFiltered); %takes FFT of filtered reference image
dataimFFT = fft(dataimFiltered); %takes FFT of filtered deformed image

%figure;
%imshow(refimFFT);
%title('FFT of Filtered Reference Image')

%========Gaussian Window Data===========
window = 1-gausswin(N,hpWin);
window = repmat(window,1,c);

refimFFT = refimFFT .* window;
dataimFFT = dataimFFT .*window;

%=========Inverse FFT=============
Ffilter2 = fspecial('disk',13);
refimReturned = ifft(refimFFT);
dataimReturned = ifft(dataimFFT);

%figure;
%imshow(refimReturned)
%title('Reference Image IFFT')

%=========Calculate Phase Shift=========
phase = angle(dataimReturned.*conj(refimReturned));
phase = imfilter(phase,Ffilter2);
phase = unwrap(phase);
phase = unwrap(phase');

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
fft_h(log(abs(fft_h))>-1) = fft_h(log(abs(fft_h))>-1).*exp(-1);
h = ifft(fft_h);

cropsize = 1100;

[vdim, hdim] = size(h);

h = 1e0*h((1+cropsize):(vdim-cropsize), (1+cropsize):(hdim-cropsize));

% h = abs(fft2(h));

[vdim, hdim] = size(h);

%=========Surface and Contour Plots======
figure;
% surf(1:(vdim-2*cropsize), 1:(hdim-2*cropsize), h,'edgecolor','none')
surf(1:vdim, 1:hdim, h, 'edgecolor','none')


figure;
% contourf(1:(vdim-2*cropsize), 1:(hdim-2*cropsize), h)   
contourf(1:vdim, 1:hdim, h)

figure;
plot(1:vdim,log(abs(fft(h(:,1500)))))