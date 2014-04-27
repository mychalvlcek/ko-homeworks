% Sports scheduling - round robin tournament
function [xmin,fmin,status,extra,usedData,allMatches] = sport_scheduling(numberOfTeams)
clc;
disp('round robin schedule');
if(nargin ~= 1)
    error('Pass the number of teams as an argument')
end

sense = 1; % sense of optimization: 1=minimization, -1=maximization
n = numberOfTeams; % number of teams
matches = (n-1)*(n/2);
vars = matches*(n-1)*(n/2)*n;

c = ones(1,vars)';% vector c
ctype = []; % constraint type: E =, L <=, G >=
lb = zeros(1,vars)';
ub = ones(1,vars)';
vartype(1:vars) = 'I'; %variable type: C=continuous, I=integer
vartype = vartype';
A = zeros(0,vars);
b = [];

allMatches = nchoosek(1:numberOfTeams,2); % get all possible matches

matchStep = matches*n;

%% each slot has 1 game
for i = 1:matches
    index = (i-1)*matchStep + 1;
    A(i,index:index+matchStep-1) = 1;
    ctype = [ctype;'E'];
    b = [b;1];
end

%% each team plays each other team once
start = 0;
init_row = size(A,1);
for i = 1:matches
    for j = 1:matchStep:vars
        index = j+start;
        A(init_row+i,index:index+n-1)=1;
    end
    ctype = [ctype;'E'];
    b = [b;1];
    start = start+n;
end

%% team i plays once in column m
init_row = size(A,1);
for i = 1:numberOfTeams
    [teamMatches,y] = find(allMatches==i); % matches of given team
    for s = 1:matches
        if(mod(s,n/2) == 1)
            init_row = init_row + 1;
            ctype = [ctype; 'E'];
            b = [b;1];
        end
        startIndex = (s-1)*matchStep;
        for m = 1:size(teamMatches,1)
            from = ((teamMatches(m)-1)*n)+startIndex+1;
            to = from+n-1;
            A(init_row,from:to) = 1;
        end
    end
end

%% referees
start = 0;
init_row = size(A,1);
for i = 1:matches
    for j = 1:matchStep:vars
        index = j+start;
        A(init_row+i,index:index+n-1) = 1;
        A(init_row+i,index-1+allMatches(i,:)) = 0;
    end
    ctype = [ctype;'E'];
    b = [b;1];
    start = start+n;
end
%% referee balancing
init_row = size(A,1)+1;
for t = 1:n
    for i = t:n:vars
        A(init_row,i) = 1;
        A(init_row+1,i) = 1;
    end
    init_row = init_row + 2;
    ctype = [ctype;'L';'G'];
    b = [b;n/2;n/2-1];
end

% ILP solve
%optimization parameters
schoptions=schoptionsset('ilpSolver','glpk','solverVerbosity',2);
%call command for ILP
[xmin,fmin,status,extra] = ilinprog(schoptions,sense,c,A,b,ctype,lb,ub,vartype);
usedData = whos; % get all variables
end