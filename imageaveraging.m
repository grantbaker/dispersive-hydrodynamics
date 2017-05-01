images = ['IMG_3587.CR2';'IMG_3588.CR2';'IMG_3589.CR2';'IMG_3590.CR2';'IMG_3591.CR2';'IMG_3592.CR2';'IMG_3593.CR2';'IMG_3594.CR2'];

[x,y] = size(rgb2gray(im2double(imread(images(1,:)))));

imdata = zeros(size(images,1),x,y);

for ii = 1:size(images)
    tmp = rgb2gray(im2double(imread(images(ii,:))));
    mask = tmp > .4;
    tmp = regionfill(tmp,mask);
    imdata(ii,:,:) = tmp;
end

means = squeeze(mean(imdata,1));
stds = squeeze(std(imdata,1));

zscores = bsxfun(@plus, permute(imdata,[2,3,1]), -means);
zscores = permute(bsxfun(@times, zscores, stds.^-1), [3,1,2]);

nbins = 10;

figure;
h = histogram(zscores, nbins);

bins = h.Values;
lower = h.BinLimits(1):h.BinWidth:h.BinLimits(2)-h.BinWidth;
upper = lower + h.BinWidth;
expected = (x*y*size(images,1))*(normcdf(upper) - normcdf(lower));

chisquare = sum(((expected - bins).^2).*(expected.^-1));

pval = chi2cdf(chisquare,nbins-1,'upper');
disp(pval)

hi = max(max(means));
lo = min(min(means));
means = (means - lo) / (hi - lo);

imshow(means)