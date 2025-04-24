% Load the Excel data
filename = 'SampleOutput.xlsx';
data = readtable(filename, 'VariableNamingRule', 'preserve');

% Convert ECEF (feet) to meters
x = data.("ecef x (ft)") * 0.3048;
y = data.("ecef y (ft)") * 0.3048;
z = data.("ecef z (ft)") * 0.3048;
vx = data.vx;  % already in m/s
vy = data.vy;
vz = data.vz;
t = data.("time (s)");

% Define scenario start time
scenarioEpoch = datetime(2025, 4, 23, 19, 0, 0);  % UTC
epochString = datestr(scenarioEpoch, 'dd mmm yyyy HH:MM:SS');

% Prepare ephemeris lines
lines = {
    "stk.v.11.0"
    "BEGIN Ephemeris"
    sprintf("NumberOfEphemerisPoints %d", length(t))
    sprintf("ScenarioEpoch %s.000000", epochString)
    "InterpolationMethod Lagrange"
    "InterpolationOrder 5"
    "CentralBody Earth"
    "CoordinateSystem Fixed"
    "EphemerisTimePosVel"
};

% Add the trajectory data with velocities
for i = 1:length(t)
    lines{end+1} = sprintf('%.6f %.3f %.3f %.3f %.6f %.6f %.6f', ...
        t(i), x(i), y(i), z(i), vx(i), vy(i), vz(i));
end

% Close the file
lines{end+1} = "END Ephemeris";

% Write to .e file
fid = fopen('missile_trajectory_with_vel.e', 'w');
for i = 1:length(lines)
    fprintf(fid, '%s\n', lines{i});
end
fclose(fid);
