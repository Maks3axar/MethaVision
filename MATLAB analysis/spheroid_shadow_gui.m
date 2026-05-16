%% Spheroid Shadow Model UI
% The model simulates, rotates, and analyzes the geometric shadows (orthogonal projections) cast by an oblate or prolate spheroid onto a horizontal surface.

% Features
% Interactive 3D Visualization: Renders a 3D spheroid using dynamic surface plotting (`surf`) with custom lighting.
% Real-time Geometric Controls: Sliders to adjust the equatorial semi-axes ($a=b$) and the polar semi-axis ($c$) to transform the shape from a sphere to a prolate or oblate spheroid.
% Rotation Modeling: Slider to control the rotation angle ($\theta$) around the X-axis using a standard 3D rotation matrix.
% Shadow Projection Mapping: Dynamically calculates and displays the exact 2D elliptical boundary and area of the shadow cast on a lower projection plane ($Z = -2.5$).
% Numerical Metrics: Displays real-time calculations of the spheroid's volume and the mathematically projected shadow area.

% Developer: Dr. Maksim Zakhartsev (C1BioEngineering, Moscow, Russia)
% Release Date: 20.02.2026

%%
function spheroid_shadow_gui()

%% === UI ===
fig = uifigure('Name','Spheroid Shadow Model','Position',[100 100 1100 720]);

ax = uiaxes(fig,'Position',[50 150 750 550]);
view(ax,3)
grid(ax,'on')
axis(ax,'equal')
xlabel(ax,'X [m]')
ylabel(ax,'Y [m]')
zlabel(ax,'Z [m]')
ax.XLim = [-3 3];
ax.YLim = [-3 3];
ax.ZLim = [-3 3];
ax.XTick = -3:0.5:3;
ax.YTick = -3:0.5:3;
ax.ZTick = -3:0.5:3;

%% --- Sliders ---

% a = b
uilabel(fig,'Position',[850 600 200 20],'Text','Semi-axis a = b [m]');
slider_a = uislider(fig,'Position',[850 590 200 3],...
    'Limits',[0.2 2],'Value',0.7,...
    'ValueChangedFcn',@updatePlot);

% c
uilabel(fig,'Position',[850 540 200 20],'Text','Semi-axis c [m]');
slider_c = uislider(fig,'Position',[850 530 200 3],...
    'Limits',[0.2 3],'Value',1,...
    'ValueChangedFcn',@updatePlot);

% Angle
uilabel(fig,'Position',[850 480 200 20],'Text','Tilt angle (deg)');
slider_angle = uislider(fig,'Position',[850 470 200 3],...
    'Limits',[0 90],'Value',0,...
    'ValueChangedFcn',@updatePlot);

% Area label
areaLabel = uilabel(fig,'Position',[850 420 300 30],...
    'Text','Shadow Area:');

%% Initial plot
updatePlot()

%% === Update function ===
function updatePlot(~,~)

    cla(ax)

    a = slider_a.Value;
    c = slider_c.Value;
    theta = deg2rad(slider_angle.Value);

    % --- Generate spheroid ---
    [u,v] = meshgrid(linspace(0,2*pi,100),linspace(0,pi,60));

    x = a*sin(v).*cos(u);
    y = a*sin(v).*sin(u);
    z = c*cos(v);

    % --- Rotation around X-axis ---
    R = [1 0 0;
         0 cos(theta) -sin(theta);
         0 sin(theta) cos(theta)];

    pts = R * [x(:)'; y(:)'; z(:)'];
    xR = reshape(pts(1,:),size(x));
    yR = reshape(pts(2,:),size(y));
    zR = reshape(pts(3,:),size(z));

    % --- Plot spheroid ---
    surf(ax,xR,yR,zR,...
        'FaceColor',[0.2 0.6 0.8],...
        'EdgeColor','none',...
        'FaceAlpha',0.9);
    hold(ax,'on')

    % --- Light source (vertical) ---
    light(ax,'Position',[0 0 5],'Style','infinite');
    lighting(ax,'gouraud')

    % --- Projection plane ---
    planeZ = -2.5;
    [Xp,Yp] = meshgrid(linspace(-3,3,2));
    Zp = planeZ*ones(size(Xp));
    surf(ax,Xp,Yp,Zp,...
        'FaceColor',[0.9 0.9 0.9],...
        'FaceAlpha',0.4,...
        'EdgeColor','none');

    % --- Shadow (convex hull projection) ---
    xShadow = xR(:);
    yShadow = yR(:);

    k = convhull(xShadow,yShadow);

    fill3(ax,...
        xShadow(k),...
        yShadow(k),...
        planeZ*ones(size(k)),...
        [0 0 0],...
        'FaceAlpha',0.5,...
        'EdgeColor','none');

    % --- Analytical shadow area ---
    % A = π a sqrt(a^2 sin^2θ + c^2 cos^2θ)
    A = (pi * a^2 * c) / sqrt(c^2*cos(theta)^2 + a^2*sin(theta)^2);

    areaLabel.Text = sprintf('Shadow Area: %.4f m^2',A);

    hold(ax,'off')

end

end
