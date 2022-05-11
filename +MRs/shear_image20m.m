
function image = shear_image20m(src)
    shear = -0.2;
    tform = maketform('affine',[1 0 0; shear 1 0; 0 0 1]);
    image = imtransform(src,tform);
end