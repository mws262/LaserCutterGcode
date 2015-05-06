clc
clear all
close all

% X = 198, Y = 4mm is far corner of print, y = 100 is max

ymin = 4;
ymax = 95;
xmax = 198

desiredLength = 100; %desired engraving length in mm
resolution = 0.1; %Attempted resolution in mm
speed = 1000; %movement speed in mm/min
minThresh = 30; %minimum darkness worth turning the laser on for 
beamWidth = 0.2; %Guess of laser beam width in mm
beamPixels = beamWidth/resolution;
intensityMult = 0.4;

xoffset = 0; %How much upper left corner of print is offset from the origin.
yoffset = 0;
% xoffset2 = 100; %How much upper left corner of print is offset from the origin.
% yoffset2 = 0;

pic = rgb2gray(imread('lasersharks2.png')); %Read image, convert to grayscale

%FLIP IMAGE?
pic = fliplr(pic)';

pixelLength = desiredLength/resolution;
actualLength = size(pic,2);
scaling = pixelLength/actualLength; %Scale the image such that each pixel represents the minimum movement for the defined scale
resizedPic = imresize(pic, scaling);

[ysize,xsize] = size(resizedPic) %Rescaled pixel dimensions of the image.

yborder = 5;
yoffset2 = (ymax-ymin)/2 + ymin-resolution*ysize/2 + yborder;
xborder = 80;
xoffset2 = xmax-xborder-resolution*xsize;

image(resizedPic)
axis equal
colormap bone

inversepic = imcomplement(resizedPic); %Invert the picture so that 255 means DARK, and 1 means LIGHT

figure
image(inversepic)
axis equal
colormap gray

fileID = fopen('gcodeTest.gcode','w');
fprintf(fileID,'G21\nG28\n');
fprintf(fileID,'M106 S255\n'); %Fans on full blast
fprintf(fileID,'G1 F%.0f\n',speed);
fprintf(fileID,'M42 P5 S255\n'); %Enable the laser (close interlock circuit)
LaserOn = 0;
for ypixel = yoffset:beamPixels:ysize+yoffset-beamPixels-1 %march through row by row
    %  each cycle consists of a left-to-right followed by a right-to-left.
    %  This is more efficient than resetting left-to-right each time
    
      %Go left to right one pass
    for xpixel = xoffset:xsize+xoffset-1
        intensity = inversepic(ypixel-yoffset+1,xpixel-xoffset+1);
        if intensity>minThresh
            fprintf(fileID,'G1 X%.2f Y%.2f\nM400\n',resolution*xpixel+xoffset2,resolution*ypixel+yoffset2);
            if LaserOn == 0
                %fprintf(fileID,'M42 P5 S255\n'); %Enable the laser (close interlock circuit)
                LaserOn = 1;
            end
            fprintf(fileID,'M42 P4 S%.0f\n',intensity*intensityMult);
        else
            if LaserOn ~= 0
                fprintf(fileID,'M42 P4 S%.0f\n',0);
                %fprintf(fileID,'M42 P5 S0\n'); %disable the laser (close interlock circuit)
                LaserOn = 0;
            end
        end
    end
    
    fprintf(fileID,'M42 P4 S%.0f\n',0);
    ypixel = ypixel+beamPixels; %Go down one row
    
         %Go right to left one pass 
    for xpixel = xsize+xoffset-1:-1:xoffset
        intensity = inversepic(ypixel-yoffset+1,xpixel-xoffset+1);
        if intensity>minThresh
            fprintf(fileID,'G1 X%.2f Y%.2f\nM400\n',resolution*xpixel+xoffset2,resolution*ypixel+yoffset2);
            if LaserOn == 0
               % fprintf(fileID,'M42 P5 S255\n'); %Enable the laser (close interlock circuit)
                LaserOn = 1;
            end
            fprintf(fileID,'M42 P4 S%.0f\n',intensity*intensityMult);
            LaserOn = 1;
        else
            if LaserOn ~= 0
                fprintf(fileID,'M42 P4 S%.0f\n',0);
                %fprintf(fileID,'M42 P5 S0\n'); %disable the laser (close interlock circuit)
                LaserOn = 0;
            end
        end
    end
    fprintf(fileID,'M42 P4 S%.0f\n',0);
    LaserOn = 0;
    %fprintf(fileID,'M42 P5 S0\n'); %disable the laser (close interlock circuit)
end

fprintf(fileID,'M42 P4 S%.0f\n',0);
fprintf(fileID,'M42 P5 S0\n'); %Disable the laser (close interlock circuit)
fprintf(fileID,'M107\n'); %Fans off
fclose(fileID);