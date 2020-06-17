%% This is the final script to launch in order to plot result and smooth the path

f = fopen("/home/stefano/planning_reasoning/output.txt");
states = [];
l = fgetl(f);
% From the output file of the NuMSV file I only take the state variables of
% the robot
while ischar(l)
    if contains(l,"state") == 1
        splitted = split(l," ");
        states(end+1) = str2num(splitted{end});
    end
    l = fgetl(f);
end

% I need the coordinates of the passed traingles centers for the plot
passed_incenters = zeros(length(states),2);
DT = delaunayTriangulation(P);
%triplot(DT);
N = neighbors(DT);
IC = incenter(DT);
for(i=1:length(states))
    passed_incenters(i,:) = IC(states(i),:); 
end
% I get the new states(triangles) passed by the robot after the smoothing
% procedure
new_states = post_smoothing(states,R,IC)
% I need the coordinates of the passed traingles centers after smoothing for the plot
new_passed_incenters = zeros(length(new_states),2);
for(i=1:length(new_states))
    new_passed_incenters(i,:) = IC(new_states(i),:); 
end

%plot pre-smoothing

nexttile
disp = display_map(map,R)
numtri = size(DT,1);
trilabels = arrayfun(@(P) {sprintf('T%d', P)}, (1:numtri)');
Htl = text(IC(:,1),IC(:,2),trilabels,'FontWeight','bold', ...
'HorizontalAlignment','center','Color','blue');
hold on
plot(passed_incenters(:,1),passed_incenters(:,2));
%hold off

%plot smoothed path

nexttile
disp = display_map(map,R);
numtri = size(DT,1);
trilabels = arrayfun(@(P) {sprintf('T%d', P)}, (1:numtri)');
Htl = text(IC(:,1),IC(:,2),trilabels,'FontWeight','bold', ...
'HorizontalAlignment','center','Color','blue');
hold on
plot(new_passed_incenters(:,1),new_passed_incenters(:,2));

%% UTILITY FUNCTIONS

% This is the function that operates the post smoothing procedure
% The inputs are 
% states ---> list containing the id of the triangles passed by the robot
% in the NuMSV counterexample
% rooms ---> list containint the map rooms
% IC ---> list containing the coordinates of the traingles centers

function new_states = post_smoothing(states,rooms,IC)
new_states = [states(1)];
i = 1;
% keep cycling untill we are not exceeding the states array length
% i is the index in the states array that represents the current triangle
% we are interested in
while i < length(states)
    states(i);
    IC_i = IC(states(i),:);
    % j represents the current successor of state i that we are analyizing
    % ate the start j will be the direct successor of i 
    j = i+1;
    successor = j;
    % safe is a flag that tells us if the oreviously ckecked state was not
    % inside an obstacles and so we can keep checking other suitable
    % successors
    safe = 1;
    % stopped is a flag that tell us if with the previously checkde room we
    % just landed in an allowed room but then i need to stop the search,
    % otherwise I might miss that particular room that might have been a
    % goal of the formula
    stopped = 0;
    % Until it is safe and I don't need to stop and I didn't exceed the
    % state array keep searching for a suitable successor
    while safe == 1 && stopped == 0 && j < length(states)
        next = states(j);
        IC_next = IC(next,:);
        temp_succ = -1;
        % for each room I need to do some checks
        for(r=1:length(rooms))
            room = rooms{r};
            pol = polyshape(room(:,1),room(:,2));
            % I take the line between the starting state and the current
            % possible successor
            line = [IC_i(1) IC_i(2); IC_next(1) IC_next(2)];
            % I find the intersection between this line and the current
            % room
            [in,out] = intersect(pol,line);
            if isempty(in) == 0
                % If the line is intersecting a room but neither the
                % starting state and the current possible successor is
                % inside this room then it means that I am passing through
                % an obstacle and the current candidate is not valid and
                % therefore the safe flag is set to 0
                if inpolygon(IC_next(1),IC_next(2),room(:,1),room(:,2)) == 0 && inpolygon(IC_i(1),IC_i(2),room(:,1),room(:,2)) == 0
                    safe = 0;
                end
                % if either one of the 2 states is inside the room,
                % instead, the safe flag is not set and I have 2 cases to
                % consider
                % if the state inside the room is the starting state then I
                % keep checking suitable successors since I am not inside
                % an obstacle
                % If the state inside the room is instead the current
                % suitable candidate then The current candidate is ok but i
                % need to stop the search otherwise I might miss the
                % passage through this room and so i set the flag stopped
                if inpolygon(IC_next(1),IC_next(2),room(:,1),room(:,2)) == 1
                    stopped = 1;
                end
            end
        end
        % After cycling through each room in the map, I need to set the
        % current possible successor. So, I check if the safe flag has been
        % kept to 1 and set as successor the j-th state and increment the j
        % variable to check other suitable candidates further in the states
        % array.
        if safe == 1
            successor = j;
            j = j + 1;
        end
    end
    % If I exit the while cycle then either safe or stop flags have been
    % changed(or i exceeded the states array) and so I put as the new
    % successor state the last safe candidate and start again the search
    % from this new successor
    new_states(end+1) = states(successor);
    i = successor;
end
end

function disp = display_map(map,R)
disp = 1;
patch(map(:,1),map(:,2),"white");
hold on
for(i=1:length(R))
    r = R{i};
    patch(r(:,1),r(:,2),"red");
    hold on
end
end