
addpath('models/pretrained-yolo-v4-main/src');
addpath('models/pretrained-yolo-v4-main');

modelName = 'YOLOv4-coco';
%modelName = 'YOLOv4-tiny-coco';
model = helper.downloadPretrainedYOLOv4(modelName);
net = model.net;

image = imread('3cats.jpg');

% Get classnames of COCO dataset.
classNames = helper.getCOCOClassNames;

% Get anchors used in training of the pretrained model.
anchors = helper.getAnchors(modelName);

% Detect objects in test image.
executionEnvironment = 'auto';
[bboxes, scores, labels] = detectYOLOv4(net, image, anchors, classNames, executionEnvironment);

% Visualize detection results.
annotations = string(labels) + ": " + string(scores);
image = insertObjectAnnotation(image, 'rectangle', bboxes, annotations);

figure, imshow(image)