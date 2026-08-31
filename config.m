function cfg = config
%CONFIG Shared settings for the ephemeris and STK recording scripts.
%
%   Edit this file to point at your own trajectory data or to change the
%   scenario time, camera, or recording options. Both generate_ephemeris
%   and generate_video read from here so the epoch and file names stay
%   in sync.

    % --- Input / output files (relative to the current working directory)
    cfg.excel_file     = fullfile('sample_data', 'sample_flight.xlsx');
    cfg.ephemeris_file = fullfile('sample_data', 'sample_trajectory.e');
    cfg.video_prefix   = 'missile_flight';

    % --- Scenario time (UTC). Duration must cover the trajectory.
    cfg.epoch    = datetime(2025, 4, 23, 19, 0, 0);
    cfg.duration = minutes(20);

    % --- STK COM server and object names
    cfg.stk_prog_id    = 'STK12.Application';
    cfg.scenario_name  = 'missile_trajectory_scenario';
    cfg.vehicle_name   = 'missile';   % STK missile object (eMissile)

    % --- Camera: offset in the vehicle body frame (km) and field of view
    cfg.camera_offset_km = [-10; 0; 5];   % behind, right, above
    cfg.field_of_view_deg = 60;

    % --- Wall-clock seconds to record while STK animates
    cfg.record_duration = 10;
end
