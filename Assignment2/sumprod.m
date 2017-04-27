function [Z] = sumprod(A,w, its)

nodeNum = size(A, 1);
dmainSize = size(w, 1);

newMsg = ones(nodeNum,nodeNum,dmainSize);
oldMsg = newMsg;

%% marginal probability of a vertex and an edge
belief_Xi = ones(dmainSize, nodeNum);
belief_XiXj = zeros(dmainSize, dmainSize, nodeNum, nodeNum);

%%%%% initialize phi domain for total number of vertecies %%%%%
phi = [w];
for newCol = 1 : nodeNum-1
    phi = [phi w];
end

    for it = 1: its
        scale = 1/it;
        for i = 1: nodeNum
            for j = 1: nodeNum
                %% update only if vertex i and j are connected
                if (A(i,j) == 1)
                    % possible colors of x_j
                    for xj = 1:dmainSize
                        newMsg(i,j,xj) = updateMessage(i, j, xj, A, phi, oldMsg, scale);
                    end
                end
            end
        end
        oldMsg = newMsg;
    end

    %%% Compute belief for singleton
    for i = 1: nodeNum
        for xi = 1:dmainSize
            beliefXi(xi, i) = exp( phi(xi, i) ) * getSingletonBelief(i, xi, newMsg);
        end
    end

    %%% normalize belief using gamma
    gamma = getGamma(beliefXi);
    for i = 1 : nodeNum
        beliefXi(:,i) = gamma(i) * beliefXi(:,i);
    end

    %%% Compute belief of edge between xi and xj
    for i = 1: nodeNum
        for j = 1: nodeNum
            if( A(i, j) == 1)
                for xi = 1:dmainSize
                    for xj = 1:dmainSize
                        belief_XiXj(xi, xj,i,j) = Indicator(i, j, xi, xj, phi) * exp( phi(xi, i) ) * exp( phi(xj, j) ) * getNeighborMsg(i, j, xi, newMsg, A) * getNeighborMsg(j, i, xj, newMsg, A);
                    end
                end
            end
        end
    end

    for i = 1:nodeNum
        for j = 1:nodeNum
            gamma_XiXj = getGammaEdge(belief_XiXj(:,:,i,j));
            belief_XiXj(:,:, i, j) = gamma_XiXj * belief_XiXj(:,:, i, j);

        end
    end

    %%%%%% Plug into Bethe Free Energy %%%%%%

    %%% Calc First term of Entropy
    fistEntropy = 0;
    for i = 1: nodeNum
        for xi = 1:dmainSize
            belief_Log = log(beliefXi(xi, i));
            fistEntropy = fistEntropy + beliefXi(xi, i) * belief_Log;
        end
    end

    %%% Calc Second term of Entropy
    secondEntropy = 0;
    wholeTerm = 0;
    log_term = 0;
    for i = 1: nodeNum
        for j = 1: i
            if( A(i, j) == 1)
                for xi = 1:dmainSize
                    for xj = 1:dmainSize
                            belif_inClique = beliefXi(xi, i)*beliefXi(xj, j);
                            log_term = belief_XiXj(xi,xj,i,j)/belif_inClique;
                        if( log_term ~= 0)
                            wholeTerm = log(log_term);
                        end

                        secondEntropy = secondEntropy + belief_XiXj(xi, xj, i, j) * wholeTerm;

                    end
                end
            end
        end
    end

    %%%%%%%%%% first term to approximate %%%%%%%%%%
    appxOfphi = 0;
    for i = 1: nodeNum
        for xi = 1:dmainSize
            belief_Log = log( exp( phi(xi, i) ));
            appxOfphi = appxOfphi + beliefXi(xi, i) * belief_Log;
        end
    end

    %%% it will only return 0
    appxOfclique = 0;
    for i = 1:nodeNum
        for j = 1:nodeNum
            for xi = 1:dmainSize
                for xj = 1:dmainSize
                    if( Indicator(i,j,xi,xj,phi) == 0 )
                        lnTerm = 1;
                    else
                        lnTerm = log( Indicator(i,j,xi,xj,phi) );
                    end
                    appxOfclique = appxOfclique + belief_XiXj(xi,xj,i,j)*lnTerm;
                end
            end
        end
    end

fprintf('Belief of each vertices - row denotes colors, column denotes a vertex\n');
disp(beliefXi);
fprintf('Belief of edges rows and columns denote combination of colors\n');
fprintf('Dimentions denote vertecies in clique\n');
disp(belief_XiXj);

BetheFreeEntropy = - (fistEntropy + secondEntropy);
LowerBoundLogZ = appxOfphi + appxOfclique + BetheFreeEntropy;

LowerBoundLogZ
Z = exp(LowerBoundLogZ);

end

%% Normalizing constants
function gamma = getGamma(beliefXi)
    if sum(beliefXi) ~= 0
        gamma = 1 ./ sum(beliefXi);
    else
        gamma = 0;
    end
end

function gammaXiXj = getGammaEdge(beliefXiXj)
    if sum(sum(beliefXiXj)) ~= 0
        gammaXiXj = 1 ./ sum(sum(beliefXiXj));
    else
        gammaXiXj = 0;
    end
end

%%% Calculate messages
function scaledMsg = updateMessage(i, j, xj, A, phi, oldMsg, scale)
    [rowsA, colsA] = size(phi);
    msgSum = 0;
    for xi = 1:rowsA
        msgSum = msgSum + exp( phi(xi,i) ) * Indicator(i, j, xi, xj, phi) * getNeighborMsg(i, j, xi, oldMsg, A);
    end
    scaledMsg = msgSum*scale;
end

%% Calculate message for singleton belief
function msg = getSingletonBelief(i, xi, newMsg)
    [verticesRow, verticesCol, color] = size(newMsg);
    msg = 1;
    for vertex_k = 1: verticesRow
        msg = msg * newMsg(vertex_k, i,xi);
    end
end

%% Indicator function If adjacent vertices have same color return 0, 1 otherwise
function OneOrZero = Indicator(i, j, xi, xj ,phi)
    % In case colors of x_i and x_j are different
    if  ( phi(xi, i) ~= phi(xj, j))
        OneOrZero = 1;
    else
        OneOrZero = 0;
    end
end

function msgOfNeibs = getNeighborMsg(i, j, xi, oldMsg, A)
	msg = 1;
    [rowsA, colsA] = size(A);
    for k = 1: rowsA
        %% i and k are connected and k is not equal to j
		if (k ~= j ) && (A(i, k) == 1)
			msg = msg*oldMsg(k, i, xi);
		end
    end
    msgOfNeibs = msg;
end

