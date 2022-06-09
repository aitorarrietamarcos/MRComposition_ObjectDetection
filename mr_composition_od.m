%% Extension of Cost-Effectiveness of Composite Metamorphic Relations for Testing Deep Learning Systems
% Experimental setup includes
% 4 DL models:
%       'YOLOv4-coco','efficientDetD0-coco','tinyYOLOv2-coco','tiny-yolov3-coco'
clear;
clc;

%modelNames = {'YOLOv4-coco','efficientDetD0-coco','tinyYOLOv2-coco','tiny-yolov3-coco'};
modelNames = {'YOLOv4-coco'};
%datasets = {'datasets/oid/oidperson','datasets/oid/oidvehicle','datasets/oid/oidanimal','datasets/oid/oidfood','datasets/oid/oidfurniture','datasets/coco/cocoperson','datasets/coco/cocovehicle','datasets/coco/cocoanimal','datasets/coco/cocofood','datasets/coco/cocofurniture'};    % list of datasets
datasets = {'datasets/coco/subset1'};
results_dir = 'results';                % results dir
noOfExecutions = 1;
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
                results_file = fullfile(model_results_dir, strcat(modelNames{i},'_',subset(length(subset)) , '_',string(j),'.xlsx')) ;
                
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
                expResults{1,15} = 'objDetectCompositeMRMutationScore';
                expResults{1,16} = 'objClassCompositeMRMutationScore';
                expResults{1,17} = 'compositeMRMutationScore';                
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
                results_file = fullfile(model_results_dir, strcat(modelNames{i},'_',subset(length(subset)) , '_',string(j),'.xlsx')) ;
                
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
                expResults{1,15} = 'objDetectCompositeMRMutationScore';
                expResults{1,16} = 'objClassCompositeMRMutationScore';
                expResults{1,17} = 'compositeMRMutationScore';                
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
                results_file = fullfile(model_results_dir, strcat(modelNames{i},'_',subset(length(subset)) , '_',string(j),'.xlsx')) ;

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
                expResults{1,15} = 'objDetectCompositeMRMutationScore';
                expResults{1,16} = 'objClassCompositeMRMutationScore';
                expResults{1,17} = 'compositeMRMutationScore';                
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
                results_file = fullfile(model_results_dir, strcat(modelNames{i},'_',subset(length(subset)) , '_',string(j),'.xlsx')) ;

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
                expResults{1,15} = 'objDetectCompositeMRMutationScore';
                expResults{1,16} = 'objClassCompositeMRMutationScore';
                expResults{1,17} = 'compositeMRMutationScore';                
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
            end
        otherwise
            fprintf('No actions found for %s',modelNames{i});
    end
end