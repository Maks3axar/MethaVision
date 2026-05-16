%% Double Sphere Union & Shadow App
% The script models, rotates, and analyzes the 3D geometry and horizontal shadow projections of two overlapping spheres (i.e. diplococcus). This tool simulates morphological variations in dividing or budding microbial cells.

% Features
% Dual-Axes Interactive UI: Displays a 3D geometric render alongside a real-time plot tracking shadow area variations across tilt angles ($\theta = 0^\circ \text{ to } 180^\circ$).
% Microbial Morphology Scaling: Dynamic sliders to adjust cell radius ($R$) and the center-to-center distance ($d$) to visualize either separate cells or an overlapping cell union.
% Orientation Controls: Interactive sliders for tilt angle ($\theta$) and azimuth rotation ($\phi$) implemented via 3D coordinate transformation matrices.
% Hybrid Shadow Analysis: Implements a binary matrix mask projection technique (`bwboundaries`) to display the overlapping shadow on a base plane ($Z = -4$), providing both exact analytical and pixel-counting numerical area metrics.
% Volumetric Metrics: Instantly calculates the total combined surface area and volume of the single or intersecting double-sphere union.

% Developer: Dr. Maksim Zakhartsev (C1BioEngineering, Moscow, Russia)
% Release Date: 20.02.2026

%% 
function double_sphere_union_advanced()

fig = uifigure('Name','Union of Two Spheres','Position',[100 100 1300 720]);

ax = uiaxes(fig,'Position',[40 150 650 550]);
view(ax,3)
grid(ax,'on')
axis(ax,'equal')
xlabel(ax,'X [\mum]')
ylabel(ax,'Y [\mum]')
zlabel(ax,'Z [\mum]')

ax2 = uiaxes(fig,'Position',[720 350 550 300]);
title(ax2,'Shadow Area vs Tilt Angle θ')
xlabel(ax2,'Tilt angle θ [°]')
ylabel(ax2,'A(\theta) [\mum^2]')
grid(ax2,'on')

%% controls
lbl_R = uilabel(fig,'Position',[720 300 200 20],'Text','Cell radius R = 0.75 [μm]');
% slider_R = uislider(fig,'Position',[720 290 200 3],'Limits',[0.5 2],'Value',1,'ValueChangedFcn',@updatePlot);
slider_R = uislider(fig,...
    'Position',[750 290 140 3],...
    'Limits',[0.5 2],...
    'Value',0.6242,...
    'ValueChangedFcn',@updatePlot);

btn_R_minus = uibutton(fig,...
    'Text','–',...
    'Position',[720 280 25 25],...
    'ButtonPushedFcn',@(btn,event) stepSlider(slider_R,-0.05));

btn_R_plus = uibutton(fig,...
    'Text','+',...
    'Position',[900 280 25 25],...
    'ButtonPushedFcn',@(btn,event) stepSlider(slider_R,0.05));

lbl_d = uilabel(fig,'Position',[720 250 200 20],'Text','Center distance d = 2.00 [μm]');
% slider_d = uislider(fig,'Position',[720 240 200 3],'Limits',[0 4],'Value',1,'ValueChangedFcn',@updatePlot);
slider_d = uislider(fig,...
    'Position',[750 240 140 3],...
    'Limits',[0 3],...
    'Value',1.1678,...
    'ValueChangedFcn',@updatePlot);

btn_d_minus = uibutton(fig,...
    'Text','–',...
    'Position',[720 230 25 25],...
    'ButtonPushedFcn',@(btn,event) stepSlider(slider_d,-0.1));

btn_d_plus = uibutton(fig,...
    'Text','+',...
    'Position',[900 230 25 25],...
    'ButtonPushedFcn',@(btn,event) stepSlider(slider_d,0.1));

lbl_theta = uilabel(fig,'Position',[720 200 200 20],'Text','Tilt angle θ = 0°');
% slider_angle = uislider(fig,'Position',[720 190 200 3],'Limits',[0 90],'Value',0,'ValueChangedFcn',@updatePlot);
slider_angle = uislider(fig,...
    'Position',[750 190 140 3],...
    'Limits',[0 90],...
    'Value',0,...
    'ValueChangedFcn',@updatePlot);

btn_angle_minus = uibutton(fig,...
    'Text','–',...
    'Position',[720 180 25 25],...
    'ButtonPushedFcn',@(btn,event) stepSlider(slider_angle,-1));

btn_angle_plus = uibutton(fig,...
    'Text','+',...
    'Position',[900 180 25 25],...
    'ButtonPushedFcn',@(btn,event) stepSlider(slider_angle,1));

shadowLabel = uilabel(fig,'Position',[950 290 300 25]);
shadowNumLabel = uilabel(fig,'Position',[950 260 300 25]);
surfaceLabel = uilabel(fig,'Position',[950 230 300 25]);
volumeLabel = uilabel(fig,'Position',[950 200 300 25]);

updatePlot()

%% ===========================
function updatePlot(~,~)

cla(ax)

R = slider_R.Value;
d = slider_d.Value;
theta = deg2rad(slider_angle.Value);

% Обновление заголовков слайдеров с текущими значениями
        lbl_R.Text = sprintf('Cell radius R = %.2f [μm]', R);
        lbl_d.Text = sprintf('Center distance d = %.2f [μm]', d);
        lbl_theta.Text = sprintf('Tilt angle θ = %.0f°', rad2deg(theta));

%% centers
C1 = [-d/2 0 0]';
C2 = [ d/2 0 0]';

Ry = [cos(theta) 0 sin(theta);
      0 1 0;
     -sin(theta) 0 cos(theta)];

C1 = Ry*C1;
C2 = Ry*C2;

%% draw spheres
[u,v] = meshgrid(linspace(0,2*pi,60),linspace(0,pi,40));
xs = R*sin(v).*cos(u);
ys = R*sin(v).*sin(u);
zs = R*cos(v);

surf(ax,xs+C1(1),ys+C1(2),zs+C1(3),'EdgeColor','none','FaceAlpha',0.9);
hold(ax,'on')
surf(ax,xs+C2(1),ys+C2(2),zs+C2(3),'EdgeColor','none','FaceAlpha',0.9);

%% projection plane
planeZ=-3;
[Xp,Yp]=meshgrid(linspace(-4,4,2));
surf(ax,Xp,Yp,planeZ*ones(size(Xp)),'FaceAlpha',0.3,'EdgeColor','none')

%% analytic shadow area

d_proj = abs(d*cos(theta));

if d_proj>=2*R
A_shadow=2*pi*R^2;
else
overlap = 2*R^2*acos(d_proj/(2*R)) - 0.5*d_proj*sqrt(4*R^2-d_proj^2);
A_shadow = 2*pi*R^2 - overlap;
end

%% raster shadow area + visualization

res=500;
x=linspace(-3,3,res);
y=linspace(-3,3,res);
[X,Y]=meshgrid(x,y);

mask1 = (X-C1(1)).^2+(Y-C1(2)).^2<=R^2;
mask2 = (X-C2(1)).^2+(Y-C2(2)).^2<=R^2;
mask = mask1 | mask2;

dx=x(2)-x(1);
A_num = sum(mask(:))*dx*dx;

% --- Визуализация тени как единого полигона ---
B = bwboundaries(mask);

for k = 1:length(B)
    boundary = B{k};
    xb = x(boundary(:,2));
    yb = y(boundary(:,1));
    zb = planeZ * ones(size(xb));

    patch(ax, xb, yb, zb, ...
        'k', ...
        'FaceAlpha', 0.35, ...
        'EdgeColor', 'none');
end

%% surface area

if d>=2*R
A_surface=8*pi*R^2;
else
A_surface=4*pi*R^2 + 2*pi*R*d;
end

%% volume

if d>=2*R
V_union = 2*(4/3*pi*R^3);
else
V_int = pi*(4*R+d)*(2*R-d)^2/12;
V_union = 2*(4/3*pi*R^3)-V_int;
end

%% labels

shadowLabel.Text=sprintf('Shadow area (analytic): %.4f μm^2',A_shadow);
shadowNumLabel.Text=sprintf('Shadow area (numeric): %.4f μm^2',A_num);
surfaceLabel.Text=sprintf('Surface area: %.4f μm^2',A_surface);
volumeLabel.Text=sprintf('Volume union: %.4f μm^3',V_union);

%% plot A(theta)

theta_vec=linspace(0,90,200);
A=zeros(size(theta_vec));

for i=1:length(theta_vec)
th=deg2rad(theta_vec(i));
dproj=d*cos(th);

if dproj>=2*R
A(i)=2*pi*R^2;
else
overlap=2*R^2*acos(dproj/(2*R))-0.5*dproj*sqrt(4*R^2-dproj^2);
A(i)=2*pi*R^2-overlap;
end
end

plot(ax2,theta_vec,A,'LineWidth',2)

hold(ax,'off')

end

function stepSlider(slider, step)

    newVal = slider.Value + step;
    
    % ограничение диапазона
    newVal = max(slider.Limits(1), newVal);
    newVal = min(slider.Limits(2), newVal);
    
    slider.Value = newVal;
    
    % вызвать обновление
    slider.ValueChangedFcn();
end

end
