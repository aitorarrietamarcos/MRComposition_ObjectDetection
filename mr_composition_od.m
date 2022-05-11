%% Extension of Cost-Effectiveness of Composite Metamorphic Relations for Testing Deep Learning Systems
% Experimental setup includes
% 4 DL models:
%       'YOLOv4-coco','efficientDetD0-coco','tinyYOLOv2-coco','tiny-yolov3-coco'
clear;
clc;

% modelNames = {'YOLOv4-coco','efficientDetD0-coco','tinyYOLOv2-coco','tiny-yolov3-coco'};
modelNames = {'YOLOv4-coco'};
% datasets = {'datasets/coco/subset1','datasets/coco/subset2','datasets/coco/subset3','datasets/coco/subset4'};    % list of datasets
datasets = {'datasets/coco/images/subset1'};
results_dir = 'results';                % results dir
noOfExecutions = 10;
% create results dir if not existing
if ~exist(results_dir, 'dir')
   mkdir(results_dir)
end

for i = 1 : length(modelNames)
    switch modelNames{i}
        case 'YOLOv4-coco'
            % Check if yolov4 dir exists
            yolov4_dir = 'models/pretrained-yolo-v4-main';
            if ~exist(yolov4_dir, 'dir')
                fprintf('Yolov4 dir not found! exiting...\n')
               return;
            end
            % add paths for YOLOv4-coco            
            addpath('models/pretrained-yolo-v4-main/src');
            addpath('models/pretrained-yolo-v4-main');   

            model_results_dir = fullfile(results_dir,modelNames{i});
            if ~exist(model_results_dir, 'dir')
               mkdir(model_results_dir);
            end
            
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
            for j = 1 : length(datasets)
                % check and create dir for current dataset's results
                model_dataset_results_dir = fullfile(model_results_dir, string(j));
                if ~exist(model_dataset_results_dir, 'dir')
                   mkdir(model_dataset_results_dir);
                end
                results_file = fullfile(model_dataset_results_dir, strcat(modelNames{i}, '_',string(j),'.xlsx')) ;
                
                it = 1;
                expResults{1,1} = 'MR1';
                expResults{1,2} = 'MR2';
                expResults{1,3} = 'objfailureRateMR1';
                expResults{1,4} = 'classfailureRateMR1';                
                expResults{1,5} = 'objfailureRateMR2';
                expResults{1,6} = 'classfailureRateMR2';                
                expResults{1,7} = 'objfailureRateMR1_MR2_combined';
                expResults{1,8} = 'classfailureRateMR1_MR2_combined';                
                expResults{1,9} = 'objfailureRateMR1_2_composite';
                expResults{1,10} = 'classfailureRateMR1_2_composite'; 
                expResults{1,11} = 'timeMR1';
                expResults{1,12} = 'timeMR2';
                expResults{1,13} = 'timeMR12_composite';
                
                % 1
                for k=1:noOfExecutions
                    it = it+1;
                    [objfailureRateMR1,objfailureRateMR2, objcombinedFailureRateMR1MR2, ...
                    objcompositeMRFailureRate, classfailureRateMR1, classfailureRateMR2, ...
                    classcombinedFailureRateMR1MR2, classcompositeMRFailureRate, ...
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.flip_left_right, @MRs.flip_up_down, net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'flipUpDown';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,7} = classfailureRateMR1;                    
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,8} = classfailureRateMR2;                    
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;                    
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,10} = classcompositeMRFailureRate;                    
                    expResults{it,11} = tMR1;
                    expResults{it,12} = tMR2;
                    expResults{it,13} = tCompositeMR;
                end
                xlswrite(results_file,expResults);
                
                % 2
                for k=1:noOfExecutions
                    it = it+1;
                    [objfailureRateMR1,objfailureRateMR2, objcombinedFailureRateMR1MR2, ...
                    objcompositeMRFailureRate, classfailureRateMR1, classfailureRateMR2, ...
                    classcombinedFailureRateMR1MR2, classcompositeMRFailureRate, ...
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.flip_left_right, @MRs.rotate_image5m, net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'rotateMinus5deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,7} = classfailureRateMR1;                    
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,8} = classfailureRateMR2;                    
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;                    
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,10} = classcompositeMRFailureRate;                    
                    expResults{it,11} = tMR1;
                    expResults{it,12} = tMR2;
                    expResults{it,13} = tCompositeMR;
                end
                xlswrite(results_file,expResults);
            
                % 3
                for k=1:noOfExecutions
                    it = it+1;
                    [objfailureRateMR1,objfailureRateMR2, objcombinedFailureRateMR1MR2, ...
                    objcompositeMRFailureRate, classfailureRateMR1, classfailureRateMR2, ...
                    classcombinedFailureRateMR1MR2, classcompositeMRFailureRate, ...
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.flip_left_right, @MRs.rotate_image5p, net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'rotatePlus5deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,7} = classfailureRateMR1;                    
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,8} = classfailureRateMR2;                    
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;                    
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,10} = classcompositeMRFailureRate;                    
                    expResults{it,11} = tMR1;
                    expResults{it,12} = tMR2;
                    expResults{it,13} = tCompositeMR;
                end
                xlswrite(results_file,expResults);
                
                % 4
                for k=1:noOfExecutions
                    it = it+1;
                    [objfailureRateMR1,objfailureRateMR2, objcombinedFailureRateMR1MR2, ...
                    objcompositeMRFailureRate, classfailureRateMR1, classfailureRateMR2, ...
                    classcombinedFailureRateMR1MR2, classcompositeMRFailureRate, ...
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.flip_left_right, @MRs.shear_image20m, net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'shearMinus20deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,7} = classfailureRateMR1;                    
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,8} = classfailureRateMR2;                    
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;                    
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,10} = classcompositeMRFailureRate;                    
                    expResults{it,11} = tMR1;
                    expResults{it,12} = tMR2;
                    expResults{it,13} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                % 5
                for k=1:noOfExecutions
                    it = it+1;
                    [objfailureRateMR1,objfailureRateMR2, objcombinedFailureRateMR1MR2, ...
                    objcompositeMRFailureRate, classfailureRateMR1, classfailureRateMR2, ...
                    classcombinedFailureRateMR1MR2, classcompositeMRFailureRate, ...
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.flip_left_right, @MRs.shear_image20p, net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'shearPlus20deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,7} = classfailureRateMR1;                    
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,8} = classfailureRateMR2;                    
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;                    
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,10} = classcompositeMRFailureRate;                    
                    expResults{it,11} = tMR1;
                    expResults{it,12} = tMR2;
                    expResults{it,13} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                % 6
                for k=1:noOfExecutions
                    it = it+1;
                    [objfailureRateMR1,objfailureRateMR2, objcombinedFailureRateMR1MR2, ...
                    objcompositeMRFailureRate, classfailureRateMR1, classfailureRateMR2, ...
                    classcombinedFailureRateMR1MR2, classcompositeMRFailureRate, ...
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.flip_up_down, @MRs.rotate_image5m, net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'rotateMinus5deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,7} = classfailureRateMR1;                    
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,8} = classfailureRateMR2;                    
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;                    
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,10} = classcompositeMRFailureRate;                    
                    expResults{it,11} = tMR1;
                    expResults{it,12} = tMR2;
                    expResults{it,13} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                % 7
                for k=1:noOfExecutions
                    it = it+1;
                    [objfailureRateMR1,objfailureRateMR2, objcombinedFailureRateMR1MR2, ...
                    objcompositeMRFailureRate, classfailureRateMR1, classfailureRateMR2, ...
                    classcombinedFailureRateMR1MR2, classcompositeMRFailureRate, ...
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.flip_up_down, @MRs.rotate_image5p, net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'rotatePlus5deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,7} = classfailureRateMR1;                    
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,8} = classfailureRateMR2;                    
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;                    
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,10} = classcompositeMRFailureRate;                    
                    expResults{it,11} = tMR1;
                    expResults{it,12} = tMR2;
                    expResults{it,13} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                % 8
                for k=1:noOfExecutions
                    it = it+1;
                    [objfailureRateMR1,objfailureRateMR2, objcombinedFailureRateMR1MR2, ...
                    objcompositeMRFailureRate, classfailureRateMR1, classfailureRateMR2, ...
                    classcombinedFailureRateMR1MR2, classcompositeMRFailureRate, ...
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.flip_up_down, @MRs.shear_image20m, net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'shearMinus20deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,7} = classfailureRateMR1;                    
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,8} = classfailureRateMR2;                    
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;                    
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,10} = classcompositeMRFailureRate;                    
                    expResults{it,11} = tMR1;
                    expResults{it,12} = tMR2;
                    expResults{it,13} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                % 8
                for k=1:noOfExecutions
                    it = it+1;
                    [objfailureRateMR1,objfailureRateMR2, objcombinedFailureRateMR1MR2, ...
                    objcompositeMRFailureRate, classfailureRateMR1, classfailureRateMR2, ...
                    classcombinedFailureRateMR1MR2, classcompositeMRFailureRate, ...
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.flip_up_down, @MRs.shear_image20p, net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'shearPlus20deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,7} = classfailureRateMR1;                    
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,8} = classfailureRateMR2;                    
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;                    
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,10} = classcompositeMRFailureRate;                    
                    expResults{it,11} = tMR1;
                    expResults{it,12} = tMR2;
                    expResults{it,13} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                % 9
                for k=1:noOfExecutions
                    it = it+1;
                    [objfailureRateMR1,objfailureRateMR2, objcombinedFailureRateMR1MR2, ...
                    objcompositeMRFailureRate, classfailureRateMR1, classfailureRateMR2, ...
                    classcombinedFailureRateMR1MR2, classcompositeMRFailureRate, ...
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.rotate_image5m, @MRs.shear_image20m, net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'rotateMinus5deg';
                    expResults{it,2} = 'shearMinus20degrees';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,7} = classfailureRateMR1;                    
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,8} = classfailureRateMR2;                    
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;                    
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,10} = classcompositeMRFailureRate;                    
                    expResults{it,11} = tMR1;
                    expResults{it,12} = tMR2;
                    expResults{it,13} = tCompositeMR;
                end
                xlswrite(results_file, expResults);  
                
                % 10
                for k=1:noOfExecutions
                    it = it+1;
                    [objfailureRateMR1,objfailureRateMR2, objcombinedFailureRateMR1MR2, ...
                    objcompositeMRFailureRate, classfailureRateMR1, classfailureRateMR2, ...
                    classcombinedFailureRateMR1MR2, classcompositeMRFailureRate, ...
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.rotate_image5m, @MRs.shear_image20p, net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'rotateMinus5deg';
                    expResults{it,2} = 'shearPlus20degrees';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,7} = classfailureRateMR1;                    
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,8} = classfailureRateMR2;                    
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;                    
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,10} = classcompositeMRFailureRate;                    
                    expResults{it,11} = tMR1;
                    expResults{it,12} = tMR2;
                    expResults{it,13} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                rmpath('models/pretrained-yolo-v4-main/src');
                rmpath('models/pretrained-yolo-v4-main');  
            end
            
        case 'efficientDetD0-coco'

        case 'tinyYOLOv2-coco'

        case 'tiny-yolov3-coco'

        otherwise
            fprintf('No actions found for %s',modelNames{i});
    end
end

