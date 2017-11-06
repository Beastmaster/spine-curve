

# Haar-like feature training

----
## Workflow

1. **sort_data.m**: Load training and testing data (filenames) to .mat file. Testing and training data are small patches. 
2. **train_classifier**: train a svm classifier, save model to model.mat. 
3. **test_classifier**: load test data and model from .mat file. Use *cellfun* to accelerate.
**Note:**
- Patch size: 200X240
- Resize factor: detail in scripts

# utils
- test.m
- symm.m
- haar_masks.m: create haar-like feature mask. 
- haar_feature.m: Use convolution to replace integral image.


## Deprecated
- training.mat
- svm_classify.m
- construct_data_for_training.m




