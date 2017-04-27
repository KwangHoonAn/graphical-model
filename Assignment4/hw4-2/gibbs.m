function [updated_X,m]=gibbs(A,w,burnin,its)
%get the number of nodes
[n,~]=size(A);
%get the number of colors
[~,colors]=size(w);
%assign random colors to the nodes
currcolor=randi(colors,1,n);
%stores the probability of node i having color j
currprob=zeros(n,colors);
%final probability of node's color
m=zeros(n,colors);

updated_X = zeros(n, burnin+its);
%run the loop for burnin+its number of iterations
for t=1:burnin+its
    for i=1:n
        %get the probability of the node i having the color xi
        for xi=1:colors
            currprob(i,xi)=exp(w(xi));
            for j=1:n
                if A(i,j)~=0
                   currprob(i,xi)=currprob(i,xi)*sign(abs(xi-currcolor(1,j)));
                end
            end
        end
        
        %In case probabilities are zero for all colors then, assign uniform
        %probability distribution
        if sum(currprob(i,:))==0
            currprob(i,:)=ones(1,colors);
        end
        
        %normalize the probabilities of the node i
        currprob(i,:)=currprob(i,:)/sum(currprob(i,:));
        k=rand();
        temp=0;
        %let us check where the random number lies on the cumulative
        %distribution line
        for xi=1:colors
            temp=temp+currprob(i,xi);
            if k<temp
                currcolor(1,i)=xi;
                break
            end
        end
        updated_X(i,t) = currcolor(1,i);
        %when we get out of the burn-in phase, count the number of times we
        %have seen color currcolor(1,i) on the node i
        if t>burnin
            m(i,currcolor(1,i))=m(i,currcolor(1,i))+1;
        end
    end
end
updated_X = updated_X(:,burnin+1:end);
%normalize the count in order to get the probabilities

end
