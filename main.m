% === Load Excel data ===
filename = 'SampleOutput.xlsx';  % Change if needed
fprintf('Reading Excel data from: %s\n', filename);
data = readtable(filename, 'VariableNamingRule', 'preserve');

% === Limit number of waypoints ===
maxPoints = min(500, height(data));
latitudes = data.lat(1:maxPoints);
longitudes = data.long(1:maxPoints);
altitudes_km = data.("alt (ft)")(1:maxPoints) * 0.0003048;  % Convert ft to km

vx = data.vx(1:maxPoints);
vy = data.vy(1:maxPoints);
vz = data.vz(1:maxPoints);
speed_kms = sqrt(vx.^2 + vy.^2 + vz.^2) * 0.0003048;  % Convert ft/s to km/s

% === Launch STK ===
fprintf('Launching STK...\n');
app = actxserver('STK12.Application');  % Change version if needed
app.Visible = 1;
root = app.Personality2;

fprintf('Creating new scenario: AircraftFromExcel\n');
root.NewScenario('AircraftFromExcel');
scenario = root.CurrentScenario;

% === Set scenario time period ===
startTime = '23 Apr 2025 19:00:00.000';
stopTime  = '23 Apr 2025 19:20:00.000';
fprintf('Setting scenario time: %s to %s\n', startTime, stopTime);
scenario.SetTimePeriod(startTime, stopTime);
scenario.StartTime = startTime;
scenario.StopTime = stopTime;

% === Create Aircraft with Great Arc Propagator ===
fprintf('Creating aircraft with Great Arc propagator...\n');
aircraft = scenario.Children.New('eAircraft', 'MyAircraft');
aircraft.SetRouteType('ePropagatorGreatArc');
route = aircraft.Route;
route.Method = 'eDetermineTimeAccFromVel';
route.SetAltitudeRefType('eWayPtAltRefMSL');
route.Waypoints.RemoveAll();

% === Add waypoints ===
fprintf('Adding %d waypoints from Excel...\n', length(latitudes));
for i = 1:length(latitudes)
    lat = latitudes(i);
    lon = longitudes(i);
    alt = altitudes_km(i);
    spd = speed_kms(i);

    wp = route.Waypoints.Add();
    wp.Latitude = lat;
    wp.Longitude = lon;
    wp.Altitude = alt;
    wp.Speed = spd;

    fprintf('  Added waypoint %d: Lat %.6f, Lon %.6f, Alt %.2f km, Speed %.4f km/s\n', ...
        i, lat, lon, alt, spd);
end

% === Propagate the route ===
fprintf('Propagating route...\n');
route.Propagate();
fprintf('✅ Propagation complete.\n');
