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

% TODO: SET VIEW TO ROCKET/MISSILE

% === Configure High-Res MP4 Recording ===
fprintf('Setting up video recording...\n');
videoDir = fullfile(pwd);  % Save in current directory
root.ExecuteCommand('RecordMovie3D * Record Off');
root.ExecuteCommand(['RecordMovie3D * FileFormat H264 ', ...
                     'OutputDir "', videoDir, '" Prefix MissileFlight']);
% Optional visual enhancements (commented out):
% root.ExecuteCommand('RecordMovie3D * AntiAlias 2');

% === Animate and Record ===
fprintf('Recording animation...\n');
root.ExecuteCommand('Animate * Reset');
root.ExecuteCommand('RecordMovie3D * Record On');
root.ExecuteCommand('Animate * Start');

% % === Wait Until Scenario End ===
% stopTimeNum = datenum(scenario.StopTime); 
% while datenum(root.CurrentTime) < stopTimeNum
%     pause(0.5);
% end

pause(10);  % Wait 10 seconds while animation plays and video records


% === Stop Recording ===
root.ExecuteCommand('RecordMovie3D * Record Off');
fprintf('✅ Video recording complete. Check output in:\n%s\n', videoDir);
