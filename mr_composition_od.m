%% Extension of Cost-Effectiveness of Composite Metamorphic Relations for Testing Deep Learning Systems
% Experimental setup includes
% 4 DL models:
%       'YOLOv4-coco','efficientDetD0-coco','tinyYOLOv2-coco','tiny-yolov3-coco'
% modelNames = {'YOLOv4-coco','efficientDetD0-coco','tinyYOLOv2-coco','tiny-yolov3-coco'};
% 7 MRs:
%       1-blur_image, 2-flip_left_right, 3-flip_up_down, 4-invert_colors,
%       5-rgb_to_grayscale, 6-rotate_image, 7-shear_image
clear;
clc;

modelNames = {'YOLOv4-coco'};
datasets = {'datasets/coco/images'};
results_dir = 'results';
if ~exist(results_dir, 'dir')
   mkdir(results_dir)
end

for i = 1 : length(modelNames)
    switch modelNames{i}
        case 'YOLOv4-coco'
            % func_yolov4 runs for 1 time currently on 2 images from coco
            % dataset
            func_yolov4(datasets,results_dir);
        case 'efficientDetD0-coco'

        case 'tinyYOLOv2-coco'

        case 'tiny-yolov3-coco'

        otherwise
            fprintf('No actions found for %s',modelNames{i});
    end
end

