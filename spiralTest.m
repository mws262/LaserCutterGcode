clear all; close all;
%Print settings:
speed = 300;
intensity = 255;

%Spiral testing:
currAng = 0;
arcAng = pi/2;
centerX = 60;
centerY = 20; 
res = 0.01;
radInc = 1.2;

radius = 20;
hold on

    x = radius*cos(currAng) + centerX;
    y = radius*sin(currAng) + centerY;
    
    %Get the file going
    fileID = fopen('gcodeTest.gcode','w');
fprintf(fileID,'G21\nG28\n');
fprintf(fileID,'M106 S255\n'); %Fans on full blast
fprintf(fileID,'G1 F%.0f\n',speed);
fprintf(fileID,'M42 P5 S255\n'); %Enable the laser (close interlock circuit)
fprintf(fileID,'M42 P4 S%.0f\n',intensity); %Turn on the laser
fprintf(fileID,'G1 X%.2f Y%.2f\nM400\n',x,y);

for i = 1:18
    
    range = currAng:0.01:arcAng+currAng;

    x = radius*cos(range) + centerX;
    y = radius*sin(range) + centerY;

    fprintf(fileID,'\nG3 X%0.2f Y%0.2f I%0.2f J%0.2f F%0.0f\n',x(end),y(end),centerX,centerY,speed);
    fprintf(fileID,'M400');
    
    plot(x,y);
    plot(centerX,centerY,'*','MarkerSize',20);
    %Update the angle we're now at.
    currAng = currAng + arcAng;
    %Update the new center location.
   
    newdir = [cos(range(end)),sin(range(end))];
    newdir = newdir./norm(newdir);
    newcenter = newdir*radInc+[centerX,centerY];
    centerX = newcenter(1);
    centerY = newcenter(2);
    
    %Now change the radius
    radius = radius - radInc;
    
    
end
hold off

axis equal

%Close the file
fprintf(fileID,'M42 P4 S%.0f\n',0); %Laser off
fprintf(fileID,'M42 P5 S0\n'); %Disable the laser (close interlock circuit)
fprintf(fileID,'M107\n'); %Fans off
fclose(fileID);


