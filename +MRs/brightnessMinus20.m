function image = brightnessMinus20(src)
    % https://es.mathworks.com/matlabcentral/answers/347448-how-to-increase-the-brightness-of-an-image 
    % adjust brightness by lowering the black point range [0, 1] with
    % increments of 0.1
    param = 0.2;
    % to achieve same by lowering the white point use image = imadjust(src,[0 param],[0 1]);  
    image = imadjust(src,[0 1],[0 param]);
end