function FFwind_figure(fileName)
%% function that plots wind speeds from a TurbSim .bts file

    Component={'U','V','W'};

    [velocity, twrVelocity, y, z, zTwr, nz, ny, dz, dy, dt, zHub, z1,mffws] = readfile_BTS(fileName);
    %%
    nt = size(velocity,1);
    t = (0:(nt-1))*dt;
    
    xSlice = [t(1) t(end)];
    ySlice = [y(1) y(end)];
    zSlice = [z(1) z(end)];
    for i=1:3
        figure;
        h=slice(y,t,z, squeeze(velocity(:,i,:,:)), ySlice, xSlice, zSlice );
        set(h,'EdgeColor','none')
        
        xlabel('y (m)')
        ylabel('time (s)')
        zlabel('z (m)')
        title([Component{i} '-component wind speed (m/s)'])
        colorbar
    end

return
end