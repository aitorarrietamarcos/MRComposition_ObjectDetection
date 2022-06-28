function image = fisheye(src)
    % https://es.mathworks.com/help/images/ref/imadjust.html
    % sqsize = 60;
    % src = checkerboard(sqsize,4,4);
    nrows = size(src,1);
    ncols = size(src,2);
    fill = 0.3;
    [xi,yi] = meshgrid(1:ncols,1:nrows);
    xt = xi - ncols/2;
    yt = yi - nrows/2;
    [theta,r] = cart2pol(xt,yt);
    a = 2; % Try varying the amplitude of the cubic term.
    rmax = max(r(:));
    s1 = r + r.^3*(a/rmax.^2);
    [ut,vt] = pol2cart(theta,s1);
    ui = ut + ncols/2;
    vi = vt + nrows/2;
    ifcn = @(c) [ui(:) vi(:)];
    tform = geometricTransform2d(ifcn);

    image = imwarp(src,tform,'FillValues',fill);
end