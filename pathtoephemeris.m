% Load the Excel data
filename = 'SampleOutput.xlsx';
fprintf('Reading Excel data from %s...\n', filename);
data = readtable(filename, 'VariableNamingRule', 'preserve');
fprintf('Excel data successfully loaded. Rows read: %d\n', height(data));

% Convert ECEF (feet) to meters
fprintf('Converting ECEF coordinates from feet to meters...\n');
x = data.("ecef x (ft)") * 0.3048;
y = data.("ecef y (ft)") * 0.3048;
z = data.("ecef z (ft)") * 0.3048;

vx = data.vx;  % already in m/s
vy = data.vy;
vz = data.vz;
t = data.("time (s)");
fprintf('Coordinate and velocity data extracted and converted.\n');

% Define scenario start time
scenarioEpoch = datetime(2025, 4, 23, 19, 0, 0);  % UTC
epochString = datestr(scenarioEpoch, 'dd mmm yyyy HH:MM:SS');
fprintf('Scenario epoch set to: %s UTC\n', epochString);

% Prepare ephemeris lines
fprintf('Preparing ephemeris file content...\n');
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
fprintf('Adding trajectory data (%d points)...\n', length(t));
for i = 1:length(t)
    lines{end+1} = sprintf('%.6f %.3f %.3f %.3f %.6f %.6f %.6f', ...
        t(i), x(i), y(i), z(i), vx(i), vy(i), vz(i));
end

% Close the file
lines{end+1} = "END Ephemeris";
fprintf('Finalizing ephemeris file...\n');

% Write to .e file
outputFile = 'missile_trajectory.e';
fid = fopen(outputFile, 'w');
fprintf('Writing data to file: %s\n', outputFile);
for i = 1:length(lines)
    fprintf(fid, '%s\n', lines{i});
end
fclose(fid);
fprintf('File writing complete. Ephemeris saved as %s\n', outputFile);
