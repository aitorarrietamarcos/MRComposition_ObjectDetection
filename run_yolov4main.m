% add paths for YOLOv4-coco
addpath('models/pretrained-yolo-v4-main/src');
addpath('models/pretrained-yolo-v4-main');            

% load model    
modelName = 'YOLOv4-coco';
model = helper.downloadPretrainedYOLOv4(modelName);
net = model.net;

% Get classnames of COCO dataset.
classNames = helper.getCOCOClassNames;
% Get anchors used in training of the pretrained model.
anchors = helper.getAnchors(modelName);
% Specify environment
executionEnvironment = 'auto';
% execute model with current image        
image = imread('3cats.jpg');        
[bboxes, scores, labels] = detectYOLOv4(net, image, anchors, classNames, executionEnvironment);

% Visualize detection results.
annotations = string(labels) + ": " + string(scores);
image = insertObjectAnnotation(image, 'rectangle', bboxes, annotations);

figure, imshow(image)


% Copyright 2021 The MathWorks, Inc.