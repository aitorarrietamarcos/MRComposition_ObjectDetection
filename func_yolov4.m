function func_yolov4(datasets, results_dir)
    % add paths for YOLOv4-coco            
    addpath('models/pretrained-yolo-v4-main/src');
    addpath('models/pretrained-yolo-v4-main'); 

    modelName = 'YOLOv4-coco';
    % load model
    model = load(['models/yolo-v4-main/', modelName, '.mat']);
    net = model.net;
    % Get classnames of COCO dataset.
    classNames = helper.getCOCOClassNames;
    % Get anchors used in training of the pretrained model.
    anchors = helper.getAnchors(modelName);
    % Specify environment
    executionEnvironment = 'auto';
    % Get all images from dataset directory
    filePattern = fullfile(datasets{1}, '*.jpg');
    theFiles = dir(filePattern);
    % Loop through images and execute model
    for j = 1 : 1 % restricted to one execution for now
        % Output format for each execution:
        %   testcase_type
        %   noOfObjs
        %   objDectectScore
        %   classificationSocre (classified images / no of source Objs)
        %   Time (seconds including followup gen.
        testcase_types = []; noOfObjs = []; objDectectScore = []; classScores = []; exectimes = [];
        %for k = 1 : length(theFiles)
        for k = 1 : 2 % restricted to two images from coco dataset for now
            % Get file name
            baseFileName = theFiles(k).name;                
            image = fullfile(theFiles(k).folder, baseFileName);
            % fprintf('begin source %d \n',k);
            t1 = tic(); % get start time
            % execute model with current image        
            testcase = imread(image);
            [bboxes, scores, labels] = detectYOLOv4(net, testcase, anchors, classNames, executionEnvironment);                        
            % store source testcase results            
            source_labels = labels;
            source_noOfObjs = length(source_labels);
            
            testcase_types = [testcase_types; strcat("source",string(k))];
            noOfObjs = [noOfObjs; source_noOfObjs];
            exectimes = [exectimes; toc(t1)];
            classScores = [classScores; 1]; % score is btn 0 and 1, 1 for source testcase
            objDectectScore = [objDectectScore; 1];% score is btn 0 and 1, 1 for source testcase        
            
            % follow-up 1 blur_image
            % fprintf('begin follow 1 for source %d \n', k);
            t1 = tic(); % get start time
            followup = MRs.blur_image(testcase);
            [bboxes, scores, labels] = detectYOLOv4(net, followup, anchors, classNames, executionEnvironment);          
            % store results
            testcase_types = [testcase_types; strcat("blur_image",string(k))];
            noOfObjs = [noOfObjs; length(labels)];
            exectimes = [exectimes; toc(t1)];
            fobjs = length(labels);
            
            % Object detection score
            if fobjs > 0
                objDectectScore = [objDectectScore; (fobjs/source_noOfObjs)];
            else
                objDectectScore = [objDectectScore; 0];
            end

            % calculate classification score
            if fobjs > 0
                temp_source_labels = source_labels;
                correct = 0;
                % correct number of objects id'd
                for l = 1: fobjs
                    for m = 1: length(temp_source_labels)
                        if labels(l) == temp_source_labels(m) % if element exists in temp
                            correct = correct + 1; % increment
                            temp_source_labels(m) = ""; % remove element
                            break
                        end
                    end
                end
                if correct > 0
                    cscore = correct/source_noOfObjs;
                    classScores = [classScores; cscore];
                else
                    classScores = [classScores; 0];
                end                
            else
                classScores = [classScores; 0];
            end

            % follow-up 2
            % fprintf('begin follow 2 for source %d \n', k);
            t1 = tic(); % get start time
            followup = MRs.flip_left_right(testcase);
            [bboxes, scores, labels] = detectYOLOv4(net, followup, anchors, classNames, executionEnvironment);
            % store results
            testcase_types = [testcase_types; strcat("flip_left_right",string(k))];
            noOfObjs = [noOfObjs; length(labels)];
            exectimes = [exectimes; toc(t1)];
            fobjs = length(labels);     
            
            % Object detection score
            if fobjs > 0
                objDectectScore = [objDectectScore; (fobjs/source_noOfObjs)];
            else
                objDectectScore = [objDectectScore; 0];
            end
            
            % calculate classification score
            if fobjs > 0
                temp_source_labels = source_labels;
                correct = 0;
                % correct number of objects id'd
                for l = 1: fobjs
                    for m = 1: length(temp_source_labels)
                        if labels(l) == temp_source_labels(m) % if element exists in temp
                            correct = correct + 1; % increment 
                            temp_source_labels(m) = ""; % remove element
                            break
                        end
                    end
                end
                if correct > 0
                    cscore = correct/source_noOfObjs;
                    classScores = [classScores; cscore];
                else
                    classScores = [classScores; 0];
                end                
            else
                classScores = [classScores; 0];
            end
            
            % follow-up 3
            % fprintf('begin follow 3 for source %d \n', k);
            t1 = tic(); % get start time
            followup = MRs.flip_up_down(testcase);
            [bboxes, scores, labels] = detectYOLOv4(net, followup, anchors, classNames, executionEnvironment);
            % store results
            testcase_types = [testcase_types; strcat("flip_up_down",string(k))];
            noOfObjs = [noOfObjs; length(labels)];
            exectimes = [exectimes; toc(t1)];
            fobjs = length(labels);

            % Object detection score
            if fobjs > 0
                objDectectScore = [objDectectScore; (fobjs/source_noOfObjs)];
            else
                objDectectScore = [objDectectScore; 0];
            end
            
            % calculate classification score
            if fobjs > 0
                temp_source_labels = source_labels;
                correct = 0;
                % correct number of objects id'd
                for l = 1: fobjs
                    for m = 1: length(temp_source_labels)
                        if labels(l) == temp_source_labels(m) % if element exists in temp
                            correct = correct + 1; % increment 
                            temp_source_labels(m) = ""; % remove element
                            break
                        end
                    end
                end
                if correct > 0
                    cscore = correct/source_noOfObjs;
                    classScores = [classScores; cscore];
                else
                    classScores = [classScores; 0];
                end                
            else
                classScores = [classScores; 0];
            end

            % follow-up 4
            % fprintf('begin follow 4 for source %d \n', k);
            t1 = tic(); % get start time
            followup = MRs.invert_colors(testcase);
            [bboxes, scores, labels] = detectYOLOv4(net, followup, anchors, classNames, executionEnvironment);
            % store results
            testcase_types = [testcase_types; strcat("invert_colors",string(k))];
            noOfObjs = [noOfObjs; length(labels)];
            exectimes = [exectimes; toc(t1)];
            fobjs = length(labels);   
            
            % Object detection score
            if fobjs > 0
                objDectectScore = [objDectectScore; (fobjs/source_noOfObjs)];
            else
                objDectectScore = [objDectectScore; 0];
            end
            
            % calculate classification score
            if fobjs > 0
                temp_source_labels = source_labels;
                correct = 0;
                % correct number of objects id'd
                for l = 1: fobjs
                    for m = 1: length(temp_source_labels)
                        if labels(l) == temp_source_labels(m) % if element exists in temp
                            correct = correct + 1; % increment 
                            temp_source_labels(m) = ""; % remove element
                            break
                        end
                    end
                end
                if correct > 0
                    cscore = correct/source_noOfObjs;
                    classScores = [classScores; cscore];
                else
                    classScores = [classScores; 0];
                end                
            else
                classScores = [classScores; 0];
            end   

            % follow-up 
            % fprintf('begin follow 5 for source %d \n', k);
            t1 = tic(); % get start time
            followup = MRs.rotate_image(testcase, -5);
            [bboxes, scores, labels] = detectYOLOv4(net, followup, anchors, classNames, executionEnvironment);
            % store results
            testcase_types = [testcase_types; strcat("rotate_image_5m",string(k))];
            noOfObjs = [noOfObjs; length(labels)];
            exectimes = [exectimes; toc(t1)];
            fobjs = length(labels);     
            
            % Object detection score
            if fobjs > 0
                objDectectScore = [objDectectScore; (fobjs/source_noOfObjs)];
            else
                objDectectScore = [objDectectScore; 0];
            end
            
            % calculate classification score
            if fobjs > 0
                temp_source_labels = source_labels;
                correct = 0;
                % correct number of objects id'd
                for l = 1: fobjs
                    for m = 1: length(temp_source_labels)
                        if labels(l) == temp_source_labels(m) % if element exists in temp
                            correct = correct + 1; % increment 
                            temp_source_labels(m) = ""; % remove element
                            break
                        end
                    end
                end
                if correct > 0
                    cscore = correct/source_noOfObjs;
                    classScores = [classScores; cscore];
                else
                    classScores = [classScores; 0];
                end                
            else
                classScores = [classScores; 0];
            end             

            % follow-up 6
            % fprintf('begin follow 6 for source %d \n', k);
            t1 = tic(); % get start time
            followup = MRs.rotate_image(testcase, 5);
            [bboxes, scores, labels] = detectYOLOv4(net, followup, anchors, classNames, executionEnvironment);
            % store results
            testcase_types = [testcase_types; strcat("rotate_image_5p",string(k))];
            noOfObjs = [noOfObjs; length(labels)];
            exectimes = [exectimes; toc(t1)];
            fobjs = length(labels);
            
            % Object detection score
            if fobjs > 0
                objDectectScore = [objDectectScore; (fobjs/source_noOfObjs)];
            else
                objDectectScore = [objDectectScore; 0];
            end
            
            % calculate classification score
            if fobjs > 0
                temp_source_labels = source_labels;
                correct = 0;
                % correct number of objects id'd
                for l = 1: fobjs
                    for m = 1: length(temp_source_labels)
                        if labels(l) == temp_source_labels(m) % if element exists in temp
                            correct = correct + 1; % increment 
                            temp_source_labels(m) = ""; % remove element
                            break
                        end
                    end
                end
                if correct > 0
                    cscore = correct/source_noOfObjs;
                    classScores = [classScores; cscore];
                else
                    classScores = [classScores; 0];
                end                
            else
                classScores = [classScores; 0];
            end

            % follow-up 7
            % fprintf('begin follow 7 for source %d \n', k);
            t1 = tic(); % get start time
            followup = MRs.shear_image(testcase);
            [bboxes, scores, labels] = detectYOLOv4(net, followup, anchors, classNames, executionEnvironment);
            % store results
            testcase_types = [testcase_types; strcat("shear_image",string(k))];
            noOfObjs = [noOfObjs; length(labels)];
            exectimes = [exectimes; toc(t1)];
            fobjs = length(labels);       
            
            % Object detection score
            if fobjs > 0
                objDectectScore = [objDectectScore; (fobjs/source_noOfObjs)];
            else
                objDectectScore = [objDectectScore; 0];
            end
            
            % calculate classification score
            if fobjs > 0
                temp_source_labels = source_labels;
                correct = 0;
                % correct number of objects id'd
                for l = 1: fobjs
                    for m = 1: length(temp_source_labels)
                        if labels(l) == temp_source_labels(m) % if element exists in temp
                            correct = correct + 1; % increment 
                            temp_source_labels(m) = ""; % remove element
                            break
                        end
                    end
                end
                if correct > 0
                    cscore = correct/source_noOfObjs;
                    classScores = [classScores; cscore];
                else
                    classScores = [classScores; 0];
                end                
            else
                classScores = [classScores; 0];
            end

% Composite Followups from paper
        
            % composite followup 1 
            % fprintf('begin composite 1 for source %d \n', k);
            t1 = tic(); % get start time
            composite = MRs.flip_up_down(MRs.flip_left_right(testcase));
            [bboxes, scores, labels] = detectYOLOv4(net, composite, anchors, classNames, executionEnvironment);
            % store results
            testcase_types = [testcase_types; strcat("flip_left_right_","flip_up_down",string(k))];
            noOfObjs = [noOfObjs; length(labels)];
            exectimes = [exectimes; toc(t1)];
            fobjs = length(labels);        
            
            % Object detection score
            if fobjs > 0
                objDectectScore = [objDectectScore; (fobjs/source_noOfObjs)];
            else
                objDectectScore = [objDectectScore; 0];
            end
            
            % calculate classification score
            if fobjs > 0
                temp_source_labels = source_labels;
                correct = 0;
                % correct number of objects id'd
                for l = 1: fobjs
                    for m = 1: length(temp_source_labels)
                        if labels(l) == temp_source_labels(m) % if element exists in temp
                            correct = correct + 1; % increment 
                            temp_source_labels(m) = ""; % remove element
                            break
                        end
                    end
                end
                if correct > 0
                    cscore = correct/source_noOfObjs;
                    classScores = [classScores; cscore];
                else
                    classScores = [classScores; 0];
                end                
            else
                classScores = [classScores; 0];
            end    

            % composite followup 2
            % fprintf('begin composite 2 for source %d \n', k);
            t1 = tic(); % get start time
            composite = MRs.rotate_image(MRs.flip_left_right(testcase), -5);
            [bboxes, scores, labels] = detectYOLOv4(net, composite, anchors, classNames, executionEnvironment);
            % store results
            testcase_types = [testcase_types; strcat("flip_left_right_","rotate_image_5m",string(k))];
            noOfObjs = [noOfObjs; length(labels)];
            exectimes = [exectimes; toc(t1)];
            fobjs = length(labels);       
            
            % Object detection score
            if fobjs > 0
                objDectectScore = [objDectectScore; (fobjs/source_noOfObjs)];
            else
                objDectectScore = [objDectectScore; 0];
            end
            
            % calculate classification score
            if fobjs > 0
                temp_source_labels = source_labels;
                correct = 0;
                % correct number of objects id'd
                for l = 1: fobjs
                    for m = 1: length(temp_source_labels)
                        if labels(l) == temp_source_labels(m) % if element exists in temp
                            correct = correct + 1; % increment 
                            temp_source_labels(m) = ""; % remove element
                            break
                        end
                    end
                end
                if correct > 0
                    cscore = correct/source_noOfObjs;
                    classScores = [classScores; cscore];
                else
                    classScores = [classScores; 0];
                end                
            else
                classScores = [classScores; 0];
            end    
            
            % composite followup 3
            % fprintf('begin composite 3 for source %d \n', k);
            t1 = tic(); % get start time
            composite = MRs.rotate_image(MRs.flip_left_right(testcase), 5);
            [bboxes, scores, labels] = detectYOLOv4(net, composite, anchors, classNames, executionEnvironment);
            % store results
            testcase_types = [testcase_types; strcat("flip_left_right_","rotate_image_5p",string(k))];
            noOfObjs = [noOfObjs; length(labels)];
            exectimes = [exectimes; toc(t1)];
            fobjs = length(labels);        
            
            % Object detection score
            if fobjs > 0
                objDectectScore = [objDectectScore; (fobjs/source_noOfObjs)];
            else
                objDectectScore = [objDectectScore; 0];
            end
            
            % calculate classification score
            if fobjs > 0
                temp_source_labels = source_labels;
                correct = 0;
                % correct number of objects id'd
                for l = 1: fobjs
                    for m = 1: length(temp_source_labels)
                        if labels(l) == temp_source_labels(m) % if element exists in temp
                            correct = correct + 1; % increment 
                            temp_source_labels(m) = ""; % remove element
                            break
                        end
                    end
                end
                if correct > 0
                    cscore = correct/source_noOfObjs;
                    classScores = [classScores; cscore];
                else
                    classScores = [classScores; 0];
                end                
            else
                classScores = [classScores; 0];
            end    
            
            % composite followup 4
            % fprintf('begin composite 4 for source %d \n', k);
            t1 = tic(); % get start time
            composite = MRs.shear_image(MRs.flip_left_right(testcase));
            [bboxes, scores, labels] = detectYOLOv4(net, composite, anchors, classNames, executionEnvironment);
            % store results
            testcase_types = [testcase_types; strcat("flip_left_right_","shear_image",string(k))];
            noOfObjs = [noOfObjs; length(labels)];
            exectimes = [exectimes; toc(t1)];
            fobjs = length(labels);
            
            % Object detection score
            if fobjs > 0
                objDectectScore = [objDectectScore; (fobjs/source_noOfObjs)];
            else
                objDectectScore = [objDectectScore; 0];
            end
            
            % calculate classification score
            if fobjs > 0
                temp_source_labels = source_labels;
                correct = 0;
                % correct number of objects id'd
                for l = 1: fobjs
                    for m = 1: length(temp_source_labels)
                        if labels(l) == temp_source_labels(m) % if element exists in temp
                            correct = correct + 1; % increment 
                            temp_source_labels(m) = ""; % remove element
                            break
                        end
                    end
                end
                if correct > 0
                    cscore = correct/source_noOfObjs;
                    classScores = [classScores; cscore];
                else
                    classScores = [classScores; 0];
                end                
            else
                classScores = [classScores; 0];
            end    
            
            % composite followup 5
            % fprintf('begin composite 5 for source %d \n', k);
            t1 = tic(); % get start time
            composite = MRs.rotate_image(MRs.flip_up_down(testcase), -5);
            [bboxes, scores, labels] = detectYOLOv4(net, composite, anchors, classNames, executionEnvironment);
            % store results
            testcase_types = [testcase_types; strcat("flip_up_down_","rotate_image_5m",string(k))];
            noOfObjs = [noOfObjs; length(labels)];
            exectimes = [exectimes; toc(t1)];
            fobjs = length(labels);     
            
            % Object detection score
            if fobjs > 0
                objDectectScore = [objDectectScore; (fobjs/source_noOfObjs)];
            else
                objDectectScore = [objDectectScore; 0];
            end
            
            % calculate classification score
            if fobjs > 0
                temp_source_labels = source_labels;
                correct = 0;
                % correct number of objects id'd
                for l = 1: fobjs
                    for m = 1: length(temp_source_labels)
                        if labels(l) == temp_source_labels(m) % if element exists in temp
                            correct = correct + 1; % increment 
                            temp_source_labels(m) = ""; % remove element
                            break
                        end
                    end
                end
                if correct > 0
                    cscore = correct/source_noOfObjs;
                    classScores = [classScores; cscore];
                else
                    classScores = [classScores; 0];
                end                
            else
                classScores = [classScores; 0];
            end    
            % composite followup 6 
            % fprintf('begin composite 6 for source %d \n', k);
            t1 = tic(); % get start time
            composite = MRs.rotate_image(MRs.flip_up_down(testcase), 5);
            [bboxes, scores, labels] = detectYOLOv4(net, composite, anchors, classNames, executionEnvironment);
            % store results
            testcase_types = [testcase_types; strcat("flip_up_down_","rotate_image_5p",string(k))];
            noOfObjs = [noOfObjs; length(labels)];
            exectimes = [exectimes; toc(t1)];
            fobjs = length(labels);      
            
            % Object detection score
            if fobjs > 0
                objDectectScore = [objDectectScore; (fobjs/source_noOfObjs)];
            else
                objDectectScore = [objDectectScore; 0];
            end            
            % calculate classification score
            if fobjs > 0
                temp_source_labels = source_labels;
                correct = 0;
                % correct number of objects id'd
                for l = 1: fobjs
                    for m = 1: length(temp_source_labels)
                        if labels(l) == temp_source_labels(m) % if element exists in temp
                            correct = correct + 1; % increment 
                            temp_source_labels(m) = ""; % remove element
                            break
                        end
                    end
                end
                if correct > 0
                    cscore = correct/source_noOfObjs;
                    classScores = [classScores; cscore];
                else
                    classScores = [classScores; 0];
                end                
            else
                classScores = [classScores; 0];
            end    
            % composite followup 7 
            % fprintf('begin composite 7 for source %d \n', k);
            t1 = tic(); % get start time
            composite = MRs.shear_image(MRs.flip_up_down(testcase));
            [bboxes, scores, labels] = detectYOLOv4(net, composite, anchors, classNames, executionEnvironment);
            % store results
            testcase_types = [testcase_types; strcat("flip_up_down_","shear_image",string(k))];
            noOfObjs = [noOfObjs; length(labels)];
            exectimes = [exectimes; toc(t1)];
            fobjs = length(labels);  
            
            % Object detection score
            if fobjs > 0
                objDectectScore = [objDectectScore; (fobjs/source_noOfObjs)];
            else
                objDectectScore = [objDectectScore; 0];
            end
            
            % calculate classification score
            if fobjs > 0
                temp_source_labels = source_labels;
                correct = 0;
                % correct number of objects id'd
                for l = 1: fobjs
                    for m = 1: length(temp_source_labels)
                        if labels(l) == temp_source_labels(m) % if element exists in temp
                            correct = correct + 1; % increment 
                            temp_source_labels(m) = ""; % remove element
                            break
                        end
                    end
                end
                if correct > 0
                    cscore = correct/source_noOfObjs;
                    classScores = [classScores; cscore];
                else
                    classScores = [classScores; 0];
                end                
            else
                classScores = [classScores; 0];
            end
            
            % composite followup 8 
            % fprintf('begin composite 8 for source %d \n', k);
            t1 = tic(); % get start time
            composite = MRs.shear_image(MRs.rotate_image(testcase, -5));
            [bboxes, scores, labels] = detectYOLOv4(net, composite, anchors, classNames, executionEnvironment);
            % store results
            testcase_types = [testcase_types; strcat("rotate_image_5m_","shear_image",string(k))];
            noOfObjs = [noOfObjs; length(labels)];
            exectimes = [exectimes; toc(t1)];
            fobjs = length(labels);      
            
            % Object detection score
            if fobjs > 0
                objDectectScore = [objDectectScore; (fobjs/source_noOfObjs)];
            else
                objDectectScore = [objDectectScore; 0];
            end
            
            % calculate classification score
            if fobjs > 0
                temp_source_labels = source_labels;
                correct = 0;
                % correct number of objects id'd
                for l = 1: fobjs
                    for m = 1: length(temp_source_labels)
                        if labels(l) == temp_source_labels(m) % if element exists in temp
                            correct = correct + 1; % increment 
                            temp_source_labels(m) = ""; % remove element
                            break
                        end
                    end
                end
                if correct > 0
                    cscore = correct/source_noOfObjs;
                    classScores = [classScores; cscore];
                else
                    classScores = [classScores; 0];
                end                
            else
                classScores = [classScores; 0];
            end    
        end        
        filename = fullfile(results_dir, strcat(modelName, '-',string(j),'.xlsx')) ;
        results = table(testcase_types, noOfObjs, objDectectScore, classScores, exectimes);
        writetable(results,filename, 'Sheet' ,1);
    end
end