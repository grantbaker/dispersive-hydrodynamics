%FTP Code

%=========Experimental Parameters===========
L = 300; %distance from camera to surface
p = 1; %period of fringes
D = 50; %distance between camera and projector

%=========Data Analysis Variables===========
hpWin = 90; %width of high pass Gaussian filter

%=========Read Images=============
refim = im2double(imread('refim.png'));
dataim = im2double(imread('dataim.png'));

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

% h = abs(fft2(h));

%d = size(h)

%=========Surface and Contour Plots======
figure;
surf(1:1080, 1:1920, h,'edgecolor','none')

figure;
contourf(1:1080, 1:1920, h)

