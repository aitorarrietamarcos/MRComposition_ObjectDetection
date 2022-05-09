
function image = blur_image(src)
    windowWidth = 3;
    kernel = ones(windowWidth) / windowWidth ^ 2;
    image = imfilter(src, kernel);
end