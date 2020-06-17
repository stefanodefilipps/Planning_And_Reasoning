clear all
close all

%% This is the first file to launch and generates the map with the specified rooms and the particular formula to satisfy

% First case ---> 4 rooms and in order I want to visit in order r4 r2  r3
% and afterwards straight to r1
% boundaries of the map
map = [0,0;0,10;10,10;10,0];
%rooms
r1 = [2,6;2,8;4,8;4,6];
r2 = [6,6;6,8;8,8;8,6];
r3 = [2,2;2,4;4,4];
r4 = [6,2;6,4;8,4;8,2];
% the formula says see in order pi2 pi3 and pi4 and go back to pi while
% avoiding pi2 and pi3
formula = "F ( pi2 & F ( pi3 & F ( pi4 & F ( pi1 ) ) ) )";
%Rooms
R = {r1,r2,r3,r4};
P = [map;r1;r2;r3;r4];
disp = display_map(map,R);

% Second Case ---> 6 rooms and in order I want to visit in order r4 r3 r2
% r1 while always avoiding r5 and r6 
% boundaries of the map
% map = [0,0;0,10;10,10;10,0];
% %rooms
% r1 = [2,6;2,8;4,8;4,6];
% r2 = [6,6;6,8;8,8;8,6];
% r3 = [2,2;2,4;4,4];
% r4 = [6,2;6,4;8,4;8,2];
% r5 = [4,4;4,6;5,6;5,4];
% r6 = [5,2;5,4;6,4;6,2];
% formula = "G ( ! pi5 & ! pi6 ) & ( F ( pi4 & F ( pi3 & F ( pi2 & F pi1 ) ) ) )";
% %Rooms
% R = {r1,r2,r3,r4,r5,r6};
% P = [map;r1;r2;r3;r4;r5;r6];
% disp = display_map(map,R);

% % Third Case ---> 6 rooms and in order I want to reach r3 while avoiding r5
% % r6 r4
% % boundaries of the map
% map = [0,0;0,10;10,10;10,0];
% %rooms
% r1 = [2,6;2,8;4,8;4,6];
% r2 = [6,6;6,8;8,8;8,6];
% r3 = [2,2;2,4;4,4];
% r4 = [6,2;6,4;8,4;8,2];
% r5 = [4,4;4,6;5,6;5,4];
% r6 = [5,2;5,4;6,4;6,2];
% formula = "( ! pi5 & ! pi6 & !pi4 ) U pi3";
% %Rooms
% R = {r1,r2,r3,r4,r5,r6};
% P = [map;r1;r2;r3;r4;r5;r6];
% disp = display_map(map,R);

% This function is simply used to dispaly the map with the room in red

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