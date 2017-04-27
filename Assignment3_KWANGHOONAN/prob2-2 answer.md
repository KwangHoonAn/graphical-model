You can simulate and see the result using gibbs_2(A,w) --- Running time may take more than 30 minutes

with Adjacency matrix and weight w
A = [0 1 1 1 ;1 0 0 1; 1 0 0 1; 1 1 1 0]
w = [1;2;3;4]

Initial_X is an initial color assignment for each vertices, column denotes each variable Xa, Xb, Xc, Xd respectively

Matrix Converge is the constructed table from the set {2^6, 2^10, 2^14, 2^18}, row denotes burnin, column denotes its

I could observe that no matter i initially assigned different colors on each vertices, gibbs sampling could eventually approximate true distribution with high number of iterations.
But, with low number of burnin,its iterations, sampling yeilds different result.
Therefore, sampling does not depend on the initial choice of assignment used in my Gibbs sampling algorithm

Below are simulation results for different initial assignment

(1)
initial_X =

2   3   4   1

Converge =

0.42188   0.13603   0.17443   0.17469
0.17096   0.15186   0.18089   0.17276
0.17491   0.18244   0.17899   0.17591
0.18091   0.17260   0.17570   0.17429


(2)
initial_X =

1   4   2   3

Converge =

0.093750   0.156250   0.167741   0.172436
0.204963   0.206055   0.155618   0.167209
0.192607   0.177562   0.156616   0.174395
0.171368   0.182397   0.175304   0.169207

(3)
initial_X =

4   1   3   2

Converge =

0.28125   0.28217   0.17017   0.17236
0.27941   0.25000   0.19296   0.17485
0.18294   0.16056   0.20297   0.17374
0.17328   0.17869   0.17246   0.17279
