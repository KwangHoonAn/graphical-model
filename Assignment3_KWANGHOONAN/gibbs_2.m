function m = test(A, w)

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
burnBucket = 100;
itsBucket = 50;
Converge = zeros(4,4);

initial_X
%%%%% Gibbs Sampling %%%%%
updated_X = zeros(burnBucket + itsBucket, nodeNum);
for t = 1:burnBucket+itsBucket
    probs_X = zeros(colorNum,1);
    for j = 1:nodeNum
        for s = 1:colorNum
            probs_X(s) = exp(s);
                neighbors = 1;
                for i = 1:nodeNum
                    if ( A(i,j) == 1 )
                        neighbors = neighbors * exp(initial_X(i))*Indicator(s,i,initial_X,t);
                    endif
                end
                probs_X(s) = probs_X(s)*neighbors;
            end

            probs_X = probs_X ./ sum(probs_X);

            randomSample = rand(1);
            temp=0;
            for xi=1:colorNum
                temp = temp+=probs_X(xi);
                if randomSample < temp
                    initial_X(j) = xi;
                end
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
        Converge(burnin, its) = m(4,1)
end


end

%% Indicator function If adjacent vertices have same color return 0, 1 otherwise
function OneOrZero = Indicator(s, i, colNeightbor)
    if ( s ~= colNeightbor(i) )
        OneOrZero = 1;
    else
        OneOrZero = 0;
    end
end
