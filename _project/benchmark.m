%% Benchmarking
function benchmark    
    clear all;
    close all;
    clc;
    
    numberOfTeams = 4;

    startTime = tic; % start of timer
    [xmin,fmin,status,extra,usedData,allMatches] = sport_scheduling(numberOfTeams);
    endTime = toc(startTime); % end of timer

    % show the solution
    if(status == 1)
        disp('Solution: '); disp(xmin')
        disp('Matches: '); disp(sum(xmin))
        disp('Objective function: '); disp(fmin)
    else
        disp('No feasible solution found!');
    end;

    % benchmark data
    bytes = 0;
    for i=1:size(usedData)
        bytes = bytes + usedData(i).bytes;
    end
    fprintf('Computing time: %.4f s\n', endTime)
    fprintf('Used memory: %s \n', Bytes2str(bytes))
    
    % print result
    slots = size(allMatches,1);
    slotNumber = 0;  
    for i = 1:size(xmin)
        if(mod(i,slots) == 1)
            slotNumber = slotNumber + 1;
            fprintf('slot: %d\n\t', slotNumber)
        end
        if xmin(i) == 1
            matchIndex = mod(i-1,slots)+1;
            fprintf('%d x %d\n', allMatches(matchIndex,1), allMatches(matchIndex,2));
        end
    end
end

%% returns formatted bytes
% @param NumBytes - number representing bytes of used memory
% @return str - formatted string of bytes
function str = Bytes2str(NumBytes)
scale = floor(log(NumBytes)/log(1024));
switch scale
    case 0
        str = [sprintf('%.0f',NumBytes) ' b'];
    case 1
        str = [sprintf('%.2f',NumBytes/(1024)) ' kb'];
    case 2
        str = [sprintf('%.2f',NumBytes/(1024^2)) ' Mb'];
    case 3
        str = [sprintf('%.2f',NumBytes/(1024^3)) ' Gb'];
    case 4
        str = [sprintf('%.2f',NumBytes/(1024^4)) ' Tb'];
    case -inf
        % Size occasionally returned as zero (eg some Java objects).
        str = 'Not Available';
    otherwise
       str = 'Over a petabyte!!!';
end
end