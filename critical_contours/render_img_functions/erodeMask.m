function erodeM = erodeMask(mask, strelSize)
    SE = strel('disk',strelSize, 0);
    erodeM = imerode(mask,SE);
    %figure;
    %image(erode1);
end