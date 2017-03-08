% ftp_v1
% Script containing my first implementation of the Fourier Tranform
% Profilometry algorithm outlined by Cobelli et al (2009)

% read in data, taken with camera and croppod or generated by 
% generateTestPair script
refim = rgb2gray(im2double(imread('refim.png')));
dataim = rgb2gray(im2double(imread('dataim.png')));

if (size(refim) ~= size(dataim))
    disp('dimensions must match')
end

[vdim,hdim] = size(refim);

% figure;
% imshow(refim)
% figure;
% imshow(abs(fft(refim')'))
% 
% figure;
% imshow(dataim)
% figure;
% imshow(abs(fft(dataim').'))

% figure;
% imshow(refim)
% figure;
% imshow(abs(hilbert(refim')'))
% 
% figure;
% imshow(dataim)
% figure;
% imshow(abs(hilbert(dataim').'))

refim_ft = hilbert(refim')';
dataim_ft = hilbert(dataim').';
delta_phi = imag(log(refim_ft.*dataim_ft));

% figure;
% imshow(delta_phi)

L = 300;
p = 1;
D = 50;

h = delta_phi * L .* (delta_phi - 2*pi*D/p).^-1;

h(abs(h)>1)=0;

fft_h_y = fft(h(1,1:hdim));

figure;
plot(log(abs(fft_h_y)))

figure;
pl = surf(1:hdim, 1:vdim, h);
set(pl, 'edgecolor','none')
figure;
contour(1:hdim, 1:vdim, h)
