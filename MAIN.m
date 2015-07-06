% This is the speedy version of the script which converts images to gcode
% for my laser etcher. This version does NOT vary laser intensity. Rather,
% it cranks the power up to max and moves at a faster speed - 1 speed for
% movement, another for etching.
%
%
% Matthew Sheen

clc
clear all
close all

% X = 198, Y = 4mm is far corner of print, y = 100 is max
xmin = 0;
ymin = 0;
ymax = 95;
xmax = 150;

resizeIt = true;
desiredLength = 90; %desired engraving length in mm
resolution = 0.1; %Attempted resolution in mm
speedOff = 1000*3; %movement speed when laser is off in mm/min
speedOn = 200*3; %movement speed when laser is on in mm/min

minThresh = 30; %minimum darkness worth turning the laser on for 
beamWidth = 0.1; %Guess of laser beam width in mm
beamPixels = beamWidth/resolution;
intensityMult = 1;

xoffset = 0; %How much upper left corner of print is offset from the origin.
yoffset = 0;
% xoffset2 = 100; %How much upper left corner of print is offset from the origin.
% yoffset2 = 0;

% pic = rgb2gray(imread('fractal4.png')); %Read image, convert to grayscale
pic = imread('swirl.png');
%FLIP IMAGE?
pic = fliplr(pic);
if(resizeIt)
pixelLength = desiredLength/resolution;

actualLength = size(pic,2);
scaling = pixelLength/actualLength; %Scale the image such that each pixel represents the minimum movement for the defined scale
resizedPic = imresize(pic, scaling);
else
    resizedPic = pic;
end
[ysize,xsize] = size(resizedPic) %Rescaled pixel dimensions of the image.

yborder = 5;
yoffset2 = (ymax-ymin)/2 + ymin-resolution*ysize/2 + yborder;
xborder = 10;
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
fprintf(fileID,'G1 F%.0f\n',speedOff);
fprintf(fileID,'M42 P5 S255\n'); %Enable the laser (close interlock circuit)
LaserOn = 0;

%%% NEW STUFF HERE:

onPts = zeros(numel(resizedPic),2);
ele = 1;
for ypixel = yoffset:beamPixels:ysize+yoffset-beamPixels-1
    %Left to right one pass
    for xpixel = xoffset:xsize+xoffset-1
        intensity = inversepic(ypixel-yoffset+1,xpixel-xoffset+1);
        
        if (intensity>minThresh) && (LaserOn==0) %Laser should be on, and isn't. Go to position and turn it on.
            %Move to position
            fprintf(fileID,'G1 X%.2f Y%.2f F%.0f\nM400\n',resolution*xpixel+xoffset2,resolution*ypixel+yoffset2,speedOff);
            %Turn on laser
            fprintf(fileID,'M42 P4 S%.0f\n',255*intensityMult);
            LaserOn = 1;
            
        elseif (intensity<minThresh) && (LaserOn==1) %Laser is on, and shouldn't. Go to position-1, then turn it off.
            %Move to position
            fprintf(fileID,'G1 X%.2f Y%.2f F%.0f\nM400\n',resolution*(xpixel-1)+xoffset2,resolution*ypixel+yoffset2,speedOn);
            %Turn on laser
            fprintf(fileID,'M42 P4 S%.0f\n',0);
           LaserOn = 0; 
        elseif (intensity>minThresh)
        onPts(ele,:) = [resolution*xpixel+xoffset2,resolution*ypixel+yoffset2];
        ele = ele+1;
        end
    end
    
    fprintf(fileID,'M42 P4 S%.0f\n',0);
    ypixel = ypixel+beamPixels; %Go down one row
    
      %Go right to left one pass 
    for xpixel = xsize+xoffset-1:-1:xoffset
        intensity = inversepic(ypixel-yoffset+1,xpixel-xoffset+1);
        if (intensity>minThresh) && (LaserOn==0) %Laser should be on, and isn't. Go to position and turn it on.
            %Move to position
            fprintf(fileID,'G1 X%.2f Y%.2f F%.0f\nM400\n',resolution*xpixel+xoffset2,resolution*ypixel+yoffset2,speedOff);
            %Turn on laser
            fprintf(fileID,'M42 P4 S%.0f\n',255*intensityMult);
            LaserOn = 1;
            
        elseif (intensity<minThresh) && (LaserOn==1) %Laser is on, and shouldn't. Go to position-1, then turn it off.
            %Move to position
            fprintf(fileID,'G1 X%.2f Y%.2f F%.0f\nM400\n',resolution*(xpixel-1)+xoffset2,resolution*ypixel+yoffset2,speedOn);
            %Turn on laser
            fprintf(fileID,'M42 P4 S%.0f\n',0);
           LaserOn = 0; 
        elseif (intensity>minThresh)
        onPts(ele,:) = [resolution*xpixel+xoffset2,resolution*ypixel+yoffset2];
        ele = ele+1;
        end
    end
    
end

%%%

fprintf(fileID,'M42 P4 S%.0f\n',0);
fprintf(fileID,'M42 P5 S0\n'); %Disable the laser (close interlock circuit)
fprintf(fileID,'M107\n'); %Fans off
fclose(fileID);

Plotter;