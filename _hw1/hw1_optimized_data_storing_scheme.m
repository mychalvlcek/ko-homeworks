function hw1_optimized_data_storing_scheme
% hw 1 - optimized data storing scheme
clc;
disp('Input data A = 8 x 17');
disp('------------------------------------------------------');
A = [ 1 2 3 4 5 6 7 8 9 3 6 5 3 4 2 7 4;
  2 3 4 5 6 4 7 8 9 3 5 2 6 7 8 4 5;
  4 5 7 8 9 3 6 4 6 8 4 5 2 7 4 5 4;
  3 3 3 8 9 3 6 4 6 8 4 5 2 7 7 4 -1;
  6 4 4 5 6 3 7 5 7 8 9 3 5 3 7 -1 0;
  6 4 4 5 6 3 7 8 6 9 3 6 5 3 4 -1 4;
  1 2 3 4 6 4 4 5 6 6 9 3 6 5 3 -1 0;
  1 2 3 4 6 0 0 5 4 4 5 6 6 9 3 -1 0]

% load('oldStorage.mat')
% disp(' ');
% A = oldStorage;

n = size(A,1); % number of records (nodes)
m = size(A,2); % number of records (nodes)
X(:,:) = inf;

for i = 1:n;
    for j = i+1:n;
        x = A(i,:);
        if i ~= j
            index = find(A(i,:) == -1, 1);
            if index > 0
                x(index:m) = [];
            end

            y = A(j,:);
            index = find(A(j,:) == -1, 1);
            if index > 0
                y(index:m) = [];
            end

            dist = levenshtein(x, y);
            X(i,j) = dist;
            X(j,i) = dist;
        end
    end
end
X
g = graph(X);
g = spanningtree(g);

mat = edges2matrixparam(g);

sum(mat(mat<inf))

graphedit(g)
end

function dist = levenshtein(w1, w2)
% calculation of levenshtein distance of two input vectors
m=length(w1);
n=length(w2);
v=zeros(m+1,n+1);
for x=1:m
    v(x+1,1)=x;
end
for y=1:n
    v(1,y+1)=y;
end
for x=1:m
    for y=1:n
        if (w1(x) == w2(y))
            v(x+1,y+1)=v(x,y);
        else
            v(x+1,y+1)=1+min(min(v(x+1,y),v(x,y+1)),v(x,y));
        end
    end
end
dist = v(m+1,n+1);
end