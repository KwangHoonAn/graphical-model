function m = gibbs(A, w, burnin, its)

nodeNum = size(A,1);
colorNum = size(w, 1);

vertices = size(colorNum,nodeNum);

%%%%% Choose an initial assignment x_0 - Note : It has to be valid (Non-zero) assignment%%%%%
initial_X = zeros(1, nodeNum);
for i = 1:nodeNum
    x = randi(colorNum);

    while length(find(initial_X(:) == x)) > 0
       x = randi(colorNum);
    end
    initial_X(i) = x;
end

initial_X
%%%%% Gibbs Sampling %%%%%
updated_X = zeros(burnin+its, nodeNum);
for t = 1:burnin + its
    probs_X = zeros(colorNum,1);
    for j = 1:nodeNum
        for s = 1:colorNum
            probs_X(s) = exp(w(s));
            neighbors = 1;
            for i = 1:nodeNum
                if ( A(i,j) == 1 )
                    neighbors = neighbors * exp(w(initial_X(i)))*Indicator(s,i,initial_X,t);
                endif
            end
            probs_X(s) = probs_X(s)*neighbors;
            end
            probs_X = probs_X ./ sum(probs_X);

            %%%%% Draw a line and sample %%%%%
            first = probs_X(1);
            second = probs_X(2);
            third = probs_X(3);
            fourth = probs_X(4);
            randomSample = rand(1);
            secondSum = first+second;
            thirdSum = secondSum+third;
            if le(randomSample, first)
                z = 1;
            elseif lt(first, randomSample)&&le(randomSample, secondSum)
                z = 2;
            elseif (lt(secondSum, randomSample)&&le(randomSample, thirdSum))
                z = 3;
            else
                z = 4;
            endif


            initial_X(j) = z;
        end
        updated_X(t,:) = initial_X;
    end

    %% Calculate probability
    for i = 1 :colorNum
        for j = 1 : nodeNum
            vertices(i,j) = sum(updated_X(:,j) == i);
        end
    end

    normalConstant = sum(vertices);
    m = vertices ./ normalConstant;

end



%% Indicator function If adjacent vertices have same color return 0, 1 otherwise
function OneOrZero = Indicator(s, i, corNeightbor)
    if ( s ~= corNeightbor(i) )
        OneOrZero = 1;
    else
        OneOrZero = 0;
    end
end

