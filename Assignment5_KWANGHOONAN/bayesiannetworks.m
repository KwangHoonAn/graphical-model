%% Import data
[train_data,train_text,train_cls, attrName] = preprocessing();

unique_cls = unique(train_cls);
clsNum = size(unique_cls,1);
data_attrNum = size(train_data, 2);
text_attrNum = size(train_text, 1);
priors = zeros(clsNum,1);
for i = 1:clsNum
  priors(i) = sum(train_cls==unique_cls(i))/length(train_cls);
end

  #train_text{1,indexed}
attrName;
dataIndx = [2 3 4 5 6 12 13 14 15 16 17 18];
txtIndx = [1 7 8 9 10 11];

%%% Unique attr values
for i = 1:data_attrNum-1
data_attr(1).(attrName{dataIndx(i)}) = unique(train_data(:,i))';
end
data_attr(1).(attrName{dataIndx(end)}) = 0:93;
for i = 1:text_attrNum
txt_attr(1).(attrName{txtIndx(i)}) = unique(train_text(i,:));
end


%%%%%%%%%%% Modeling Naive Bayes %%%%%%%%%%%

for i = 1:size(unique_cls,1)
  %% Return all data indexs corresponding to chosen class
  indexed = find(train_cls==unique_cls(i))';    
  
  for attr = 1:data_attrNum
    %% Distinct data points given class
    all_GivenClass = train_data(indexed,attr);
    %% Return all datas given class
    distinctGivenClass = unique(all_GivenClass);
    
    vect = zeros(length(data_attr(1).(attrName{dataIndx(attr)})),1);
    for dist = 1:size(distinctGivenClass,1)
      vect(find(ismember(data_attr(1).(attrName{dataIndx(attr)}), distinctGivenClass(dist)) == 1)) = length(find(all_GivenClass == distinctGivenClass(dist)));
    end
    prob = vect./sum(vect);
    if sum(vect) ~=0
      naivemodel(i).(attrName{dataIndx(attr)}) = prob;
    endif
  end
  
end


naivemodel(i).(attrName{dataIndx(12)});

for i = 1:size(unique_cls,1)
  %% Return all data indexs corresponding to chosen class
  indexed = find(train_cls==unique_cls(i))';    
  
  for attr = 1:text_attrNum
    %% Distinct data points given class
    all_GivenClass = train_text(attr,indexed);
    %% Return all datas given class
    distinctGivenClass = unique(all_GivenClass);
    #distinctGivenClass
    vect = zeros(length(txt_attr(1).(attrName{txtIndx(attr)})),1);
        
    for dist = 1:size(distinctGivenClass,2)
      vect(find(ismember(txt_attr(1).(attrName{txtIndx(attr)}), distinctGivenClass{dist}) == 1)) = sum(ismember(all_GivenClass, distinctGivenClass{dist}));
    end
    prob = vect./sum(vect);
    if sum(vect) ~=0
      naivemodel(i).(attrName{txtIndx(attr)}) = prob;
    endif
  end
  
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[test_data,test_text,test_cls] = getTest();
totalNum = size(test_cls,1);
correctAnswer = 0;
for n = 1:totalNum
  mle = ones(size(unique_cls,1),1);
  for i =1:size(unique_cls,1)
    for attr =1:text_attrNum  
      idx = find(ismember(txt_attr(1).(attrName{txtIndx(attr)}),test_text{attr,n}) == 1);
      mle(i) *= naivemodel(i).(attrName{txtIndx(attr)})(idx);
    end
    
    for attr=1:data_attrNum
      #attrName{dataIndx(attr)},data_attr(1).(attrName{dataIndx(attr)}), test_data(n,attr), dataIndx(attr), n
      idx = find(data_attr(1).(attrName{dataIndx(attr)}) == test_data(n,attr));   
      mle(i) *= naivemodel(i).(attrName{dataIndx(attr)})(idx);
    end
    mle(i)*=priors(i);
  end
  max(mle);
  if unique_cls(find(max(mle) == mle)) == test_cls(n)
    correctAnswer += 1;
  endif
end
correctAnswer
accuracy = (correctAnswer/totalNum)

