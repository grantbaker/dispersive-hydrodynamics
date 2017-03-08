%FTP Code

%=========Experimental Parameters===========
L = 300; %distance from camera to surface
p = 1; %period of fringes
D = 50; %distance between camera and projector

%=========Data Analysis Variables===========
hpWin = 3; %width of high pass Gaussian filter

%=========Read Images=============
refim = gpuArray(rgb2gray(im2double(imread('refim.png'))));
dataim = gpuArray(rgb2gray(im2double(imread('dataim.png'))));

if (size(refim) ~= size(dataim))
    disp('dimensions must match')
end

[vdim,hdim] = size(refim);

%========Rescale greyscale images===========
mingrey = min(min(refim));
maxgrey = max(max(refim));
refim = (refim - mingrey)/(maxgrey - mingrey);

mingrey = min(min(dataim));
maxgrey = max(max(refim));
dataim = (dataim - mingrey)/(maxgrey - mingrey);

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

h = gpuArray(phase * L .* (phase - 2*pi*D/p).^-1);

cropsize = 100;
h = 1e4*h((1+cropsize):(vdim-cropsize), (1+cropsize):(hdim-cropsize));

% h = abs(fft2(h));

%d = size(h)

%=========Surface and Contour Plots======
figure;
surf(1:(vdim-2*cropsize), 1:(hdim-2*cropsize), h,'edgecolor','none')

figure;
contourf(1:(vdim-2*cropsize), 1:(hdim-2*cropsize), h)   

