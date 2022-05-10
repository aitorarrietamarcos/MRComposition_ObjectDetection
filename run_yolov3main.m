name = 'tiny-yolov3-coco';
%name = 'darknet53-coco';

detector = yolov3ObjectDetector(name);

image = imread('3cats.jpg');
image = preprocess(detector,image);
image = im2single(image);
[bboxes,scores,labels] = detect(detector,image,'DetectionPreprocessing','none');

detectedimage = insertObjectAnnotation(image,'Rectangle',bboxes,labels);
imshow(detectedimage)