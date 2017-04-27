function w = colormle(A, samples)

nodeNum = size(A,1);

colorNum = length(samples(1,:));
theta = randi(colorNum,colorNum,1);
time = sum(samples(1,:));

learningrate = 1;
its = 20;
f_c = sum(samples)'/time;

for steps=1:its
    
    fprintf("Step %d\n", steps);
    [b,b_edge] = sumprod(A,theta',100);
    
    
    expectation = sum(b)';
    
    gradient = learningrate*( f_c - expectation );
    
                         
    theta = theta + gradient;
    
    
end
w = theta;
end
