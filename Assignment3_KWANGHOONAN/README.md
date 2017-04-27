Gibbs sampling algorithm

gibbs function(A,w,burnin, its) will return probability

%%%%% Output matrix Column denotes vertices
%%%%% Output matrix Row denotes colors

A is the number adjacency matrix with size N x N
w is the weight indicating colors

example :
A = [ 0 1 ; 1 0 ];
w = [ 1 ; 2 ; 3 ; 4];

%%%%% Note : I have implemented only when there are four colors,
%%%%% If we want to add more colors, i need to slightly change if statement for drawing a sample
%%%%% In order to check if its correct, we can plug in same color weights then probability will be uniformly distributed
