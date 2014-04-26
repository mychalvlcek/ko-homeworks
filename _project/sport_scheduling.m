% Sports scheduling - round robin tournament
% Example:
% no. of teams = 8
% ----------------
% no. of matches = 7 x 4 = 28
function [xmin,fmin,status,extra,usedData,allMatches] = sport_scheduling(numberOfTeams)
clc;
disp('round robin schedule');
if(nargin ~= 1)
    error('Pass the number of teams as an argument')
end

sense = 1; % sense of optimization: 1=minimization, -1=maximization
n = numberOfTeams; % number of teams
matches = (n-1)*(n/2);
vars = matches*matches;
b = [];

c = ones(1,vars)';% vector c
ctype(1:6) = 'E'; % constraint type: E =, L <=, G >=
ctype = [];
lb = zeros(1,vars)';
ub = ones(1,vars)';
vartype(1:vars) = 'I'; %variable type: C=continuous, I=integer
vartype = vartype';
A = [];

allMatches = nchoosek(1:numberOfTeams,2) % get all possible matches

%% each slot has 1 game
for i = 1:matches
    index = (i-1)*matches + 1;
    A(i,index:index+matches-1) = 1;
    ctype = [ctype;'E'];
    b = [b;1];
end

%% each team plays each other team once
start = 0;
row = size(A,1);
for i = 1:matches
    tmp_row = zeros(1,vars);
    for j = 1:matches:vars
        A(i+row,j+start)=1;
    end
    ctype = [ctype;'E'];
    b = [b;1];
    start = start +1;
end

%% team i plays once in column m
row = size(A,1);
for i = 1:numberOfTeams
    [teamMatches,y] = find(allMatches==i); % matches of given team
    for s = 1:matches
        if(mod(s,n/2) == 1)
            row = row + 1;
            ctype = [ctype; 'E'];
            b = [b;1];
        end
        startIndex = (s-1)*matches;
        A(row,teamMatches+startIndex) = 1;

    end
end

% ILP solve
%optimization parameters
schoptions=schoptionsset('ilpSolver','glpk','solverVerbosity',2);
%call command for ILP
[xmin,fmin,status,extra] = ilinprog(schoptions,sense,c,A,b,ctype,lb,ub,vartype);
usedData = whos; % get all variables
end