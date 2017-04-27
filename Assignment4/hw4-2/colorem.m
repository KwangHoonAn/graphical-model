function w = colorem(A, i, samples)

%%% Hyper parameters %%%
nodeNum = size(A,1);
iteration = 20;
colorNum = length(unique(samples));

theta = randi(colorNum,colorNum,1);
time = length(samples);

observedSample = samples;
observedSample(i,:) = [];
f_c = zeros(nodeNum-1, colorNum);
obsNodeNum = size(f_c,1);

for obs = 1:obsNodeNum
  for col = 1:colorNum
    f_c(obs, col) = length(find(observedSample(obs,:)==unique(observedSample)(col)));
  end
end
#f_c
#f_c = sum(f_c + 1)'/(time*colorNum);

for it =1:iteration
    
    %%%% E steps %%%%
    q = zeros(colorNum,time);

    for m = 1:time
      tempQ = zeros(1,colorNum);   
      for col = 1:colorNum    
        for xi = 1:nodeNum
          if( A(i,xi) == 1 )
            tempQ(col) += theta(samples(xi,m));
          endif
        end
        tempQ(col) += (theta(col));
      end
      q(:,m) = (tempQ')/(sum(tempQ));
      
    end
    
    
    %%%% M Steps %%%%
    b = sumprod(A,theta',100);
    
    expectation = sum(b)';
    #error = (f_c - expectation);
    #secondTerm = sum(q')'.*error;
    #secondTerm = error;
    
    secondTerm = zeros(colorNum,1);
    for m = 1:time
      vec = zeros(colorNum,1);
      for x_obs = 1:nodeNum
        if ( x_obs ~= i)
          vec += feature(samples(x_obs,m),colorNum);
        endif
      end
      sumterm = q(:,m).*( vec + 1 );
      theta += sumterm;
    end
    
    theta = theta .- expectation.*sum(q')';
    theta;
    %%%%%%%%%%%%%%%%%
    #
    #theta = theta + secondTerm;
end
w = theta;

end

function f = feature(color, colorNum)
  f = zeros(colorNum,1);
  f(color) = 1;
end

