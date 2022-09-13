%% Extension of Cost-Effectiveness of Composite Metamorphic Relations for Testing Deep Learning Systems
% Experimental setup includes
% 4 DL models:
%       'YOLOv4-coco','efficientDetD0-coco','tinyYOLOv2-coco','tiny-yolov3-coco'
clear;
clc;
%modelNames = {'tinyYOLOv2-coco', 'tiny-yolov3-coco', 'YOLOv4-coco', 'efficientDetD0-coco'};
modelNames = {'efficientDetD0-coco'};
datasets = {'datasets/oid/oidvehicle','datasets/oid/oidanimal','datasets/oid/oidfood', 'datasets/oid/oidfurniture','datasets/coco/cocoperson', ...
    'datasets/coco/cocovehicle','datasets/coco/cocoanimal','datasets/coco/cocofood','datasets/coco/cocofurniture','datasets/oid/oidperson'};    % list of datasets
%datasets = {'datasets/coco/cocofood','datasets/coco/cocofurniture','datasets/oid/oidperson'};    % list of datasets
results_dir = 'results';                % results dir
% create results dir if not existing
if ~exist(results_dir, 'dir')
   mkdir(results_dir)
end

noOfExecutions = 1; % no. of executions per model per dataset

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
            model = helper.downloadPretrainedYOLOv4(modelNames{i});
            net = model.net;
            % Get classnames of COCO dataset.
            classNames = helper.getCOCOClassNames;
            % Get anchors used in training of the pretrained model.
            anchors = helper.getAnchors(modelNames{i});
            % Specify environment
            executionEnvironment = 'auto';       
            for j = 1 : length(datasets)
                % create results file
                subset = split(datasets{j}, "/" );
                results_file = fullfile(model_results_dir, strcat(modelNames{i},'_',string(subset(length(subset))),'.xlsx'));
                fprintf('Dataset: %s\n', string(subset(length(subset))));
                it = 1;
                expResults{1,1} = 'MR1';
                expResults{1,2} = 'MR2';
                expResults{1,3} = 'objfailureRateMR1';
                expResults{1,4} = 'objfailureRateMR2';                
                expResults{1,5} = 'objfailureRateMR1_MR2_combined';
                expResults{1,6} = 'objfailureRateMR1_2_composite';
                expResults{1,7} = 'classfailureRateMR1';
                expResults{1,8} = 'classfailureRateMR2';                
                expResults{1,9} = 'classfailureRateMR1_MR2_combined';
                expResults{1,10} = 'classfailureRateMR1_2_composite';
                expResults{1,11} = 'objClassDetectFailureRateMR1';
                expResults{1,12} = 'objClassDetectFailureRateMR2';
                expResults{1,13} = 'objClassDetectFailureRateMR1_MR2';
                expResults{1,14} = 'objClassDetectFailureRateMR12';
                expResults{1,15} = 'objDetectCompositeMRUniqueFaults';
                expResults{1,16} = 'objClassCompositeMRUniqueFaults';
                expResults{1,17} = 'compositeMRUniqueFaults';                
                expResults{1,18} = 'timeMR1';
                expResults{1,19} = 'timeMR2';
                expResults{1,20} = 'timeMR12';
                expResults{1,21} = 'timeMR12_composite';

                fprintf('composite MR1\n')
                % 1
                for k=1:noOfExecutions
                    fprintf('Composite MR1 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.flip_left_right, @MRs.flip_up_down, net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'flipUpDown';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file,expResults);
                
                fprintf('composite MR2\n')
                % 2
                for k=1:noOfExecutions
                    fprintf('Composite MR2 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.flip_left_right, @MRs.rotate_image5m, net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'rotateMinus5deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file,expResults);
            
                fprintf('composite MR3\n')
                % 3
                for k=1:noOfExecutions
                    fprintf('Composite MR3 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.flip_left_right, @MRs.rotate_image5p, net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'rotatePlus5deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file,expResults);
                
                fprintf('composite MR4\n')
                % 4
                for k=1:noOfExecutions
                    fprintf('Composite MR4 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.flip_left_right, @MRs.shear_image20m, net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'shearMinus20deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR5\n')
                % 5
                for k=1:noOfExecutions
                    fprintf('Composite MR5 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.flip_left_right, @MRs.shear_image20p, net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'shearPlus20deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR6\n')
                % 6
                for k=1:noOfExecutions
                    fprintf('Composite MR6 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.flip_up_down, @MRs.rotate_image5m, net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'rotateMinus5deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR7\n')
                % 7
                for k=1:noOfExecutions
                    fprintf('Composite MR7 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.flip_up_down, @MRs.rotate_image5p, net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'rotatePlus5deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR8\n')
                % 8
                for k=1:noOfExecutions
                    fprintf('Composite MR8 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.flip_up_down, @MRs.shear_image20m, net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'shearMinus20deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR9\n')
                % 9
                for k=1:noOfExecutions
                    fprintf('Composite MR9 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.flip_up_down, @MRs.shear_image20p, net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'shearPlus20deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR10\n')
                % 10
                for k=1:noOfExecutions
                    fprintf('Composite MR10 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.rotate_image5m, @MRs.shear_image20m, net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'rotateMinus5deg';
                    expResults{it,2} = 'shearMinus20degrees';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);  
                
                fprintf('composite MR11\n')
                % 11
                for k=1:noOfExecutions
                    fprintf('Composite MR11 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.rotate_image5m, @MRs.shear_image20p, net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'rotateMinus5deg';
                    expResults{it,2} = 'shearPlus20degrees';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);

                fprintf('composite MR12\n')
                % 12
                for k=1:noOfExecutions
                    fprintf('Composite MR12 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.flip_left_right, @MRs.blur_image, net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'blurImage';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR13\n')
                % 13
                for k=1:noOfExecutions
                    fprintf('Composite MR13 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.flip_up_down, @MRs.blur_image, net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'blurImage';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR14\n')
                % 14
                for k=1:noOfExecutions
                    fprintf('Composite MR14 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.rotate_image5m, @MRs.blur_image, net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'rotateMinus5deg';
                    expResults{it,2} = 'blurImage';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR15\n')
                % 15
                for k=1:noOfExecutions
                    fprintf('Composite MR15 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.rotate_image5p, @MRs.shear_image20m, net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'shearMinus20degrees';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);

                fprintf('composite MR16\n')
                % 16
                for k=1:noOfExecutions
                    fprintf('Composite MR16 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.rotate_image5p, @MRs.shear_image20p, net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'shearPlus20degrees';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR17\n')
                % 17
                for k=1:noOfExecutions
                    fprintf('Composite MR17 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.rotate_image5p, @MRs.blur_image, net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'blurImage';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR18\n')
                % 18
                for k=1:noOfExecutions
                    fprintf('Composite MR18 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.shear_image20m,@MRs.blur_image,  net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'shearMinus20degrees';
                    expResults{it,2} = 'blurImage';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR19\n')
                % 19
                for k=1:noOfExecutions
                    fprintf('Composite MR19 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.shear_image20p,@MRs.blur_image,  net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'shearPlus20degrees';
                    expResults{it,2} = 'blurImage';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);

                fprintf('composite MR20\n')
                % 20
                for k=1:noOfExecutions
                    fprintf('Composite MR20 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.flip_left_right,@MRs.brightnessPlus20,  net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'brightnessPlus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR21\n')
                % 21
                for k=1:noOfExecutions
                    fprintf('Composite MR21 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.flip_up_down,@MRs.brightnessPlus20,  net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'brightnessPlus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR22\n')
                % 20
                for k=1:noOfExecutions
                    fprintf('Composite MR22 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.rotate_image5p,@MRs.brightnessPlus20,  net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'brightnessPlus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR23\n');
                % 23
                for k=1:noOfExecutions
                    fprintf('Composite MR23 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.shear_image20p,@MRs.brightnessPlus20,  net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'shearPlus20deg';
                    expResults{it,2} = 'brightnessPlus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR24\n')
                % 24
                for k=1:noOfExecutions
                    fprintf('Composite MR24 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.flip_left_right,@MRs.brightnessMinus20,  net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'brightnessMinus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR25\n')
                % 25
                for k=1:noOfExecutions
                    fprintf('Composite MR25 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.flip_up_down,@MRs.brightnessMinus20,  net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'brightnessMinus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR26\n')
                % 26
                for k=1:noOfExecutions
                    fprintf('Composite MR26 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.rotate_image5p,@MRs.brightnessMinus20,  net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'brightnessMinus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR27\n');
                % 27
                for k=1:noOfExecutions
                    fprintf('Composite MR27 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.shear_image20p,@MRs.brightnessMinus20,  net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'shearPlus20deg';
                    expResults{it,2} = 'brightnessMinus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);

                fprintf('composite MR28\n')
                % 28
                for k=1:noOfExecutions
                    fprintf('Composite MR28 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.flip_left_right,@MRs.fisheye,  net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'fisheye';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR29\n')
                % 29
                for k=1:noOfExecutions
                    fprintf('Composite MR29 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.flip_up_down,@MRs.fisheye,  net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'fisheye';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR30\n')
                % 30
                for k=1:noOfExecutions
                    fprintf('Composite MR30 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.rotate_image5p,@MRs.fisheye,  net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'fisheye';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR31\n');
                % 31
                for k=1:noOfExecutions
                    fprintf('Composite MR31 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.shear_image20p,@MRs.fisheye,  net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'shearPlus20deg';
                    expResults{it,2} = 'fisheye';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);

                fprintf('composite MR32\n')
                % 32
                for k=1:noOfExecutions
                    fprintf('Composite MR32 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.flip_left_right,@MRs.contrastUp,  net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'contrastUp';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR33\n')
                % 33
                for k=1:noOfExecutions
                    fprintf('Composite MR33 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.flip_up_down,@MRs.contrastUp,  net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'contrastUp';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR34\n')
                % 34
                for k=1:noOfExecutions
                    fprintf('Composite MR34 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.rotate_image5p,@MRs.contrastUp,  net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'contrastUp';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR35\n');
                % 35
                for k=1:noOfExecutions
                    fprintf('Composite MR35 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.shear_image20p,@MRs.contrastUp,  net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'shearPlus20deg';
                    expResults{it,2} = 'contrastUp';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR36\n')
                % 36
                for k=1:noOfExecutions
                    fprintf('Composite MR36 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.flip_left_right,@MRs.contrastDown,  net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'contrastDown';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR37\n')
                % 37
                for k=1:noOfExecutions
                    fprintf('Composite MR37 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.flip_up_down,@MRs.contrastDown,  net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'contrastDown';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR38\n')
                % 38
                for k=1:noOfExecutions
                    fprintf('Composite MR38 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.rotate_image5p,@MRs.contrastDown,  net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'contrastDown';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR39\n');
                % 39
                for k=1:noOfExecutions
                    fprintf('Composite MR39 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.shear_image20p,@MRs.contrastDown,  net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'shearPlus20deg';
                    expResults{it,2} = 'contrastDown';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR40\n')
                % 40
                for k=1:noOfExecutions
                    fprintf('Composite MR40 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.fisheye,@MRs.brightnessPlus20,  net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'fisheye';
                    expResults{it,2} = 'brightnessPlus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR41\n')
                % 41
                for k=1:noOfExecutions
                    fprintf('Composite MR41 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.fisheye,@MRs.brightnessMinus20,  net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'fisheye';
                    expResults{it,2} = 'brightnessMinus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR42\n')
                % 42
                for k=1:noOfExecutions
                    fprintf('Composite MR42 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.fisheye,@MRs.contrastUp,  net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'fisheye';
                    expResults{it,2} = 'contrastUp';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR43\n');
                % 43
                for k=1:noOfExecutions
                    fprintf('Composite MR43 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.fisheye,@MRs.contrastDown,  net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'fisheye';
                    expResults{it,2} = 'contrastDown';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);

                fprintf('composite MR44\n');
                % 44
                for k=1:noOfExecutions
                    fprintf('Composite MR44 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov4(datasets{j},@MRs.fisheye,@MRs.blur_image,  net, anchors, classNames, executionEnvironment);
                    expResults{it,1} = 'fisheye';
                    expResults{it,2} = 'blurImage';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
            end
            rmpath('models/pretrained-yolo-v4-main/src');
            rmpath('models/pretrained-yolo-v4-main');  
            
        case 'efficientDetD0-coco'
            % Check if efficientDetD0 dir exists
            efficientd_dir = 'models/pretrained-efficientdet-d0-main';
            if ~exist(efficientd_dir, 'dir')
                fprintf('efficientDetD0 dir not found! exiting...\n')
               return;
            end
            % add paths for efficientDetD0            
            addpath('models/pretrained-efficientdet-d0-main/src');
            addpath('models/pretrained-efficientdet-d0-main');   

            model_results_dir = fullfile(results_dir,modelNames{i});
            if ~exist(model_results_dir, 'dir')
               mkdir(model_results_dir);
            end
            % download model - function from downloadPretrainedEfficientDetD0.m
            model = downloadPretrainedEfficientDetD0;
            net = model.net;
            % Get classnames for COCO dataset.
            classNames = helper.getCOCOClasess;
            % Perform detection using pretrained model.
            executionEnvironment = 'auto';
            
            for j = 1 : length(datasets)
                % create results file
                subset = split(datasets{j}, "/" );
                results_file = fullfile(model_results_dir, strcat(modelNames{i},'_',string(subset(length(subset))),'.xlsx'));
                fprintf('Dataset: %s\n', string(subset(length(subset))));
                it = 1;
                expResults{1,1} = 'MR1';
                expResults{1,2} = 'MR2';
                expResults{1,3} = 'objfailureRateMR1';
                expResults{1,4} = 'objfailureRateMR2';                
                expResults{1,5} = 'objfailureRateMR1_MR2_combined';
                expResults{1,6} = 'objfailureRateMR1_2_composite';
                expResults{1,7} = 'classfailureRateMR1';
                expResults{1,8} = 'classfailureRateMR2';                
                expResults{1,9} = 'classfailureRateMR1_MR2_combined';
                expResults{1,10} = 'classfailureRateMR1_2_composite';
                expResults{1,11} = 'objClassDetectFailureRateMR1';
                expResults{1,12} = 'objClassDetectFailureRateMR2';
                expResults{1,13} = 'objClassDetectFailureRateMR1_MR2';
                expResults{1,14} = 'objClassDetectFailureRateMR12';
                expResults{1,15} = 'objDetectCompositeMRUniqueFaults';
                expResults{1,16} = 'objClassCompositeMRUniqueFaults';
                expResults{1,17} = 'compositeMRUniqueFaults';                
                expResults{1,18} = 'timeMR1';
                expResults{1,19} = 'timeMR2';
                expResults{1,20} = 'timeMR12';
                expResults{1,21} = 'timeMR12_composite';
                
                fprintf('composite MR1\n')
                % 1
                for k=1:noOfExecutions
                    fprintf('Composite MR1 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.flip_left_right, @MRs.flip_up_down, net, classNames, executionEnvironment);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'flipUpDown';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file,expResults);      
                
                fprintf('composite MR2\n')
                % 2
                for k=1:noOfExecutions
                    fprintf('Composite MR2 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.flip_left_right, @MRs.rotate_image5m, net, classNames, executionEnvironment);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'rotateMinus5deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file,expResults);
            
                fprintf('composite MR3\n')
                % 3
                for k=1:noOfExecutions
                    fprintf('Composite MR3 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.flip_left_right, @MRs.rotate_image5p, net, classNames, executionEnvironment);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'rotatePlus5deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file,expResults);
                
                fprintf('composite MR4\n')
                % 4
                for k=1:noOfExecutions
                    fprintf('Composite MR4 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.flip_left_right, @MRs.shear_image20m, net, classNames, executionEnvironment);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'shearMinus20deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR5\n')
                % 5
                for k=1:noOfExecutions
                    fprintf('Composite MR5 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.flip_left_right, @MRs.shear_image20p, net, classNames, executionEnvironment);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'shearPlus20deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR6\n')
                % 6
                for k=1:noOfExecutions
                    fprintf('Composite MR6 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.flip_up_down, @MRs.rotate_image5m, net, classNames, executionEnvironment);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'rotateMinus5deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR7\n')
                % 7
                for k=1:noOfExecutions
                    fprintf('Composite MR7 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.flip_up_down, @MRs.rotate_image5p, net, classNames, executionEnvironment);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'rotatePlus5deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR8\n')
                % 8
                for k=1:noOfExecutions
                    fprintf('Composite MR8 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.flip_up_down, @MRs.shear_image20m, net, classNames, executionEnvironment);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'shearMinus20deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR9\n')
                % 9
                for k=1:noOfExecutions
                    fprintf('Composite MR9 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.flip_up_down, @MRs.shear_image20p, net, classNames, executionEnvironment);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'shearPlus20deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR10\n')
                % 10
                for k=1:noOfExecutions
                    fprintf('Composite MR10 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.rotate_image5m, @MRs.shear_image20m, net, classNames, executionEnvironment);
                    expResults{it,1} = 'rotateMinus5deg';
                    expResults{it,2} = 'shearMinus20degrees';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);  
                
                fprintf('composite MR11\n')
                % 11
                for k=1:noOfExecutions
                    fprintf('Composite MR11 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.rotate_image5m, @MRs.shear_image20p, net, classNames, executionEnvironment);
                    expResults{it,1} = 'rotateMinus5deg';
                    expResults{it,2} = 'shearPlus20degrees';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);    
                
                fprintf('composite MR12\n')
                % 12
                for k=1:noOfExecutions
                    fprintf('Composite MR12 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.flip_left_right, @MRs.blur_image, net, classNames, executionEnvironment);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'blurImage';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR13\n')
                % 13
                for k=1:noOfExecutions
                    fprintf('Composite MR13 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.flip_up_down, @MRs.blur_image, net, classNames, executionEnvironment);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'blurImage';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR14\n')
                % 14
                for k=1:noOfExecutions
                    fprintf('Composite MR14 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.rotate_image5m, @MRs.blur_image, net, classNames, executionEnvironment);
                    expResults{it,1} = 'rotateMinus5deg';
                    expResults{it,2} = 'blurImage';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR15\n')
                % 15
                for k=1:noOfExecutions
                    fprintf('Composite MR15 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.rotate_image5p, @MRs.shear_image20m, net, classNames, executionEnvironment);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'shearMinus20degrees';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);

                fprintf('composite MR16\n')
                % 16
                for k=1:noOfExecutions
                    fprintf('Composite MR16 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.rotate_image5p, @MRs.shear_image20p, net, classNames, executionEnvironment);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'shearPlus20degrees';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR17\n')
                % 17
                for k=1:noOfExecutions
                    fprintf('Composite MR17 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.rotate_image5p, @MRs.blur_image, net, classNames, executionEnvironment);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'blurImage';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR18\n')
                % 18
                for k=1:noOfExecutions
                    fprintf('Composite MR18 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.shear_image20m,@MRs.blur_image,  net, classNames, executionEnvironment);
                    expResults{it,1} = 'shearMinus20degrees';
                    expResults{it,2} = 'blurImage';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR19\n')
                % 19
                for k=1:noOfExecutions
                    fprintf('Composite MR19 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.shear_image20p,@MRs.blur_image,  net, classNames, executionEnvironment);
                    expResults{it,1} = 'shearPlus20degrees';
                    expResults{it,2} = 'blurImage';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);

                fprintf('composite MR20\n')
                % 20
                for k=1:noOfExecutions
                    fprintf('Composite MR20 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.flip_left_right,@MRs.brightnessPlus20,  net,  classNames, executionEnvironment);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'brightnessPlus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR21\n')
                % 21
                for k=1:noOfExecutions
                    fprintf('Composite MR21 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.flip_up_down,@MRs.brightnessPlus20,  net,  classNames, executionEnvironment);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'brightnessPlus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR22\n')
                % 20
                for k=1:noOfExecutions
                    fprintf('Composite MR22 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.rotate_image5p,@MRs.brightnessPlus20,  net,  classNames, executionEnvironment);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'brightnessPlus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR23\n');
                % 23
                for k=1:noOfExecutions
                    fprintf('Composite MR23 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.shear_image20p,@MRs.brightnessPlus20,  net,  classNames, executionEnvironment);
                    expResults{it,1} = 'shearPlus20deg';
                    expResults{it,2} = 'brightnessPlus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR24\n')
                % 24
                for k=1:noOfExecutions
                    fprintf('Composite MR24 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.flip_left_right,@MRs.brightnessMinus20,  net,  classNames, executionEnvironment);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'brightnessMinus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR25\n')
                % 25
                for k=1:noOfExecutions
                    fprintf('Composite MR25 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.flip_up_down,@MRs.brightnessMinus20,  net,  classNames, executionEnvironment);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'brightnessMinus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR26\n')
                % 26
                for k=1:noOfExecutions
                    fprintf('Composite MR26 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.rotate_image5p,@MRs.brightnessMinus20,  net,  classNames, executionEnvironment);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'brightnessMinus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR27\n');
                % 27
                for k=1:noOfExecutions
                    fprintf('Composite MR27 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.shear_image20p,@MRs.brightnessMinus20,  net,  classNames, executionEnvironment);
                    expResults{it,1} = 'shearPlus20deg';
                    expResults{it,2} = 'brightnessMinus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);

                fprintf('composite MR28\n')
                % 28
                for k=1:noOfExecutions
                    fprintf('Composite MR28 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.flip_left_right,@MRs.fisheye,  net,  classNames, executionEnvironment);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'fisheye';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR29\n')
                % 29
                for k=1:noOfExecutions
                    fprintf('Composite MR29 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.flip_up_down,@MRs.fisheye,  net,  classNames, executionEnvironment);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'fisheye';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR30\n')
                % 30
                for k=1:noOfExecutions
                    fprintf('Composite MR30 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.rotate_image5p,@MRs.fisheye,  net,  classNames, executionEnvironment);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'fisheye';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR31\n');
                % 31
                for k=1:noOfExecutions
                    fprintf('Composite MR31 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.shear_image20p,@MRs.fisheye,  net,  classNames, executionEnvironment);
                    expResults{it,1} = 'shearPlus20deg';
                    expResults{it,2} = 'fisheye';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);

                fprintf('composite MR32\n')
                % 32
                for k=1:noOfExecutions
                    fprintf('Composite MR32 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.flip_left_right,@MRs.contrastUp,  net,  classNames, executionEnvironment);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'contrastUp';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR33\n')
                % 33
                for k=1:noOfExecutions
                    fprintf('Composite MR33 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.flip_up_down,@MRs.contrastUp,  net,  classNames, executionEnvironment);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'contrastUp';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR34\n')
                % 34
                for k=1:noOfExecutions
                    fprintf('Composite MR34 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.rotate_image5p,@MRs.contrastUp,  net,  classNames, executionEnvironment);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'contrastUp';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR35\n');
                % 35
                for k=1:noOfExecutions
                    fprintf('Composite MR35 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.shear_image20p,@MRs.contrastUp,  net,  classNames, executionEnvironment);
                    expResults{it,1} = 'shearPlus20deg';
                    expResults{it,2} = 'contrastUp';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR36\n')
                % 36
                for k=1:noOfExecutions
                    fprintf('Composite MR36 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.flip_left_right,@MRs.contrastDown,  net,  classNames, executionEnvironment);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'contrastDown';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR37\n')
                % 37
                for k=1:noOfExecutions
                    fprintf('Composite MR37 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.flip_up_down,@MRs.contrastDown,  net,  classNames, executionEnvironment);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'contrastDown';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR38\n')
                % 38
                for k=1:noOfExecutions
                    fprintf('Composite MR38 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.rotate_image5p,@MRs.contrastDown,  net,  classNames, executionEnvironment);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'contrastDown';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR39\n');
                % 39
                for k=1:noOfExecutions
                    fprintf('Composite MR39 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.shear_image20p,@MRs.contrastDown,  net,  classNames, executionEnvironment);
                    expResults{it,1} = 'shearPlus20deg';
                    expResults{it,2} = 'contrastDown';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR40\n')
                % 40
                for k=1:noOfExecutions
                    fprintf('Composite MR40 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.fisheye,@MRs.brightnessPlus20,  net,  classNames, executionEnvironment);
                    expResults{it,1} = 'fisheye';
                    expResults{it,2} = 'brightnessPlus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR41\n')
                % 41
                for k=1:noOfExecutions
                    fprintf('Composite MR41 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.fisheye,@MRs.brightnessMinus20,  net,  classNames, executionEnvironment);
                    expResults{it,1} = 'fisheye';
                    expResults{it,2} = 'brightnessMinus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR42\n')
                % 42
                for k=1:noOfExecutions
                    fprintf('Composite MR42 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.fisheye,@MRs.contrastUp,  net,  classNames, executionEnvironment);
                    expResults{it,1} = 'fisheye';
                    expResults{it,2} = 'contrastUp';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR43\n');
                % 43
                for k=1:noOfExecutions
                    fprintf('Composite MR43 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.fisheye,@MRs.contrastDown,  net,  classNames, executionEnvironment);
                    expResults{it,1} = 'fisheye';
                    expResults{it,2} = 'contrastDown';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);

                fprintf('composite MR44\n');
                % 44
                for k=1:noOfExecutions
                    fprintf('Composite MR44 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(datasets{j},@MRs.fisheye,@MRs.blur_image,  net,  classNames, executionEnvironment);
                    expResults{it,1} = 'fisheye';
                    expResults{it,2} = 'blurImage';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
            end
            rmpath('models/pretrained-efficientdet-d0-main/src');
            rmpath('models/pretrained-efficientdet-d0-main');
    
        case 'tinyYOLOv2-coco'
            % Check if tinyYOLOv2 dir exists
            yolov2_dir = 'models/yolo-v2-main';
            if ~exist(yolov2_dir, 'dir')
                fprintf('yolov2_dir dir not found! exiting...\n')
               return;
            end
            % add paths for yolo-v2            
            addpath('models/yolo-v2-main/src');
            
            model_results_dir = fullfile(results_dir,modelNames{i});
            if ~exist(model_results_dir, 'dir')
               mkdir(model_results_dir);
            end
            model = load(['models/yolo-v2-main/', modelNames{i}, '.mat']);

            detector = model.yolov2Detector;

            for j = 1 : length(datasets)
                subset = split(datasets{j}, "/" );
                results_file = fullfile(model_results_dir, strcat(modelNames{i},'_',string(subset(length(subset))),'.xlsx'));
                fprintf('Dataset: %s\n', string(subset(length(subset))));
                it = 1;
                expResults{1,1} = 'MR1';
                expResults{1,2} = 'MR2';
                expResults{1,3} = 'objfailureRateMR1';
                expResults{1,4} = 'objfailureRateMR2';                
                expResults{1,5} = 'objfailureRateMR1_MR2_combined';
                expResults{1,6} = 'objfailureRateMR1_2_composite';
                expResults{1,7} = 'classfailureRateMR1';
                expResults{1,8} = 'classfailureRateMR2';                
                expResults{1,9} = 'classfailureRateMR1_MR2_combined';
                expResults{1,10} = 'classfailureRateMR1_2_composite';
                expResults{1,11} = 'objClassDetectFailureRateMR1';
                expResults{1,12} = 'objClassDetectFailureRateMR2';
                expResults{1,13} = 'objClassDetectFailureRateMR1_MR2';
                expResults{1,14} = 'objClassDetectFailureRateMR12';
                expResults{1,15} = 'objDetectCompositeMRUniqueFaults';
                expResults{1,16} = 'objClassCompositeMRUniqueFaults';
                expResults{1,17} = 'compositeMRUniqueFaults';                
                expResults{1,18} = 'timeMR1';
                expResults{1,19} = 'timeMR2';
                expResults{1,20} = 'timeMR12';
                expResults{1,21} = 'timeMR12_composite';
                
                fprintf('composite MR1\n')
                % 1
                for k=1:noOfExecutions
                    fprintf('Composite MR1 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.flip_left_right, @MRs.flip_up_down, detector);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'flipUpDown';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file,expResults);
                
                fprintf('composite MR2\n')
                % 2
                for k=1:noOfExecutions
                    fprintf('Composite MR2 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.flip_left_right, @MRs.rotate_image5m, detector);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'rotateMinus5deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file,expResults);
            
                fprintf('composite MR3\n')
                % 3
                for k=1:noOfExecutions
                    fprintf('Composite MR3 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.flip_left_right, @MRs.rotate_image5p, detector);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'rotatePlus5deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file,expResults);
                
                fprintf('composite MR4\n')
                % 4
                for k=1:noOfExecutions
                    fprintf('Composite MR4 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.flip_left_right, @MRs.shear_image20m, detector);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'shearMinus20deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR5\n')
                % 5
                for k=1:noOfExecutions
                    fprintf('Composite MR5 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.flip_left_right, @MRs.shear_image20p, detector);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'shearPlus20deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR6\n')
                % 6
                for k=1:noOfExecutions
                    fprintf('Composite MR6 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.flip_up_down, @MRs.rotate_image5m, detector);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'rotateMinus5deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR7\n')
                % 7
                for k=1:noOfExecutions
                    fprintf('Composite MR7 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.flip_up_down, @MRs.rotate_image5p, detector);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'rotatePlus5deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR8\n')
                % 8
                for k=1:noOfExecutions
                    fprintf('Composite MR8 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.flip_up_down, @MRs.shear_image20m, detector);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'shearMinus20deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR9\n')
                % 8
                for k=1:noOfExecutions
                    fprintf('Composite MR9 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.flip_up_down, @MRs.shear_image20p, detector);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'shearPlus20deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR10\n')
                % 9
                for k=1:noOfExecutions
                    fprintf('Composite MR10 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.rotate_image5m, @MRs.shear_image20m,  detector);
                    expResults{it,1} = 'rotateMinus5deg';
                    expResults{it,2} = 'shearMinus20degrees';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);  
                
                fprintf('composite MR11\n')
                % 10
                for k=1:noOfExecutions
                    fprintf('Composite MR11 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1,objfailureRateMR2, objcombinedFailureRateMR1MR2, ...
                    objcompositeMRFailureRate, classfailureRateMR1, classfailureRateMR2, ...
                    classcombinedFailureRateMR1MR2, classcompositeMRFailureRate, ...
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.rotate_image5m, @MRs.shear_image20p,  detector);
                    expResults{it,1} = 'rotateMinus5deg';
                    expResults{it,2} = 'shearPlus20degrees';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);                
                
                fprintf('composite MR12\n')
                % 12
                for k=1:noOfExecutions
                    fprintf('Composite MR12 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.flip_left_right, @MRs.blur_image, detector);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'blurImage';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR13\n')
                % 13
                for k=1:noOfExecutions
                    fprintf('Composite MR13 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.flip_up_down, @MRs.blur_image, detector);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'blurImage';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR14\n')
                % 14
                for k=1:noOfExecutions
                    fprintf('Composite MR14 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.rotate_image5m, @MRs.blur_image, detector);
                    expResults{it,1} = 'rotateMinus5deg';
                    expResults{it,2} = 'blurImage';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR15\n')
                % 15
                for k=1:noOfExecutions
                    fprintf('Composite MR15 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.rotate_image5p, @MRs.shear_image20m, detector);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'shearMinus20degrees';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);

                fprintf('composite MR16\n')
                % 16
                for k=1:noOfExecutions
                    fprintf('Composite MR16 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.rotate_image5p, @MRs.shear_image20p, detector);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'shearPlus20degrees';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR17\n')
                % 17
                for k=1:noOfExecutions
                    fprintf('Composite MR17 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.rotate_image5p, @MRs.blur_image, detector);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'blurImage';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR18\n')
                % 18
                for k=1:noOfExecutions
                    fprintf('Composite MR18 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.shear_image20m,@MRs.blur_image,  detector);
                    expResults{it,1} = 'shearMinus20degrees';
                    expResults{it,2} = 'blurImage';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR19\n')
                % 19
                for k=1:noOfExecutions
                    fprintf('Composite MR19 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.shear_image20p,@MRs.blur_image, detector);
                    expResults{it,1} = 'shearPlus20degrees';
                    expResults{it,2} = 'blurImage';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);                 

                fprintf('composite MR20\n')
                % 20
                for k=1:noOfExecutions
                    fprintf('Composite MR20 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.flip_left_right,@MRs.brightnessPlus20,  detector);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'brightnessPlus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR21\n')
                % 21
                for k=1:noOfExecutions
                    fprintf('Composite MR21 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.flip_up_down,@MRs.brightnessPlus20, detector);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'brightnessPlus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR22\n')
                % 20
                for k=1:noOfExecutions
                    fprintf('Composite MR22 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.rotate_image5p,@MRs.brightnessPlus20, detector);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'brightnessPlus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR23\n');
                % 23
                for k=1:noOfExecutions
                    fprintf('Composite MR23 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.shear_image20p,@MRs.brightnessPlus20, detector);
                    expResults{it,1} = 'shearPlus20deg';
                    expResults{it,2} = 'brightnessPlus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR24\n')
                % 24
                for k=1:noOfExecutions
                    fprintf('Composite MR24 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.flip_left_right,@MRs.brightnessMinus20,  detector);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'brightnessMinus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR25\n')
                % 25
                for k=1:noOfExecutions
                    fprintf('Composite MR25 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.flip_up_down,@MRs.brightnessMinus20, detector);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'brightnessMinus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR26\n')
                % 26
                for k=1:noOfExecutions
                    fprintf('Composite MR26 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.rotate_image5p,@MRs.brightnessMinus20,  detector);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'brightnessMinus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR27\n');
                % 27
                for k=1:noOfExecutions
                    fprintf('Composite MR27 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.shear_image20p,@MRs.brightnessMinus20,  detector);
                    expResults{it,1} = 'shearPlus20deg';
                    expResults{it,2} = 'brightnessMinus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);

                fprintf('composite MR28\n')
                % 28
                for k=1:noOfExecutions
                    fprintf('Composite MR28 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.flip_left_right,@MRs.fisheye, detector);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'fisheye';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR29\n')
                % 29
                for k=1:noOfExecutions
                    fprintf('Composite MR29 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.flip_up_down,@MRs.fisheye,  detector);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'fisheye';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR30\n')
                % 30
                for k=1:noOfExecutions
                    fprintf('Composite MR30 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.rotate_image5p,@MRs.fisheye, detector);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'fisheye';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR31\n');
                % 31
                for k=1:noOfExecutions
                    fprintf('Composite MR31 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.shear_image20p,@MRs.fisheye,  detector);
                    expResults{it,1} = 'shearPlus20deg';
                    expResults{it,2} = 'fisheye';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);

                fprintf('composite MR32\n')
                % 32
                for k=1:noOfExecutions
                    fprintf('Composite MR32 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.flip_left_right,@MRs.contrastUp, detector);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'contrastUp';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR33\n')
                % 33
                for k=1:noOfExecutions
                    fprintf('Composite MR33 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.flip_up_down,@MRs.contrastUp,  detector);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'contrastUp';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR34\n')
                % 34
                for k=1:noOfExecutions
                    fprintf('Composite MR34 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.rotate_image5p,@MRs.contrastUp,  detector);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'contrastUp';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR35\n');
                % 35
                for k=1:noOfExecutions
                    fprintf('Composite MR35 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.shear_image20p,@MRs.contrastUp,  detector);
                    expResults{it,1} = 'shearPlus20deg';
                    expResults{it,2} = 'contrastUp';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR36\n')
                % 36
                for k=1:noOfExecutions
                    fprintf('Composite MR36 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.flip_left_right,@MRs.contrastDown, detector);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'contrastDown';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR37\n')
                % 37
                for k=1:noOfExecutions
                    fprintf('Composite MR37 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.flip_up_down,@MRs.contrastDown,  detector);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'contrastDown';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR38\n')
                % 38
                for k=1:noOfExecutions
                    fprintf('Composite MR38 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.rotate_image5p,@MRs.contrastDown, detector);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'contrastDown';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR39\n');
                % 39
                for k=1:noOfExecutions
                    fprintf('Composite MR39 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.shear_image20p,@MRs.contrastDown, detector);
                    expResults{it,1} = 'shearPlus20deg';
                    expResults{it,2} = 'contrastDown';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR40\n')
                % 40
                for k=1:noOfExecutions
                    fprintf('Composite MR40 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.fisheye,@MRs.brightnessPlus20,  detector);
                    expResults{it,1} = 'fisheye';
                    expResults{it,2} = 'brightnessPlus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR41\n')
                % 41
                for k=1:noOfExecutions
                    fprintf('Composite MR41 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.fisheye,@MRs.brightnessMinus20,  detector);
                    expResults{it,1} = 'fisheye';
                    expResults{it,2} = 'brightnessMinus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR42\n')
                % 42
                for k=1:noOfExecutions
                    fprintf('Composite MR42 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.fisheye,@MRs.contrastUp, detector);
                    expResults{it,1} = 'fisheye';
                    expResults{it,2} = 'contrastUp';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR43\n');
                % 43
                for k=1:noOfExecutions
                    fprintf('Composite MR43 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.fisheye,@MRs.contrastDown,  detector);
                    expResults{it,1} = 'fisheye';
                    expResults{it,2} = 'contrastDown';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);

                fprintf('composite MR44\n');
                % 44
                for k=1:noOfExecutions
                    fprintf('Composite MR44 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(datasets{j},@MRs.fisheye,@MRs.blur_image, detector);
                    expResults{it,1} = 'fisheye';
                    expResults{it,2} = 'blurImage';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
            end
            rmpath('models/yolo-v2-main/src');
            
        case 'tiny-yolov3-coco'
            % check dir for results
            model_results_dir = fullfile(results_dir,modelNames{i});
            if ~exist(model_results_dir, 'dir')
               mkdir(model_results_dir);
            end
            % get model detector
            detector = yolov3ObjectDetector(modelNames{i});
            for j = 1 : length(datasets)
                subset = split(datasets{j}, "/" );
                results_file = fullfile(model_results_dir, strcat(modelNames{i},'_',string(subset(length(subset))),'.xlsx'));
                fprintf('Dataset: %s\n', string(subset(length(subset))));
                it = 1;
                expResults{1,1} = 'MR1';
                expResults{1,2} = 'MR2';
                expResults{1,3} = 'objfailureRateMR1';
                expResults{1,4} = 'objfailureRateMR2';                
                expResults{1,5} = 'objfailureRateMR1_MR2_combined';
                expResults{1,6} = 'objfailureRateMR1_2_composite';
                expResults{1,7} = 'classfailureRateMR1';
                expResults{1,8} = 'classfailureRateMR2';                
                expResults{1,9} = 'classfailureRateMR1_MR2_combined';
                expResults{1,10} = 'classfailureRateMR1_2_composite';
                expResults{1,11} = 'objClassDetectFailureRateMR1';
                expResults{1,12} = 'objClassDetectFailureRateMR2';
                expResults{1,13} = 'objClassDetectFailureRateMR1_MR2';
                expResults{1,14} = 'objClassDetectFailureRateMR12';
                expResults{1,15} = 'objDetectCompositeMRUniqueFaults';
                expResults{1,16} = 'objClassCompositeMRUniqueFaults';
                expResults{1,17} = 'compositeMRUniqueFaults';                
                expResults{1,18} = 'timeMR1';
                expResults{1,19} = 'timeMR2';
                expResults{1,20} = 'timeMR12';
                expResults{1,21} = 'timeMR12_composite';
                
                fprintf('composite MR1\n')
                % 1 some issues here with some images
                for k=1:noOfExecutions
                    fprintf('Composite MR1 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.flip_left_right, @MRs.flip_up_down, detector);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'flipUpDown';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file,expResults);
                
                fprintf('composite MR2\n')
                % 2
                for k=1:noOfExecutions
                    fprintf('Composite MR2 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.flip_left_right, @MRs.rotate_image5m, detector);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'rotateMinus5deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file,expResults);
            
                fprintf('composite MR3\n')
                % 3
                for k=1:noOfExecutions
                    fprintf('Composite MR3 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.flip_left_right, @MRs.rotate_image5p, detector);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'rotatePlus5deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file,expResults);
                
                fprintf('composite MR4\n')
                % 4 Problems here with some images
                for k=1:noOfExecutions
                    fprintf('Composite MR4 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.flip_left_right, @MRs.shear_image20m, detector);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'shearMinus20deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR5\n')
                % 5
                for k=1:noOfExecutions
                    fprintf('Composite MR5 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.flip_left_right, @MRs.shear_image20p, detector);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'shearPlus20deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR6\n')
                % 6
                for k=1:noOfExecutions
                    fprintf('Composite MR6 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.flip_up_down, @MRs.rotate_image5m, detector);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'rotateMinus5deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR7\n')
                % 7
                for k=1:noOfExecutions
                    fprintf('Composite MR7 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.flip_up_down, @MRs.rotate_image5p, detector);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'rotatePlus5deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR8\n')
                % 8
                for k=1:noOfExecutions
                    fprintf('Composite MR8 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.flip_up_down, @MRs.shear_image20m, detector);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'shearMinus20deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR9\n')
                % 8
                for k=1:noOfExecutions
                    fprintf('Composite MR9 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.flip_up_down, @MRs.shear_image20p, detector);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'shearPlus20deg';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR10\n')
                % 9
                for k=1:noOfExecutions
                    fprintf('Composite MR10 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.rotate_image5m, @MRs.shear_image20m,  detector);
                    expResults{it,1} = 'rotateMinus5deg';
                    expResults{it,2} = 'shearMinus20degrees';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);  
                
                fprintf('composite MR11\n')
                % 10
                for k=1:noOfExecutions
                    fprintf('Composite MR11 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.rotate_image5m, @MRs.shear_image20p,  detector);
                    expResults{it,1} = 'rotateMinus5deg';
                    expResults{it,2} = 'shearPlus20degrees';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);           
                
                fprintf('composite MR12\n')
                % 12
                for k=1:noOfExecutions
                    fprintf('Composite MR12 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.flip_left_right, @MRs.blur_image, detector);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'blurImage';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR13\n')
                % 13
                for k=1:noOfExecutions
                    fprintf('Composite MR13 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.flip_up_down, @MRs.blur_image, detector);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'blurImage';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR14\n')
                % 14
                for k=1:noOfExecutions
                    fprintf('Composite MR14 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.rotate_image5m, @MRs.blur_image, detector);
                    expResults{it,1} = 'rotateMinus5deg';
                    expResults{it,2} = 'blurImage';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR15\n')
                % 15
                for k=1:noOfExecutions
                    fprintf('Composite MR15 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.rotate_image5p, @MRs.shear_image20m, detector);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'shearMinus20degrees';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);

                fprintf('composite MR16\n')
                % 16
                for k=1:noOfExecutions
                    fprintf('Composite MR16 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.rotate_image5p, @MRs.shear_image20p, detector);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'shearPlus20degrees';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR17\n')
                % 17
                for k=1:noOfExecutions
                    fprintf('Composite MR17 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.rotate_image5p, @MRs.blur_image,detector);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'blurImage';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR18\n')
                % 18
                for k=1:noOfExecutions
                    fprintf('Composite MR18 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.shear_image20m,@MRs.blur_image, detector);
                    expResults{it,1} = 'shearMinus20degrees';
                    expResults{it,2} = 'blurImage';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR19\n')
                % 19
                for k=1:noOfExecutions
                    fprintf('Composite MR19 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.shear_image20p,@MRs.blur_image, detector);
                    expResults{it,1} = 'shearPlus20degrees';
                    expResults{it,2} = 'blurImage';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);

                fprintf('composite MR20\n')
                % 20
                for k=1:noOfExecutions
                    fprintf('Composite MR20 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.flip_left_right,@MRs.brightnessPlus20,  detector);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'brightnessPlus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR21\n')
                % 21
                for k=1:noOfExecutions
                    fprintf('Composite MR21 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.flip_up_down,@MRs.brightnessPlus20, detector);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'brightnessPlus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR22\n')
                % 20
                for k=1:noOfExecutions
                    fprintf('Composite MR22 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.rotate_image5p,@MRs.brightnessPlus20, detector);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'brightnessPlus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR23\n');
                % 23
                for k=1:noOfExecutions
                    fprintf('Composite MR23 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.shear_image20p,@MRs.brightnessPlus20, detector);
                    expResults{it,1} = 'shearPlus20deg';
                    expResults{it,2} = 'brightnessPlus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR24\n')
                % 24
                for k=1:noOfExecutions
                    fprintf('Composite MR24 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.flip_left_right,@MRs.brightnessMinus20,  detector);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'brightnessMinus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR25\n')
                % 25
                for k=1:noOfExecutions
                    fprintf('Composite MR25 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.flip_up_down,@MRs.brightnessMinus20, detector);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'brightnessMinus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR26\n')
                % 26
                for k=1:noOfExecutions
                    fprintf('Composite MR26 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.rotate_image5p,@MRs.brightnessMinus20,  detector);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'brightnessMinus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR27\n');
                % 27
                for k=1:noOfExecutions
                    fprintf('Composite MR27 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.shear_image20p,@MRs.brightnessMinus20,  detector);
                    expResults{it,1} = 'shearPlus20deg';
                    expResults{it,2} = 'brightnessMinus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);

                fprintf('composite MR28\n')
                % 28
                for k=1:noOfExecutions
                    fprintf('Composite MR28 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.flip_left_right,@MRs.fisheye, detector);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'fisheye';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR29\n')
                % 29
                for k=1:noOfExecutions
                    fprintf('Composite MR29 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.flip_up_down,@MRs.fisheye,  detector);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'fisheye';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR30\n')
                % 30
                for k=1:noOfExecutions
                    fprintf('Composite MR30 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.rotate_image5p,@MRs.fisheye, detector);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'fisheye';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR31\n');
                % 31
                for k=1:noOfExecutions
                    fprintf('Composite MR31 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.shear_image20p,@MRs.fisheye,  detector);
                    expResults{it,1} = 'shearPlus20deg';
                    expResults{it,2} = 'fisheye';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);

                fprintf('composite MR32\n')
                % 32
                for k=1:noOfExecutions
                    fprintf('Composite MR32 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.flip_left_right,@MRs.contrastUp, detector);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'contrastUp';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR33\n')
                % 33
                for k=1:noOfExecutions
                    fprintf('Composite MR33 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.flip_up_down,@MRs.contrastUp,  detector);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'contrastUp';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR34\n')
                % 34
                for k=1:noOfExecutions
                    fprintf('Composite MR34 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.rotate_image5p,@MRs.contrastUp,  detector);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'contrastUp';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR35\n');
                % 35
                for k=1:noOfExecutions
                    fprintf('Composite MR35 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.shear_image20p,@MRs.contrastUp,  detector);
                    expResults{it,1} = 'shearPlus20deg';
                    expResults{it,2} = 'contrastUp';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR36\n')
                % 36
                for k=1:noOfExecutions
                    fprintf('Composite MR36 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.flip_left_right,@MRs.contrastDown, detector);
                    expResults{it,1} = 'flipLeftRight';
                    expResults{it,2} = 'contrastDown';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR37\n')
                % 37
                for k=1:noOfExecutions
                    fprintf('Composite MR37 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.flip_up_down,@MRs.contrastDown,  detector);
                    expResults{it,1} = 'flipUpDown';
                    expResults{it,2} = 'contrastDown';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR38\n')
                % 38
                for k=1:noOfExecutions
                    fprintf('Composite MR38 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.rotate_image5p,@MRs.contrastDown, detector);
                    expResults{it,1} = 'rotatePlus5deg';
                    expResults{it,2} = 'contrastDown';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR39\n');
                % 39
                for k=1:noOfExecutions
                    fprintf('Composite MR39 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.shear_image20p,@MRs.contrastDown, detector);
                    expResults{it,1} = 'shearPlus20deg';
                    expResults{it,2} = 'contrastDown';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR40\n')
                % 40
                for k=1:noOfExecutions
                    fprintf('Composite MR40 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.fisheye,@MRs.brightnessPlus20,  detector);
                    expResults{it,1} = 'fisheye';
                    expResults{it,2} = 'brightnessPlus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR41\n')
                % 41
                for k=1:noOfExecutions
                    fprintf('Composite MR41 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.fisheye,@MRs.brightnessMinus20,  detector);
                    expResults{it,1} = 'fisheye';
                    expResults{it,2} = 'brightnessMinus20';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR42\n')
                % 42
                for k=1:noOfExecutions
                    fprintf('Composite MR42 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.fisheye,@MRs.contrastUp, detector);
                    expResults{it,1} = 'fisheye';
                    expResults{it,2} = 'contrastUp';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
                
                fprintf('composite MR43\n');
                % 43
                for k=1:noOfExecutions
                    fprintf('Composite MR43 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.fisheye,@MRs.contrastDown,  detector);
                    expResults{it,1} = 'fisheye';
                    expResults{it,2} = 'contrastDown';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);

                fprintf('composite MR44\n');
                % 44
                for k=1:noOfExecutions
                    fprintf('Composite MR44 run %d\n', k)
                    it = it+1;
                    [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
                    objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
                    classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
                    objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
                    compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
                    tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(datasets{j},@MRs.fisheye,@MRs.blur_image, detector);
                    expResults{it,1} = 'fisheye';
                    expResults{it,2} = 'blurImage';
                    expResults{it,3} = objfailureRateMR1;
                    expResults{it,4} = objfailureRateMR2;
                    expResults{it,5} = objcombinedFailureRateMR1MR2;
                    expResults{it,6} = objcompositeMRFailureRate;                    
                    expResults{it,7} = classfailureRateMR1;
                    expResults{it,8} = classfailureRateMR2;
                    expResults{it,9} = classcombinedFailureRateMR1MR2;
                    expResults{it,10} = classcompositeMRFailureRate;  
                    expResults{it,11} = objDetectClassFailureRateMR1;
                    expResults{it,12} = objDetectClassFailureRateMR2;
                    expResults{it,13} = objDetectClassFailureRateMR1MR2;
                    expResults{it,14} = objDetectClassFailureRateMR12;
                    expResults{it,15} = odCompositeMRMutationScore;
                    expResults{it,16} = ocCompositeMRMutationScore;
                    expResults{it,17} = compositeMRMutationScore;
                    expResults{it,18} = tMR1;
                    expResults{it,19} = tMR2;
                    expResults{it,20} = tMR12;
                    expResults{it,21} = tCompositeMR;
                end
                xlswrite(results_file, expResults);
            end
        otherwise
            fprintf('No actions found for %s',modelNames{i});
    end
end