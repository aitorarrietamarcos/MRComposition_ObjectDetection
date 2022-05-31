function [objfailureRateMR1,objfailureRateMR2, objcombinedFailureRateMR1MR2, ...
        objcompositeMRFailureRate, classfailureRateMR1, classfailureRateMR2, ...
        classcombinedFailureRateMR1MR2, classcompositeMRFailureRate, ...
        tMR1, tMR2, tMR12, tCompositeMR] = func_efficientdetd0(dataset, followup1, followup2, net, classNames, executionEnvironment)
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
        [bboxes,scores,labels] = detectEfficientDetD0(net, sourceTestcase, classNames, executionEnvironment);
        % store source testcase results
        source_labels = labels;
        source_noOfObjs = length(source_labels);
        % generate followup testcase
        followUpTestcase = followup1(sourceTestcase);       
        [bboxes,scores,labels] = detectEfficientDetD0(net, followUpTestcase, classNames, executionEnvironment);
        numOfValidTests = numOfValidTests + 1;        
        fobjs = length(labels);

        % Object detection score
        if fobjs == source_noOfObjs
            % detected all objects
            objDetectionFailuresMR1(numOfValidTests, 1) = 0;
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
        [bboxes,scores,labels] = detectEfficientDetD0(net, sourceTestcase, classNames, executionEnvironment);
        % store source testcase results
        source_labels = labels;
        source_noOfObjs = length(source_labels);
        % generate followup testcase
        followUpTestcase = followup2(sourceTestcase);       
        [bboxes,scores,labels] = detectEfficientDetD0(net, followUpTestcase, classNames, executionEnvironment);
        numOfValidTests1 = numOfValidTests1 + 1;        
        fobjs = length(labels);

        % Object detection score
        if fobjs == source_noOfObjs
            % detected all objects
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
    % objcombinedFailureRateMR1MR2 = (sum(objDetectionFailuresMR1) + sum(objDetectionFailuresMR2)) / (numOfValidTests + numOfValidTests1);
    objfailuresCombined = 0;
    for k=1:length(objDetectionFailuresMR1)
        if objDetectionFailuresMR1(k,1)==1||objDetectionFailuresMR2(k,1)==1
            objfailuresCombined = objfailuresCombined+1;
        end
    end
    objcombinedFailureRateMR1MR2 = objfailuresCombined/numOfValidTests;
    
    %% obtain objClassificationFailures statistics combined
    % classcombinedFailureRateMR1MR2 = (sum(objClassificationFailuresMR1) + sum(objClassificationFailuresMR2)) / (numOfValidTests + numOfValidTests1);
      classfailuresCombined = 0;
    for k=1:length(objClassificationFailuresMR1)
        if objClassificationFailuresMR1(k,1)==1||objClassificationFailuresMR2(k,1)==1
            classfailuresCombined = classfailuresCombined+1;
        end
    end
    classcombinedFailureRateMR1MR2 = classfailuresCombined/numOfValidTests;
    
    %% Composite MR (MR1+MR2)
    numOfValidTests = 0;    
    tic;
    for j = 1 : length(theFiles) % loop through images in dataset
        % Get source image
        sourceTestcase = imread(fullfile(theFiles(j).folder, theFiles(j).name));
        % Execute source testcase
        [bboxes,scores,labels] = detectEfficientDetD0(net, sourceTestcase, classNames, executionEnvironment);
        % store source testcase results
        source_labels = labels;
        source_noOfObjs = length(source_labels);
        % generate composite testcase
        compositeTestcase = followup2(followup1(sourceTestcase));
        [bboxes,scores,labels] = detectEfficientDetD0(net, compositeTestcase, classNames, executionEnvironment);
        numOfValidTests = numOfValidTests + 1;        
        fobjs = length(labels);

        % Object detection score
        if fobjs == source_noOfObjs
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