function hw3_func_aprox
clc;
disp('HW3 /A');
alpha = 2;
beta = 10;
% x = [0.8  2.15  2.9  4.1];
% f = [0.1  0.7  1.3  0.65];
x = [0  1.26  2.51  3.77  5.03  6.28];
f = [0.01  1.16  0.70  -0.34  -0.80  0.2100];

matrix = inf*ones(length(x),length(x));

for i = 1:length(x)
    for j = i+1:length(x)
        tmp = 0;
        for k = i:j
            xx = f(i) + ( x(k) - x(i) ) * ( f(j)-f(i) )/( x(j)-x(i) );
            tmp = tmp + (beta * (f(k) - xx)^2 );
        end
        matrix(i,j) = alpha + tmp;
    end
end

previous = dijkstra(matrix);

i = size(matrix,1);

resultY(1:i) = inf;
resultX(1:i) = inf;

resultX(1) = x(1);
resultY(1) = f(1);

resultX(i) = x(i);
resultY(i) = f(i);

while previous(i) > 0
    resultX(previous(i)) = x(previous(i));
    resultY(previous(i)) = f(previous(i));
    i = previous(i);
end

resultX = resultX(resultX<inf)
resultY = resultY(resultY<inf)
plot(x,f)
hold on
plot(resultX,resultY, '-.r')
legend('original', 'aproximated')
hold off

% ---------------

disp('HW3 /B');
load('czechRepublic.mat')

alpha = 2;
beta = 10;
step = 100;

width = ceil(length(x)/step);
matrix = inf*ones(width,width);

for i = 1:step:length(x)
    for j = i+1:step:length(x)
        tmp = 0;
        
        % rovnice primky
        ux = x(j) - x(i);
        uy = y(j) - y(i);
        
        a = -uy;
        b = ux;
        c = -a*x(i) - b*y(i);
        
        for k = i+1:step:j-1
            dist = (a*x(k) + b*y(k) + c)^2/a^2 + b^2;
            tmp = tmp + dist;
        end
        ii = ceil(i/step);
        jj = ceil(j/step);
        matrix(ii,jj) = alpha + beta*tmp;
    end
end
previous = dijkstra(matrix);

i = size(matrix,1);

resultY(1:i) = inf;
resultX(1:i) = inf;

resultX(1) = x(1);
resultY(1) = y(1);

resultX(i) = x(i);
resultY(i) = y(i);

while previous(i) > 0
    resultX(previous(i)) = x(previous(i)*step);
    resultY(previous(i)) = y(previous(i)*step);
    i = previous(i);
end

resultX = resultX(resultX<inf)
resultY = resultY(resultY<inf)

plot(x,y)
hold on
plot(resultX,resultY, '-.r')
legend('original', 'aproximated')
hold off

end

function from = dijkstra(matrix)
n = size(matrix, 1)

distances(1:n) = inf;
distances(1) = 0;

queue = distances;
from(1:n) = 0;

for loop = 1:n
    [minValue,node] = min(queue);
    queue(node) = inf;

     for v = 1:n
         if(matrix(node,v) < inf)
             if ( distances(v) > (distances(node) + matrix(node,v)) )
                 distances(v) = distances(node) + matrix(node,v);
                 queue(v) = distances(v);
                 from(v) = node;
             end
         end
     end    
end
end