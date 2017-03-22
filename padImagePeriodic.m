function Ipad = padImagePeriodic(I, p, gpu)
% padImagePeriodic
% Pads an image with interpolating colors so the boundaries
% can be interpreted as periodic

[h, w] = size(I);

if gpu == 1
    Ipad = zeros(h+2*p, w+2*p, 'gpuArray');
else
    Ipad = zeros(h+2*p, w+2*p);
end

Ipad((p+1):(p+h), (p+1):(p+w)) = I;

Ipad(1, (p+1):(p+w)) = (I(1,1:w) + I(h,1:w))/2;
Ipad(h+2*p, (p+1):(p+w)) = (I(1,1:w) + I(h,1:w))/2;

for ii = (p+1):(p+w)
    Ipad(1:p, ii) = linspace(Ipad(1,ii), Ipad(p+1,ii),p);
    Ipad((h+p+1):(h+2*p),ii) = linspace(Ipad(h+p,ii),Ipad(h+2*p,ii),p);
end

Ipad(1:(h+2*p), 1) = (Ipad(1:(h+2*p),p+1) + Ipad(1:(h+2*p), w+p))/2;
Ipad(1:(h+2*p), w+2*p) = (Ipad(1:(h+2*p),p+1) + Ipad(1:(h+2*p), w+p))/2;

for ii = 1:h+2*p
    Ipad(ii, 1:p) = linspace(Ipad(ii,1), Ipad(ii,p+1),p);
    Ipad(ii, (w+p+1):(w+2*p)) = linspace(Ipad(ii,w+p),Ipad(ii,w+2*p),p);
end


end

