
function image = shear_image(src)
     tform = maketform('affine',[1 0 0; .5 1 0; 0 0 1]);
     image = imtransform(src,tform);
end