MLE algorithm

colormle function(A,samples) approximate parameters

## Note Parameters are initialized random colors
## We can test with all zero or other random numbers too
## I can get converged values with any initial parameters within 20 epoch in simple graph

example :
A = [ 0 1 1; 1 0 0; 1 0 0]
w = [ 1 2 3 4];
samples = gibbs(A,w,100,100);
colormle(A,samples)
