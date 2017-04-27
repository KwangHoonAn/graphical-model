function [train_data,train_text,train_cls, attrName] = preprocessing()
  delimiterIn = ',';
  imported_train = importdata('student_train.data', delimiterIn);
  train_data = imported_train.data;
  train_data(:,6:10) = [];
  train_data(end,:)=[];
  train_cls = train_data(:,end:end);
  train_data = train_data(:,1:end-1);
  
  train_text = imported_train.textdata;
  attrName = train_text(1,:);
  attrName = strsplit(cell2mat(attrName), ',');
  attrName(end) = [];
  attrName(~cellfun('isempty',attrName));
  train_text = train_text(2:end-1);
  rowNum = size(train_data,1);
  train_text = reshape(train_text,6,rowNum);

end
