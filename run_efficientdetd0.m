addpath('models/pretrained-efficientdet-d0-main/src');
addpath('models/pretrained-efficientdet-d0-main');

modelName = 'efficientDetD0-coco';

% download model - function from downloadPretrainedEfficientDetD0.m
model = downloadPretrainedEfficientDetD0;
net = model.net;

%image = imread('3cats.jpg');
%%image = imread('datasets/coco/images/subset1/000000002516.jpg');
image = imread('datasets/oid/subset1/9afdfdff254d32c0.jpg');
%image = MRs.flip_left_right(image);
%image = MRs.flip_up_down(image);
%image = MRs.rotate_image5p(image);
% Get classnames for COCO dataset.
classNames = helper.getCOCOClasess;

% Perform detection using pretrained model.
executionEnvironment = 'auto';
[bboxes,scores,labels] = detectEfficientDetD0(net, image, classNames, executionEnvironment);

% Visualize detection results.
annotations = string(labels) + ": " + string(scores);
image = insertObjectAnnotation(image, 'rectangle', bboxes, annotations);

figure, imshow(image)