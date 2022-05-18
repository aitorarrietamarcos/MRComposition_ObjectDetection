name = 'tiny-yolov3-coco';
%name = 'darknet53-coco';

detector = yolov3ObjectDetector(name);
%%image = imread('datasets/coco/images/subset1/000000002516.jpg');
image = imread('datasets/oid/subset1/9afdfdff254d32c0.jpg');
%image = MRs.flip_left_right(image);
%image = MRs.flip_up_down(image);
%image = MRs.rotate_image5p(image);
% image = imread('3cats.jpg');
image = preprocess(detector,image);
image = im2single(image);
[bboxes,scores,labels] = detect(detector,image,'DetectionPreprocessing','none');

detectedimage = insertObjectAnnotation(image,'Rectangle',bboxes,labels);
imshow(detectedimage)