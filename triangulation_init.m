%% This is the second file to launch and it does the triangulation and create the the NuMSV init file

% Here I do the Delanuay Triangulation on the map and room P defined in
% init_map
DT = delaunayTriangulation(P);
%plot the result of the triangulation
triplot(DT);
DT
N = neighbors(DT);
IC = incenter(DT);
hold on
numtri = size(DT,1);
trilabels = arrayfun(@(P) {sprintf('T%d', P)}, (1:numtri)');
Htl = text(IC(:,1),IC(:,2),trilabels,'FontWeight','bold', ...
'HorizontalAlignment','center','Color','blue');
hold off
% Now instead I create the NuSMV file
% I need to pass as input:
% number_area_interest ---> array of indexes of the room
% formula ---> string containing definition of the formula to satisfy (defined in init_map)
% start_config ---> the id of the initial triangle the robot is in 
% N ---> the adjacent graph of the triangulation
% R ---> struct containing the rooms (defined in init_map)
% tr_centers ---> list containing the centers of the triangles of the
% triangulation
s = create_NuSMV_file(4,formula,4,N,R,IC);
file = fopen("numsv_main.smv","wt");
fprintf(file,s);
fclose(file);


%% FROM HERE ONLY UTILITY FUNCTIONS


% this function given an area of interest in the environment, returns a
% string containing the union of triangles ids that are inside the area of
% interest. In triangles we are actually passing the incenter coordinates
% of each triangle
% In particular this was the case of the first trials where I used a
% different process to simulate the robot

function s = inverse_observation_mapping(polygon,triangles)

s = "";
first = 1;
for(i=1:size(triangles,1))
    xq = triangles(i,1);
    yq = triangles(i,2);
    in = inpolygon(xq,yq,polygon(:,1),polygon(:,2));
    if in == 1
        % the triangles is inside the polygon of interest
        if first == 1
            s = s + "robot_1.state = " + i;
            first = 0;
        else
            s = s + " | " + "robot_1.state = " + i;
        end
    end
end
end

% this function given an area of interest in the environment, returns a
% string containing the union of triangles ids that are inside the area of
% interest. In triangles we are actually passing the incenter coordinates
% of each triangle
% In particular this was the case of the second trials where the robot
% definition is is the same main process of the literals transitions

function s = inverse_observation_mapping_2(polygon,triangles)

s = "";
first = 1;
for(i=1:size(triangles,1))
    xq = triangles(i,1);
    yq = triangles(i,2);
    
    % since the triangles will always be completely inside or outside the
    % convex area of interest, it is sufficient to check if the center of
    % the triangle is inside the convex room
    
    in = inpolygon(xq,yq,polygon(:,1),polygon(:,2));
    if in == 1
        % the triangles is inside the polygon of interest
        if first == 1
            s = s + "state = " + i;
            first = 0;
        else
            s = s + " | " + "state = " + i;
        end
    end
end
end

% this function creates the transation in NuMSV from each state(triangles) given
% the dual graph after the triangulation, so having the neighbours
% N is the adjacent graph of the triangulation. Each index i represents one
% triangle of the triangulation and to it is associated an array of 3
% elements which are the ids of the adjacent triangles. It is important to
% notice that some of the triangles on the border of the map only have 2
% neighbours, so in that case in the array we still have 3 elements but nan
% value for non existant neighbours

function s = create_transations(N)
    s =  sprintf("next(state) := case");
    % for each traingle I create the correct transition string
    for(i=1:size(N,1))
        s = s + sprintf("\n\t\t      state = ") + i + " : {"; % I am using 6 blank spaces after last tab
        row = N(i,:);
        row = rmmissing(row);
        for(j=1:length(row))
            n = row(j);
            if isnan(n) == 0
                %so the neighbour is actually defined and it exists
                if j == 1
                    s = s + n;
                else
                    s = s+", " + n;
                end
            end
        end
        s = s + "};";
    end
    s = s + sprintf("\n\t\t    esac;");
end

% this function creates the transitions for the area of interest boolean
% variables. This is the one used in the first trials

function s = create_transitions_pi(number_area_interest,R,triangles)
s = "";
for(i=1:number_area_interest)
    s = s + sprintf("next(pi%i) := case\n\t\t      ",i);
    polygon = R{i};
    s = s + inverse_observation_mapping(polygon,triangles) + sprintf(" : TRUE;\n\t\t      TRUE : FALSE;\n\t\t    esac;\n  ");
end
end

% this function creates the transitions for the area of interest boolean
% variables. This is the one used in the second trials

function s = create_transitions_pi_2(number_area_interest,R,triangles)
s = "";
for(i=1:number_area_interest)
    s = s + sprintf("next(pi%i) := case\n\t\t      ",i);
    polygon = R{i};
    s = s + inverse_observation_mapping_2(polygon,triangles) + sprintf(" : TRUE;\n\t\t      TRUE : FALSE;\n\t\t    esac;\n  ");
end
end

% this is the function that actually creates the NuMSV file given all the
% previously defined functions
% I need to pass as input:
% number_area_interest ---> array of indexes of the room
% formula ---> string containing definition of the formula to satisfy (defined in init_map)
% start_config ---> the id of the initial triangle the robot is in 
% N ---> the adjacent graph of the triangulation
% R ---> struct containing the rooms (defined in init_map)
% tr_centers ---> list containing the centers of the triangles of the
% triangulation

function s = create_NuSMV_file(number_area_interest,formula,start_config,N,R,tr_centers)
s = sprintf("MODULE main\n VAR\n  ");
for(i=1:number_area_interest)
    s = s + sprintf("pi%i : boolean;\n  ",i);
end
% I need to initialize the robot state with start_config
s = s + sprintf("state: 1 .. %i;\nASSIGN\n  init(state) := %i;\n  ",size(N,1),start_config);
% Now I need to initialize the literals boolean values, so I check if the
% starting triangles is inside any room. If start_tr is inside room_i then
% pi_i is set initially to TRUE.
for(i=1:number_area_interest)
    polygon = R{i};
    center_starting_point = tr_centers(start_config,:);
    xq = center_starting_point(1);
    yq = center_starting_point(2);
    in = inpolygon(xq,yq,polygon(:,1),polygon(:,2));
    if in == 1
        s = s + sprintf("init(pi%i) := TRUE;\n  ",i);
    else
        s = s + sprintf("init(pi%i) := FALSE;\n  ",i);
    end
end

% In this case I am using the same process for the literals and robot
% transition
s = s + create_transitions_pi_2(number_area_interest,R,tr_centers);
% I create the transitions for the robot states 
s = s + create_transations(N) + sprintf("\n  ");
% finally i report le formula but with the negation in front
s = s + sprintf("\n LTLSPEC ! ( ") + formula + " )";

end