function [objfailureRateMR1, classfailureRateMR1, objfailureRateMR2, classfailureRateMR2, ...
        objcombinedFailureRateMR1MR2, classcombinedFailureRateMR1MR2, objcompositeMRFailureRate, ...
        classcompositeMRFailureRate, objDetectClassFailureRateMR1, objDetectClassFailureRateMR2, ...
        objDetectClassFailureRateMR1MR2, objDetectClassFailureRateMR12, ...
        compositeMRMutationScore, odCompositeMRMutationScore, ocCompositeMRMutationScore, ...   
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
        [rows, columns, numberOfColorChannels] = size(sourceTestcase);
        if numberOfColorChannels > 1 % filters out greyscale images        
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
            
            %get combined failure rate for object detection and classification
            %failures
            if objDetectionFailuresMR1(numOfValidTests, 1) == 1 && objClassificationFailuresMR1(numOfValidTests, 1) == 1 
            % combined is 1
                objClassDectectFailuresMR1(numOfValidTests, 1) =  1;
            else
            % combined failure rate is 0
                objClassDectectFailuresMR1(numOfValidTests, 1) =  0;
            end
        end
    end
    tMR1 = toc;
    
    objfailureRateMR1 = sum(objDetectionFailuresMR1)/numOfValidTests;
    classfailureRateMR1 = sum(objClassificationFailuresMR1)/numOfValidTests;
    objDetectClassFailureRateMR1 = sum(objClassDectectFailuresMR1)/numOfValidTests;
    
    %% Execute MR2
    numOfValidTests1 = 0;    
    tic;
    for j = 1 : length(theFiles) % loop through images in dataset
        % Get source image
        sourceTestcase = imread(fullfile(theFiles(j).folder, theFiles(j).name));
        [rows, columns, numberOfColorChannels] = size(sourceTestcase);
        if numberOfColorChannels > 1 % filters out greyscale images        
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
            
            %get combined failure rate for object detection and classification
            %failures
            if objDetectionFailuresMR2(numOfValidTests1, 1) == 1 && objClassificationFailuresMR2(numOfValidTests1, 1) == 1 
            % combined is 1
                objClassDectectFailuresMR2(numOfValidTests1, 1) =  1;
            else
            % combined failure rate is 0
                objClassDectectFailuresMR2(numOfValidTests1, 1) =  0;
            end
        end
    end
    tMR2 = toc;
    
    objfailureRateMR2 = sum(objDetectionFailuresMR2)/numOfValidTests1;
    classfailureRateMR2 = sum(objClassificationFailuresMR2)/numOfValidTests1;
    objDetectClassFailureRateMR2 = sum(objClassDectectFailuresMR2)/numOfValidTests1;
    
    tMR12 = tMR1+tMR2;

    %% obtain objDetectionFailures rate for MR1 and MR2 combined
    objfailuresCombined = 0;
    for k=1:length(objDetectionFailuresMR1)
        if objDetectionFailuresMR1(k,1)==1||objDetectionFailuresMR2(k,1)==1
            objfailuresCombined = objfailuresCombined+1;
            combinedDetectFailuresMR1MR2(k,1) = 1;
        else
            combinedDetectFailuresMR1MR2(k,1) = 0;
        end
    end
    objcombinedFailureRateMR1MR2 = objfailuresCombined/numOfValidTests;
    
    %% obtain objClassificationFailures rate for MR1 and MR2 combined
    classfailuresCombined = 0;
    for k=1:length(objClassificationFailuresMR1)
        if objClassificationFailuresMR1(k,1)==1||objClassificationFailuresMR2(k,1)==1
            classfailuresCombined = classfailuresCombined+1;
            combinedClassFailuresMR1MR2(k,1) = 1;
        else
            combinedClassFailuresMR1MR2(k,1) = 0;
        end
    end
    classcombinedFailureRateMR1MR2 = classfailuresCombined/numOfValidTests;
    
    %% obtain combined failure rate for MR1 and MR2 w.r.t. both object detection and classification
    combined_objdectectclassfailures = 0;
    for k=1:length(objClassDectectFailuresMR1)
        if objClassDectectFailuresMR1(k,1)==1||objClassDectectFailuresMR2(k,1)==1
            combined_objdectectclassfailures = combined_objdectectclassfailures+1;
            combinedClassDetectFailuresMR1MR2(k,1) = 1; % store this to use in MS for composite MR
        else
            combinedClassDetectFailuresMR1MR2(k,1) = 0;
        end
    end
    objDetectClassFailureRateMR1MR2 = combined_objdectectclassfailures/numOfValidTests;    
    
    %% Composite MR (MR1+MR2)
    numOfValidTests = 0;    
    tic;
    for j = 1 : length(theFiles) % loop through images in dataset
        % Get source image
        sourceTestcase = imread(fullfile(theFiles(j).folder, theFiles(j).name));
        [rows, columns, numberOfColorChannels] = size(sourceTestcase);
        if numberOfColorChannels > 1 % filters out greyscale images             
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
            
            %get combined failure rate for object detection and classification
            %failures
            if objDetectionCompositeFailures(numOfValidTests, 1) == 1 && objClassificationCompositeFailures(numOfValidTests, 1) == 1 
            % combined is 1
                objClassDectectFailuresMR12(numOfValidTests, 1) =  1;
            else
            % combined failure rate is 0
                objClassDectectFailuresMR12(numOfValidTests, 1) =  0;
            end
        end
    end
    tCompositeMR = toc;
    
    objcompositeMRFailureRate = sum(objDetectionCompositeFailures)/numOfValidTests;
    classcompositeMRFailureRate = sum(objClassificationCompositeFailures)/numOfValidTests;
    objDetectClassFailureRateMR12 = sum(objClassDectectFailuresMR12)/numOfValidTests;
    
    %% obtain unique object dectection failure rate for composite MR
    % failures that were dectected by the composite MR but not detected by
    % its composable MRs for object detection only
    uniqueCombinedFailures = 0;
    for k=1:length(objDetectionCompositeFailures)
        if objDetectionCompositeFailures(k,1)==1 && combinedDetectFailuresMR1MR2(k,1)== 0
            uniqueCombinedFailures = uniqueCombinedFailures+1;
        end
    end
    odCompositeMRMutationScore = uniqueCombinedFailures/numOfValidTests;
    
    %% obtain unique class dectection failure rate for composite MR
    % failures that were dectected by the composite MR but not detected by
    % its composable MRs for class detection only
    uniqueCombinedFailures = 0;
    for k=1:length(objClassificationCompositeFailures)
        if objClassificationCompositeFailures(k,1)==1 && combinedClassFailuresMR1MR2(k,1)== 0
            uniqueCombinedFailures = uniqueCombinedFailures+1;
        end
    end
    ocCompositeMRMutationScore = uniqueCombinedFailures/numOfValidTests;
    
    %% obtain unique object detection and classification failure rate for composite MR
    % failures that were dectected by the composite MR but not detected by
    % its composable MRs for both object detection and object classification
    uniqueCombinedFailures = 0;
    for k=1:length(objClassDectectFailuresMR12)
        if objClassDectectFailuresMR12(k,1)==1 && combinedClassDetectFailuresMR1MR2(k,1)==0
            uniqueCombinedFailures = uniqueCombinedFailures+1;
        end
    end
    compositeMRMutationScore = uniqueCombinedFailures/numOfValidTests;    
end