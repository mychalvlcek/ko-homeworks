function hw2_call_center_schledule
% hw 2 - call center schledule
clc;
disp('HW2 - task 1');

sense = 1; % sense of optimization: 1=minimization, -1=maximization
b = [6 6 6 6 6 8 9 12 18 22 25 21 21 20 18 21 21 24 24 18 18 18 12 8]'; % vector b
A = zeros(24,24);
for i = 1:24
    for j = i-7:i
        A(i,mod(j-1,24)+1) = 1;
    end
end

c = ones(1,24)';% vector c

ctype(1:24) = 'G';
ctype = ctype'; % constraint type: E =, L <=, G >=

lb = zeros(1,24)';% lower bound of the variables [0]
ub = (inf*ones(1,24))'; % upper bound of the variables [inf]

vartype(1:24) = 'I';
vartype = vartype'; %variable type: C=continuous, I=integer

%optimization parameters
schoptions=schoptionsset('ilpSolver','glpk','solverVerbosity',2);
%call command for ILP
[xmin,fmin,status,extra] = ilinprog(schoptions,sense,c,A,b,ctype,lb,ub,vartype);

%show the solution
if(status==1)
    disp('Solution: '); disp(xmin)
    disp('Objective function: '); disp(fmin)
    output(1,:) = xmin;
    output(2,:) = b;
    bar(output)
else
    disp('No feasible solution found!');
end;

disp('HW2 - task 2');
% xi - zi <= bi  --> 1:24
% xi + zi >= bi  --> 25:48

b = [b;b];
c = [zeros(1,24) ones(1,24)]';
A = zeros(24,48);
for i = 1:24
    for j = i-7:i
        A(i,mod(j-1,24)+1) = 1;
    end
end
for i=1:24
    A(i,24+i) = -1;
end
A=[A;A];
for i=25:48
    A(i,i) = 1;
end
disp('A');

sense = 1;
ctype(1:24) = 'L';
ctype(25:48) = 'G';
ctype = ctype';
lb = zeros(1,48)';
ub = [inf*ones(1,48)]';
vartype = repmat('I',48,1)';
schoptions=schoptionsset('ilpSolver','glpk','solverVerbosity',2);
[xmin,fmin,status,extra] = ilinprog(schoptions,sense,c,A,b,ctype,lb,ub,vartype);

res=zeros(1,24);
for i=0:23
    for j=0:7
    res(mod(i+j,24)+1)=res(mod(i+j,24)+1)+xmin(i+1);
    end
end

if(status==1)
    disp('Solution: '); disp(xmin)
    disp('Objective function: '); disp(fmin)
    
    disp('Plan smen: '); disp(res)
    disp('Lidi na pracovisti: '); disp(xmin(1:24)')
    disp('Celkem lidi: '); disp(sum(xmin(1:24)))
    
    barmap=[1.0 1.0 0.0; 0.0 1.0 0.0];
    colormap(barmap);
    bar(1:24,[b(1:24) res'])
    legend('Optimum','Solution')
else
    disp('No feasible solution found!');
end;

end