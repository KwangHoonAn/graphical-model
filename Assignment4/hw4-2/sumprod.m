function [b,b_edge]=sumprod(A,w,its)
[~,colors]=size(w);
[n,~]=size(A);

%messages will be a 3-d matrix of the 
%2 nodes and the color of the destination
message=ones(n,n,colors)*rand(); %stores the messages at time t-1
future_message=zeros(n,n,colors); %stores the message at time t
    
    %calculating the messages
    for t=1:its
        for i=1:n
            for j=1:n
                %stores the normalizing constant from i to j at time t
                normalize=0;             
                for k=1:colors
                    for l=1:colors%the psi function correspods to whether the color of the two edges  are same or not
                        future_message(i,j,k)= future_message(i,j,k)+exp(w(l))*sign(abs(l-k))*getProduct1(A,message,i,j,l);
                    end
                    normalize=normalize+future_message(i,j,k);
                end          
                %normalizing the message from i to j at time t
                for k=1:colors
                    future_message(i,j,k)= future_message(i,j,k)/normalize;
                end 
            end
        end
        %setting the previous matrix as the current matrix
        %and making the current matrix as 0
        message=future_message;
        future_message=zeros(n,n,colors);
    end
    
    %calculating the marginal distribution of the vertices
    b=zeros(n,colors);
    for i=1:n
        normal=0; %normalizing constant
        for k=1:colors
            b(i,k)=exp(w(k))*getProduct2(A,message,i,k);
            normal=normal+b(i,k);
        end
        %normalizing the marginal distributions
        for k=1:colors
            b(i,k)=b(i,k)/normal;
        end     
    end
    
    %calculating the marginal distribution of the edges
    b_edge=zeros(n,n,colors,colors);
    for i=1:n
        for j=1:n
            normal=0 ; %normalizing constant
            for xi=1:colors
                for xj=1:colors
                    b_edge(i,j,xi,xj)=sign(abs(xi-xj))*exp(w(xi))*exp(w(xj))*getProduct1(A,message,i,j,xi)*getProduct1(A,message,j,i,xj);
                    normal=normal+b_edge(i,j,xi,xj);
                end
            end
            %normalizing the edge distributions
            for xi=1:colors
                for xj=1:colors
                    b_edge(i,j,xi,xj)=b_edge(i,j,xi,xj)/normal;
                end
            end
        end
    end
    
    %calculating the other term in the bethe free energy(Qc\psiC)
    %It has two parts, one is the summation over the single vertices.
    %Second is the summation over the edges
    val1=0;
    val2=0;
    for i=1:n
        for j=1:colors
            val1=val1+b(i,j)*w(j);%q(i)log(phi(x(i)))
        end
    end
 
    %  We dont need this value since sign(abs(l-k)) is an indicator function
    % in case when it's value is 1 then it's log will be 0 and since we want
    % to maximize this value we won't be including the case where the color
    % of two vertices are the same
    %     for i=1:n
    %         for j=1:n
    %             for k=1:colors
    %                 for l=1:colors
    %                     val2=val2+b_edge(i,j,k,l)*log(sign(abs(l-k)));
    %                 end
    %             end
    %         end
    %     end
    
    %Lets compute the entropy H
    %This also consists of two parts , one over the individual vertices
    %and the second one over the cliques
    h1=0;
    h2=0;
    for i=1:n
        for j=1:colors
            if b(i,j)~=0
                h1=h1+b(i,j)*log(b(i,j));
            end
        end
    end
    
    for i=1:n
        for j=i+1:n
            if A(i,j)~=0
                for xi=1:colors
                    for xj=1:colors
                        if b_edge(i,j,xi,xj)~=0
                            h2=h2+b_edge(i,j,xi,xj)*log(b_edge(i,j,xi,xj)/(b(i,xi)*b(j,xj)));
                        end
                    end
                end
            end
        end
     end

    H=-h1-h2;
    Z=exp(val1+val2+H);
end

%A-adjacency matrix
%message-message matrix
%source - the vertex which is not to be included in the multiplication
%dest - the vertex to which the messages are to be multiplied
%color - the color of the dest vertex
function val=getProduct1(A,message,source,dest,color)
    val=1;
    [rows,~]=size(A);
    for k=1:rows
        if A(k,source)~=0 && k~=dest
          val=val*message(k,source,color);  
        end
    end
end

%A-adjacency matrix
%message-message matrix
%dest - the vertex to which the messages are to be multiplied
%color - the color of the dest vertex
function val=getProduct2(A,message,dest,color)
val=1;
[n,~]=size(A);
    for i=1:n
        if A(i,dest)~=0
            val=val*message(i,dest,color);
        end
    end
end
