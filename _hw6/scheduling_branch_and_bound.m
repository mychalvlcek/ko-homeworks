function scheduling_branch_and_bound
clc;
global tasks;
p = [2 1 2 2]; % processing time
r = [4 1 1 0]; % release time
d = [7 5 6 4]; % deadline

tasks = [p;r;d];

[time, solution] = bratley(0, [], inf, [])
end

function [solutionTime, solutionTasks] = bratley(actualTime, usedTasks, solutionTime, solutionTasks)
    global tasks;
    fprintf('========= ======== =========\n', size(usedTasks,2))
    usedTasks
    if size(usedTasks,2) == size(tasks,2)
        disp('=== solution found! ===');
        solutionTasks = usedTasks;
        solutionTime = actualTime
        disp('end of call - return');
        return
    end
    
    tmpUsedTasks = usedTasks;
    tmpTime = actualTime;
    
    for i = 1:size(tasks,2)
        usedTasks = tmpUsedTasks;
        actualTime = tmpTime;
        fprintf('========= DEPTH[%d] =========\n', size(usedTasks,2))
        fprintf('DEPTH[%d] for i = %d\n', size(usedTasks,2), i)
        if ismember(i,usedTasks) == 0
            newTime = max(actualTime,tasks(2,i)) + tasks(1,i);
            fprintf('time = %d\n', actualTime)
            fprintf('newTime = %d\n', newTime)

            % check - if actual time exceeded max deadline
            if newTime > tasks(3,i)
                disp('[ERR] - deadline of choosed task exceeded');
                disp('[PRUNE]');
                continue;
            end
            % check - if actual time isnt worst then founded solution
            if newTime >= solutionTime
                fprintf('[ERR] - worst/not better (%d) than already founded solution (%d)\n', newTime, solutionTime)
                disp('[PRUNE]');
                continue;
            end
            % check - if is exceeded deadline of some remaining tasks
            prune = 0;
            for j = 1:size(tasks,2)
                if i ~= j && ismember(j,usedTasks) == 0
                    if newTime >= tasks(3,j)
                        fprintf('[ERR] - deadline %d of remaining task %d exceeded (time = %d) \n',tasks(3,j), j, newTime)
                        prune = 1;
                        break;
                    end
                end
            end
            if prune == 1
                disp('[PRUNE]');
                continue;
            end
            
            actualTime = newTime;

            disp('zanoreni');
            usedTasks = [usedTasks i];
            [solutionTime, solutionTasks] = bratley(actualTime, usedTasks, solutionTime, solutionTasks);
        end
    end
    disp('end of call');
end