function image = contrastDown(src)
    % https://es.mathworks.com/help/images/ref/imadjust.html
    % J = imadjust(I,[low_in high_in],[low_out high_out])maps the intensity 
    % values ​​of Ito the new values ​​of Jso that the values ​​between low_in and
    % high_inare mapped to values ​​between low_outand high_out.    
    low = 0.3;
    high = 0.7;
    %image = imadjust(src, [.2 .3 0; .6 .7 1],[]);
    image = imadjust(src, [], [low, high]);
end