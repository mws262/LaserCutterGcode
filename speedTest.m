%Laser speed tester -- for discovering speeds for different darknesses.
speedOff = 500;
fileID = fopen('gcodeTest.gcode','w');
fprintf(fileID,'G21\nG28\n');
fprintf(fileID,'M106 S255\n'); %Fans on full blast
fprintf(fileID,'G1 F%.0f\n',speedOff);
fprintf(fileID,'M42 P5 S255\n'); %Enable the laser (close interlock circuit)
LaserOn = 0;

intensityMult = 1;
speedOn = 100
speedInc = 50;

%%% NEW STUFF HERE:


ele = 1;
for ypixel = 1:5:80
    %Left to right one pass
    xpixel = 50;
            %Move to position
            fprintf(fileID,'G1 X%.2f Y%.2f F%.0f\nM400\n',xpixel,ypixel);
            %Turn on laser
            fprintf(fileID,'\nM42 P4 S%.0f\n',255*intensityMult);
            
    xpixel = 100;
            %Move to position
            fprintf(fileID,'G1 X%.2f Y%.2f F%.0f\nM400\n',xpixel,ypixel,speedOn);
            %Turn off laser
            fprintf(fileID,'\nM42 P4 S%.0f\n',0);
    
            speedOn = speedOn+speedInc;
    %Right left pass
            %Move to position
            fprintf(fileID,'G1 X%.2f Y%.2f F%.0f\nM400\n',xpixel,ypixel+2.5);
            %Turn on laser
            fprintf(fileID,'\nM42 P4 S%.0f\n',255*intensityMult);
            
             xpixel = 50;  
             
            %Move to position
            fprintf(fileID,'G1 X%.2f Y%.2f F%.0f\nM400\n',xpixel,ypixel+2.5,speedOn);
            %Turn off laser
            fprintf(fileID,'M42 P4 S%.0f\n',0);
            
            speedOn = speedOn+speedInc

            
            
end

%%%

fprintf(fileID,'M42 P4 S%.0f\n',0);
fprintf(fileID,'M42 P5 S0\n'); %Disable the laser (close interlock circuit)
fprintf(fileID,'M107\n'); %Fans off
fclose(fileID);

Plotter;