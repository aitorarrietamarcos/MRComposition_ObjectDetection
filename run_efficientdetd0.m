addpath('models/efficientdet-d0-main');

modelName = 'efficientDetD0-coco';
model = load(['models/efficientdet-d0-main/', modelName, '.mat']);
net = model.net;

image = imread('3cats.jpg');

% Get classnames for COCO dataset.
classNames = helper.getCOCOClasess;

% Perform detection using pretrained model.
executionEnvironment = 'auto';
[bboxes,scores,labels] = detectEfficientDetD0(net, image, classNames, executionEnvironment);

% Visualize detection results.
annotations = string(labels) + ": " + string(scores);
image = insertObjectAnnotation(image, 'rectangle', bboxes, annotations);

figure, imshow(image)