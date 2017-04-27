EM algorithm

colorem function(A,samples) approximate parameters

example :
A = [ 0 1 1; 1 0 0; 1 0 0]
w = [ 1 2 3 4];
samples = gibbs(A,w,100,100);
colorem(A,i,samples)
