#################################
######### KWANG HOON AN #########
#################################

Note : Please open 'UndirectedMST' picture, it is Maximum Spanning Tree given dataset
Each number [0-18] indicates each columns given dataset. For example, '18' is class variable

Note : For python script, you may need python version 3.6.x

1. Naive bayes is written in Matlab ( 'bayesiannetworks.m' for naive bayes, 'getTest.m', 'preprocessing.m' for data preprocessing since matlab needs preprocessing for string data )
This program gives 9% accuracy, which is not reasonable.

2. Chowliu tree algorithm is written in python.
ChowLiu Tree algorithm gives 12.12% accuracy, which is relatively better but not that great
I could at least observe improved accuracy with chowliu tree, not idealistically improved though.

3. Conclusion
Given this data, we are not able to observe high accuracy its because some test data's unique discrete values
in attributes are not in training data set. Therefore, while traininig parameter(probability) we could not get non-zero probability for those. In order to improve accuracy, we may need smoothing method for non existing values.
