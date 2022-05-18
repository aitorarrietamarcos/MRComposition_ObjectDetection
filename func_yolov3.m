function [objfailureRateMR1,objfailureRateMR2, objcombinedFailureRateMR1MR2, ...
        objcompositeMRFailureRate, classfailureRateMR1, classfailureRateMR2, ...
        classcombinedFailureRateMR1MR2, classcompositeMRFailureRate, ...
        tMR1, tMR2, tMR12, tCompositeMR] = func_yolov3(dataset, followup1, followup2, detector)
   % Get all images from current dataset directory
    filePattern = fullfile(dataset, '*.jpg');
    theFiles = dir(filePattern);     
    %% Execute MR1
    numOfValidTests = 0;    
    tic;
    for j = 1 : length(theFiles) % loop through images in dataset
        % Get and preprocess source image
        sourceTestcase = imread(fullfile(theFiles(j).folder, theFiles(j).name));
        % Execute source testcase        
        [bboxes,scores,labels] = detect(detector,sourceTestcase,'DetectionPreprocessing','none');
        % store source testcase results
        source_labels = labels;
        source_noOfObjs = length(source_labels);
        
        % generate followup testcase
        followUpTestcase = followup1(sourceTestcase);     
        % Execute source testcase        
        [bboxes,scores,labels] = detect(detector,followUpTestcase,'DetectionPreprocessing','none');
        
        numOfValidTests = numOfValidTests + 1;        
        fobjs = length(labels);

        % Object detection score
        if fobjs > 0
            % detected at least 1 object, 
            % fobjs/source_noOfObjs = success rate so failure is 1 - fobjs/source_noOfObjs
            objDetectionFailuresMR1(numOfValidTests, 1) = (1 - fobjs/source_noOfObjs);
        else
            % detected nothing
            objDetectionFailuresMR1(numOfValidTests, 1) =  1;
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
                % correctly classified some objects
                objClassificationFailuresMR1(numOfValidTests, 1) = 1 - (correct/source_noOfObjs);
            else
                % failure rate is 1
                objClassificationFailuresMR1(numOfValidTests, 1) =  1;
            end                
        else
            % failure rate is 1
            objClassificationFailuresMR1(numOfValidTests, 1) =  1;
        end
        
    end
    tMR1 = toc;
    
    objfailureRateMR1 = sum(objDetectionFailuresMR1)/numOfValidTests;
    classfailureRateMR1 = sum(objClassificationFailuresMR1)/numOfValidTests;
    
    %% Execute MR2
    numOfValidTests1 = 0;    
    tic;
    for j = 1 : length(theFiles) % loop through images in dataset
        % Get source image
        sourceTestcase = imread(fullfile(theFiles(j).folder, theFiles(j).name));
        % Execute source testcase
        [bboxes,scores,labels] = detect(detector,sourceTestcase,'DetectionPreprocessing','none');
        % store source testcase results
        source_labels = labels;
        source_noOfObjs = length(source_labels);
        % generate followup testcase
        followUpTestcase = followup2(sourceTestcase);       
        [bboxes,scores,labels] = detect(detector,followUpTestcase,'DetectionPreprocessing','none');
        numOfValidTests1 = numOfValidTests1 + 1;        
        fobjs = length(labels);

        % Object detection score
        if fobjs > 0
            % detected at least 1 object, 
            % fobjs/source_noOfObjs = success rate so failure is 1 - fobjs/source_noOfObjs
            objDetectionFailuresMR2(numOfValidTests1, 1) = (1 - fobjs/source_noOfObjs);
        else
            % detected nothing
            objDetectionFailuresMR2(numOfValidTests1, 1) =  1;
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
                % correctly classified some objects
                objClassificationFailuresMR2(numOfValidTests1, 1) = 1 - (correct/source_noOfObjs);
            else
                % failure rate is 1
                objClassificationFailuresMR2(numOfValidTests1, 1) =  1;
            end                
        else
            % failure rate is 1
            objClassificationFailuresMR2(numOfValidTests1, 1) =  1;
        end
        
    end
    tMR2 = toc;
    
    objfailureRateMR2 = sum(objDetectionFailuresMR2)/numOfValidTests1;
    classfailureRateMR2 = sum(objClassificationFailuresMR2)/numOfValidTests1;
    
    tMR12 = tMR1+tMR2;

    % Next two lines of code are wrong when followup testcase detects more objects
    % than sourceTestcase
    %% obtain objDetectionFailures statistics combined
    objcombinedFailureRateMR1MR2 = (sum(objClassificationFailuresMR2) + sum(objDetectionFailuresMR2)) / (numOfValidTests + numOfValidTests1);
    
    %% obtain objClassificationFailures statistics combined
    classcombinedFailureRateMR1MR2 = (sum(objClassificationFailuresMR2) + sum(objDetectionFailuresMR2)) / (numOfValidTests + numOfValidTests1);
  
    %% Composite MR (MR1+MR2)
    numOfValidTests = 0;    
    tic;
    for j = 1 : length(theFiles) % loop through images in dataset
        % Get source image
        sourceTestcase = imread(fullfile(theFiles(j).folder, theFiles(j).name));
        % Execute source testcase
        [bboxes,scores,labels] = detect(detector,sourceTestcase,'DetectionPreprocessing','none');
        % store source testcase results
        source_labels = labels;
        source_noOfObjs = length(source_labels);
        % generate composite testcase
        compositeTestcase = followup2(followup1(sourceTestcase));
        [bboxes,scores,labels] = detect(detector,compositeTestcase,'DetectionPreprocessing','none');
        numOfValidTests = numOfValidTests + 1;        
        fobjs = length(labels);

        % Object detection score
        if fobjs > 0
            % detected at least 1 object, 
            % fobjs/source_noOfObjs = success rate so failure is 1 - fobjs/source_noOfObjs
            objDetectionCompositeFailures(numOfValidTests, 1) = (1 - fobjs/source_noOfObjs);
        else
            % detected nothing
            objDetectionCompositeFailures(numOfValidTests, 1) =  1;
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
                % correctly classified some objects
                objClassificationCompositeFailures(numOfValidTests, 1) = 1 - (correct/source_noOfObjs);
            else
                % failure rate is 1
                objClassificationCompositeFailures(numOfValidTests, 1) =  1;
            end                
        else
            % failure rate is 1
            objClassificationCompositeFailures(numOfValidTests, 1) =  1;
        end
        
    end
    tCompositeMR = toc;
    
    objcompositeMRFailureRate = sum(objDetectionCompositeFailures)/numOfValidTests;
    classcompositeMRFailureRate = sum(objClassificationCompositeFailures)/numOfValidTests;

end