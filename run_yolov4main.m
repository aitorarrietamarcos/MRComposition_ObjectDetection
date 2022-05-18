% add paths for YOLOv4-coco
addpath('models/pretrained-yolo-v4-main/src');
addpath('models/pretrained-yolo-v4-main');            

% load model    
modelName = 'YOLOv4-coco';
model = helper.downloadPretrainedYOLOv4(modelName);
net = model.net;

% Get classnames of COCO dataset.
classNames = helper.getCOCOClassNames;
% classNames = getOIDClassNames;
% Get anchors used in training of the pretrained model.
anchors = helper.getAnchors(modelName);
% Specify environment
%classNames = getOIDClassNames;
executionEnvironment = 'auto';
% execute model with current image        
% image = imread('3cats.jpg');
%image = imread('datasets/coco/images/subset1/000000002516.jpg');
image = imread('datasets/oid/subset1/9afdfdff254d32c0.jpg');
%image = MRs.flip_left_right(image);
%image = MRs.flip_up_down(image);
%image = MRs.rotate_image5p(image);
[bboxes, scores, labels] = detectYOLOv4(net, image, anchors, classNames, executionEnvironment);

%disp(labels)
%disp(bboxes)
%disp(scores)
% Visualize detection results.
annotations = string(labels) + ": " + string(scores);
image = insertObjectAnnotation(image, 'rectangle', bboxes, annotations);

figure, imshow(image)


% Copyright 2021 The MathWorks, Inc.