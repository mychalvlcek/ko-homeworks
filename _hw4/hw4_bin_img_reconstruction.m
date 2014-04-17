function hw4_bin_img_reconstruction
clc;
disp('HW4');
load('projectionData')

n = size(sumR,2); % 20
m = 2*n-1;
I = zeros(n,n);

countOfIterations = 7;
countOfPairs = 6;
for i = 1:countOfIterations
    for p = 1:countOfPairs
% CR         
        if p == 1
            p1 = sumC;
            p2 = sumR;
            
            b = [p1 -p2]';
            l = zeros(2*n);
            u = l;
            u(1:n,n+1:2*n) = 1;
            c = l;
%             c(1:n,n+1:2*n) = 1-I;
            for x = 1:n
                c(x,n+1:2*n) = 1-I(:,x)';
            end
% CD             
        elseif p == 2
            p1 = sumC;
            p2 = sumD;
            
            b = [p1 -p2]';
            l = zeros(size(p1,2)+size(p2,2));
            u = l;
            for x = 1:n
                u(x,n+x:(m+x)) = 1;
            end

            c = l;            
            for x = 1:n
                c(x,n+x:(m+x)) = 1-flipud(I(:,x))';
            end
% CA
        elseif p == 3
            p1 = sumC;
            p2 = sumA;
            
            b = [p1 -p2]';
            l = zeros(size(p1,2)+size(p2,2));
            u = l;
            for x = 1:n
                u(x,n+x:(m+x)) = 1;
            end
            c = l;
            for x = 1:n
                c(x,n+x:(m+x)) = 1-I(:,x)';
            end
% RD             
        elseif p == 4
            p1 = sumR;
            p2 = sumD;
            
            b = [p1 -p2]';
            l = zeros(size(p1,2)+size(p2,2));
            u = l;
            for x = 1:n
                u(x,2*n-x+1:3*n-x) = 1;
            end
            c = l;
            for x = 1:n
                c(x,2*n-x+1:3*n-x) = 1-I(x,:);
            end
% RA
        elseif p == 5
            p1 = sumR;
            p2 = sumA;
            
            b = [p1 -p2]';
            l = zeros(size(p1,2)+size(p2,2));
            u = l;
            for x = 1:n
                u(x,n+x:(m+x)) = 1;
            end
            c = l;
            for x = 1:n
                c(x,n+x:(m+x)) = 1-I(x,:);
            end
% DA
        elseif p == 6
            p1 = sumD;
            p2 = sumA;
            
            b = [p1 -p2]';
            l = zeros(size(p1,2)+size(p2,2));
            u = l;
            for x = 1:n
                u(x,3*n-x:2:3*n+x-2) = 1;
                u(2*n-x,3*n-x:2:3*n+x-2) = 1;
            end
            c = l;
            for x = 1:n
                ci = 1;
                i_x = n-x+1;
                for y = 1:x
                    c(x,3*n-x+ci-1) = 1-I(i_x,y);
                    c(2*n-x,3*n-x+ci-1) = 1-I(y,i_x);
                    ci = ci+2;
                    i_x = i_x+1;
                end
            end
        end

        G = graph;
        F = G.mincostflow(c,l,u,b);
        if p == 1
            for x = 1:n
                I(:,x) = F(x,n+1:2*n)';
            end
        elseif p == 2
            for x = 1:n
                I(:,x) = flipud(F(x,n+x:(m+x))');
            end
        elseif p == 3
            for x = 1:n
                I(:,x) = F(x,n+x:(m+x))';
            end
        elseif p == 4
            for x = 1:n
                I(x,:) = F(x,2*n-x+1:3*n-x);
            end
        elseif p == 5
            for x = 1:n
                I(x,:) = F(x,n+x:(m+x));
            end
        elseif p == 6
            for x = 1:n
                ci = 1;
                i_x = n-x+1;
                for y = 1:x
                    I(i_x,y) = F(x,3*n-x+ci-1);
                    I(y,i_x) = F(2*n-x,3*n-x+ci-1);
                    ci = ci+2;
                    i_x = i_x+1;
                end
            end
        end
        display_image(I,((i-1)*countOfPairs)+p, countOfIterations, countOfPairs);
    end
end

end
% image display
function display_image(I, order, countOfIterations, countOfPairs)
    subplot(countOfIterations,countOfPairs,order);
    imagesc(logical(I));
    colormap(gray);
    axis off;
    axis square;
end