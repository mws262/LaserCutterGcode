clc
clear all
close all

% X = 198, Y = 4mm is far corner of print, y = 100 is max

ymin = 4;
ymax = 95;
xmax = 198

desiredLength = 80; %desired engraving length in mm
resolution = 0.1; %Attempted resolution in mm
speed = 1000; %movement speed in mm/min
minThresh = 0; %minimum darkness worth turning the laser on for 
beamWidth = 0.2; %Guess of laser beam width in mm
beamPixels = beamWidth/resolution;
intensityMult = .5;

xoffset = 0; %How much upper left corner of print is offset from the origin.
yoffset = 0;
xoffset2 = 100; %How much upper left corner of print is offset from the origin.
yoffset2 = 0;
% pic = imread('gears.png');
pic = rgb2gray(imread('sphere.png')); %Read image, convert to grayscale

Z = pic;
X = 1:size(pic,1);
Y = 1:size(pic,2);

[x,y] = meshgrid(X,Y);

xnew = x(Z~=0);
ynew = y(Z~=0);
znew = Z(Z~=0);

faces = delaunay(xnew,ynew);
vertices = [xnew(:) ynew(:) znew(:)];

faces = [faces;faces];
vertices = [vertices;xnew(:),ynew(:),zeros(size(znew(:)))];


stlwrite('test.stl',X,Y,Z,'mode','ascii');
hMesh = patch('vertices', vertices,'faces', faces,'facecolor', 'blue','FaceAlpha',0.5);

% Z = reshape(pic,[numel(pic),1]);
% Y = repmat((1:size(pic,2))',[size(pic,1) 1]);
% X = repmat((1:size(pic,1))',[size(pic,2) 1]);