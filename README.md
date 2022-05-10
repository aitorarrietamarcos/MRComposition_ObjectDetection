# MRComposition_ObjectDetection

- Object detection models can be found at url - https://github.com/matlab-deep-learning/MATLAB-Deep-Learning-Model-Hub#ObjectDetection
- Model directories should be placed in dir 'models'
- Current dataset dir used is 'datasets/coco/images' url - https://cocodataset.org/#download

Execute 'mr_compostion_od.m' to view preliminary results in dir 'results'

Results currently include:
- No. of objects detected /testcase
- objDectectScores /testcase (no. of detected objects/no. of objects in source testcase)
- classScores /testcase (no. of correctly classified images/no. of objects in source testcase)
- exectimes /testcase (execution time per testcase, including followup testcase geneeration)
