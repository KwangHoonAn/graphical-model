function [test_data,test_text,test_cls] = getTest()
  delimiterIn = ',';
  imported_test = importdata('student_test.data', delimiterIn);
  test_data = imported_test.data;
  test_data(:,6:10) = [];
  test_cls = test_data(:,end:end);
  test_data = test_data(:,1:end-1);
  
  test_text = imported_test.textdata;
  test_text = test_text(2:end);
  rowNum = size(test_data,1);
  test_text = reshape(test_text,6,rowNum);

end
