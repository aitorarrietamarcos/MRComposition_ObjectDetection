
function image = blur_image(src)
   % windowWidth = 3;
    %kernel = ones(windowWidth) / windowWidth ^ 2;
    %image = imfilter(src, kernel);
% code taken from https://www.mathworks.com/matlabcentral/answers/472573-write-a-function-called-blur-that-blurs-the-input-image
% img = sourceTestCase;
% w = 1;
% B=double(img);
% [m,n] = size(B);
% k=2*w+1;
% for i = 1:m
%     for j = 1:n
%         p=i-fix(k/2);
%         q=i+fix(k/2);
%         r=j-fix(k/2);
%         s=j+fix(k/2);
%         if p<1
%             p=1;
%         end
%         if q>m
%             q=m;
%         end
%         if r<1
%             r=1;
%         end
%         if s>n
%             s=n;
%         end
%         A=B([p:q],[r:s]);
%         C(i,j)=mean(A(:));
%     end
% end
w = 0.25;
 img = src;
B=double(img);
[m,n] = size(B);
k=2*w+1;
for i = 1:m
    for j = 1:n
        p=i-fix(k/2);
        q=i+fix(k/2);
        r=j-fix(k/2);
        s=j+fix(k/2);
        if p<1
            p=1;
        end
        if q>m
            q=m;
        end
        if r<1
            r=1;
        end
        if s>n
            s=n;
        end
        A=B([p:q],[r:s]);
        B(i,j)=mean(A(:));
    end
end
%output=uint8(B);
image=uint8(B);    
end