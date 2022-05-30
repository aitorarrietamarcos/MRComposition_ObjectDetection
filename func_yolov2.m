function [objfailureRateMR1,objfailureRateMR2, objcombinedFailureRateMR1MR2, ...
        objcompositeMRFailureRate, classfailureRateMR1, classfailureRateMR2, ...
        classcombinedFailureRateMR1MR2, classcompositeMRFailureRate, ...
        tMR1, tMR2, tMR12, tCompositeMR] = func_yolov2(dataset, followup1, followup2, detector)
       % check directory validity
    if ~exist(dataset, 'dir')
       fprintf('invalid dataset directory')
       return;
    end
    % Get all images from current dataset directory
    filePattern = fullfile(dataset, '*.jpg');
    theFiles = dir(filePattern);     
    %% Execute MR1
    numOfValidTests = 0;    
    tic;
    for j = 1 : length(theFiles) % loop through images in dataset
        % Get source image
        sourceTestcase = imread(fullfile(theFiles(j).folder, theFiles(j).name));
        % Execute source testcase        
        [boxes, scores, labels] = detect(detector, sourceTestcase);
        % store source testcase results
        source_labels = labels;
        source_noOfObjs = length(source_labels);
        % generate followup testcase
        followUpTestcase = followup1(sourceTestcase);
        [boxes, scores, labels] = detect(detector, followUpTestcase);
        numOfValidTests = numOfValidTests + 1;        
        fobjs = length(labels);

        % Object detection score
        if fobjs == source_noOfObjs
            objDetectionFailuresMR1(numOfValidTests, 1) = 0;
        else
            % failed
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
            if correct == source_noOfObjs
                % correctly classified all objects
                objClassificationFailuresMR1(numOfValidTests, 1) = 0;
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
        [boxes, scores, labels] = detect(detector, sourceTestcase);
        % store source testcase results
        source_labels = labels;
        source_noOfObjs = length(source_labels);
        % generate followup testcase
        followUpTestcase = followup2(sourceTestcase);       
        [boxes, scores, labels] = detect(detector, followUpTestcase);
        numOfValidTests1 = numOfValidTests1 + 1;        
        fobjs = length(labels);

        % Object detection score
        if fobjs == source_noOfObjs
            objDetectionFailuresMR2(numOfValidTests1, 1) = 0;
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
            if correct == source_noOfObjs
                % correctly classified all objects
                objClassificationFailuresMR2(numOfValidTests1, 1) = 0;
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
        [boxes, scores, labels] = detect(detector, sourceTestcase);
        % store source testcase results
        source_labels = labels;
        source_noOfObjs = length(source_labels);
        % generate composite testcase
        compositeTestcase = followup2(followup1(sourceTestcase));
        [boxes, scores, labels] = detect(detector, compositeTestcase);
        numOfValidTests = numOfValidTests + 1;        
        fobjs = length(labels);

        % Object detection score
        if fobjs == source_noOfObjs
            % detected same number of objects
            objDetectionCompositeFailures(numOfValidTests, 1) = 0;
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
            if correct == source_noOfObjs
                % correctly classified some objects
                objClassificationCompositeFailures(numOfValidTests, 1) = 0;
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