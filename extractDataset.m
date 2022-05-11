% original code from https://es.mathworks.com/matlabcentral/answers/330208-random-extraction-of-files-from-a-folder

function extractDataset(sourceDir, noOfSubsets, noOfImages)
   
    for i=1:noOfSubsets
        sub_destDir = fullfile(sourceDir, strcat('subset',string(i)));
        if ~exist(sub_destDir, 'dir')
            mkdir(sub_destDir)
        end
        FileList = dir(fullfile(sourceDir, '*.jpg' ));
        Index = randperm(numel(FileList), noOfImages);
        for k = 1:noOfImages
          Source = fullfile(sourceDir, FileList(Index(k)).name);
          copyfile(Source, sub_destDir);
        end
        fprintf('dataset %s created \n',string(i))
    end
end