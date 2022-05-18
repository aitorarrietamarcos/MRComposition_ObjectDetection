addpath('models/yolo-v2-main/src');

%% Select the pre-trained network
modelName = 'tinyYOLOv2-coco';
model = load(['models/yolo-v2-main/', modelName, '.mat']);

detector = model.yolov2Detector;

% Detect Objects using YOLO v2 Object Detector
% Read test image.
%image = imread('3cats.jpg');
%image = imread('datasets/coco/subset1/000000002516.jpg');
image = imread('datasets/oid/subset1/9afdfdff254d32c0.jpg');
%image = MRs.flip_left_right(image);
%image = MRs.flip_up_down(image);
%image = MRs.rotate_image5p(image);
% image = imread('3cats.jpg');
% Detect objects in test image.
[boxes, scores, labels] = detect(detector, image);

% Visualize detection results.
image = insertObjectAnnotation(image,'rectangle',boxes,labels);
figure, imshow(image)

rmpath('models/yolo-v2-main/src');