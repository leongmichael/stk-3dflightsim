function generate_video
%GENERATE_VIDEO Load the ephemeris into STK and record a 3D animation.
%
%   Requires AGI STK 12 (COM automation) and a .e file produced by
%   generate_ephemeris. Paths, scenario time, camera, and recording
%   length are set in config.m.

    cfg = config();
    ephem_path = fullfile(pwd, cfg.ephemeris_file);
    if ~isfile(ephem_path)
        error('generate_video:file_not_found', ...
            ['Ephemeris file not found: %s\n', ...
             'Run generate_ephemeris first, or update config.m.'], ephem_path);
    end

    start_time = datestr(cfg.epoch, 'dd mmm yyyy HH:MM:SS.FFF');
    stop_time  = datestr(cfg.epoch + cfg.duration, 'dd mmm yyyy HH:MM:SS.FFF');

    fprintf('Launching STK (%s)...\n', cfg.stk_prog_id);
    try
        app = actxserver(cfg.stk_prog_id);
    catch ME
        error('generate_video:stk_launch_failed', ...
            ['Could not start STK via COM (%s).\n', ...
             'Confirm STK 12 is installed and MATLAB COM automation is enabled.\n', ...
             'Original error: %s'], cfg.stk_prog_id, ME.message);
    end
    app.Visible = 1;
    root = app.Personality2;

    fprintf('Creating scenario "%s"...\n', cfg.scenario_name);
    root.NewScenario(cfg.scenario_name);
    scenario = root.CurrentScenario;
    scenario.SetTimePeriod(start_time, stop_time);
    scenario.StartTime = start_time;
    scenario.StopTime = stop_time;

    fprintf('Loading trajectory from %s...\n', ephem_path);
    vehicle = scenario.Children.New('eMissile', cfg.vehicle_name);
    vehicle.SetTrajectoryType('ePropagatorStkExternal');
    traj = vehicle.Trajectory;
    traj.Filename = ephem_path;
    traj.Propagate;

    fprintf('Pointing camera at the vehicle...\n');
    scene_manager = scenario.SceneManager;
    scene = scene_manager.Scenes.Item(0);
    camera = scene.Camera;

    vehicle_vgt = vehicle.Vgt;
    camera.ViewOffsetWithUpAxis( ...
        vehicle_vgt.Axes.Item('Body'), ...
        vehicle_vgt.Points.Item('Center'), ...
        num2cell(cfg.camera_offset_km), ...
        {0; 0; 1});
    camera.ConstrainedUpAxis = 'eStkGraphicsConstrainedUpAxisZ';
    camera.FieldOfView = cfg.field_of_view_deg;
    camera.LockViewDirection = false;
    scene_manager.Render;

    video_dir = pwd;
    fprintf('Recording to %s (prefix %s)...\n', video_dir, cfg.video_prefix);
    root.ExecuteCommand('RecordMovie3D * Record Off');
    root.ExecuteCommand(sprintf( ...
        'RecordMovie3D * FileFormat H264 OutputDir "%s" Prefix %s', ...
        video_dir, cfg.video_prefix));

    root.ExecuteCommand('Animate * Reset');
    root.ExecuteCommand('RecordMovie3D * Record On');
    root.ExecuteCommand('Animate * Start');
    pause(cfg.record_duration);
    root.ExecuteCommand('RecordMovie3D * Record Off');

    fprintf('Recording finished. Video saved under:\n  %s\n', video_dir);
end
