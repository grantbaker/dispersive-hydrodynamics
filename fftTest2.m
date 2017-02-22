%2D FFT Test with Blurring

%Import Images:
%imageA = imread('imageA','png');
imageA = imread('imageC','jpg');
imageA = imageA(:,:,1);

%Create Figures of Images:
figure, imshow(imageA)
title('Image A')

%Take FFT of Images:
fftA = fft2(double(imageA));

%Plot Magnitude and Phase of FFT Images:
figure, imshow(abs(fftshift(fftA)),[24 100000]), colormap gray
title('Image A FFT2 Magnitude')
figure, imshow(angle(fftshift(fftA)),[-pi pi]), colormap gray
title('Image A FFT2 Phase')

%Blur Kernel
ksize = 31; %size of kernel
% kernel = zeros(ksize);

%Gaussian Blur
s = 3; %standard deviation
m = ksize/2; %mean
[X, Y] = meshgrid(1:ksize);
kernel = (1/(2*pi*s^2))*exp(-((X-m).^2 + (Y-m).^2)/(2*s^2)); %Gaussian Function

%Display Kernel
figure, imagesc(kernel)
axis square
title('Blur Kernel')
colormap gray

%Pad image
imagePad = padimage(imageA, ksize);
%padding is nice because of issues at the edges due to aliasing

%Embed kernel in image that is size of original image + padding
[h1, w1] = size(imagePad);
kernelimagepad = zeros(h1,w1);

kernelimagepad(1:ksize, 1:ksize) = kernel;

%Perform 2D FFTs
fftimagepad = fft2(imagePad);
fftkernelpad = fft2(kernelimagepad);

fftkernelpad(fftkernelpad == 0) = 1e-6;

%Multiply FFTs
fftblurimagepad = fftimagepad.*fftkernelpad;

%Perform Reverse 2D FFT
blurimagepad = ifft2(fftblurimagepad);

%Remove Padding
blurimageunpad = blurimagepad(ksize+15:ksize+775,ksize+15:ksize+950);
%this adjusts the blurred image. Vary the numbers to fit the size of the
%image

%Display Blurred Image
figure, imagesc(blurimageunpad)
axis square
title('Blurred Image - with Padding')
colormap gray
set(gca, 'XTick', [], 'YTick', [])