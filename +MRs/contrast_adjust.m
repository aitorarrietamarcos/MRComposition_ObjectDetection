function image = contrast_adjust(src)
    % https://es.mathworks.com/help/images/ref/imadjust.html
    % J = imadjust(I,[low_in high_in],[low_out high_out])maps the intensity 
    % values ​​of Ito the new values ​​of Jso that the values ​​between low_in and
    % high_inare mapped to values ​​between low_outand high_out.    
    image = imadjust(src, [.2 .3 0; .6 .7 1],[]);
end