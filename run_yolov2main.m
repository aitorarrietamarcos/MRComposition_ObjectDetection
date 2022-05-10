addpath('models/yolo-v2-main/src');

%% Select the pre-trained network
modelName = 'tinyYOLOv2-coco';
model = load(['models/yolo-v2-main/', modelName, '.mat']);

detector = model.yolov2Detector;

% Detect Objects using YOLO v2 Object Detector
% Read test image.
image = imread('3cats.jpg');

% Detect objects in test image.
[boxes, scores, labels] = detect(detector, image);

% Visualize detection results.
image = insertObjectAnnotation(image,'rectangle',boxes,labels);
figure, imshow(image)

rmpath('models/yolo-v2-main/src');