
fig = figure;
hold on
%Plot the entire limits:
xa = [0 150 150 0];
ya = [0 0 95 95];
za = [0 0 0 0];

patch(xa,ya,za,'red','FaceAlpha',0.2);

%Plot the acceptable print area based on settings:
xb = [xmin,xmax,xmax,xmin];
yb = [ymin,ymin,ymax,ymax];
zb = [0 0 0 0];
patch(xb,yb,zb,'blue','FaceAlpha',0.5);



plot(onPts(:,1),onPts(:,2),'.k');

hold off
axis equal
view(3)