% === Launch STK ===
fprintf('Launching STK...\n');
app = actxserver('STK12.Application');
app.Visible = 1;
root = app.Personality2;

% === Create New Scenario ===
fprintf('Creating new scenario...\n');
root.NewScenario('MissileTrajectoryScenario');
scenario = root.CurrentScenario;

% Set scenario time
startTime = '23 Apr 2025 19:00:00.000';
stopTime  = '23 Apr 2025 19:20:00.000';
scenario.SetTimePeriod(startTime, stopTime);
scenario.StartTime = startTime;
scenario.StopTime = stopTime;

% === Create Missile Object ===
fprintf('Creating missile object...\n');
missile = scenario.Children.New('eMissile', 'Missile');

% === Set Trajectory Propagator to STKExternal ===
fprintf('Setting missile trajectory to STKExternal...\n');
missile.SetTrajectoryType('ePropagatorStkExternal');

% === Configure STKExternal Propagator ===
fprintf('Loading ephemeris file...\n');
ephemPath = fullfile(pwd, 'missile_trajectory.e');
traj = missile.Trajectory;  % This is now IAgVePropagatorStkExternal
traj.Filename = ephemPath;
traj.Propagate;


% % === Adjust 3D View ===
% fprintf('Setting 3D view...\n');
% root.ExecuteCommand('VO * Activate3DWindow');
% root.ExecuteCommand('VO * ViewFromTo "Missile" "Earth"');
% 
% % === Start Recording ===
% fprintf('Recording missile animation...\n');
% videoOutput = fullfile(pwd, 'MissileFlight.mp4');
% root.ExecuteCommand(sprintf('VO * Movie Start Type "mp4" Filename "%s" WindowID 1 Quality High Size 1920 1080', videoOutput));
% 
% % === Animate ===
% root.ExecuteCommand('Animate * Reset');
% root.ExecuteCommand('Animate * Start');
% pause(1.1 * (t(end) - t(1)));  % crude wait
% 
% % === Stop Recording ===
% root.ExecuteCommand('VO * Movie Stop');
% fprintf('✅ Missile video saved to: %s\n', videoOutput);
