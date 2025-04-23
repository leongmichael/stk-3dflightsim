% Launch STK Application
app = actxserver('STK12.Application');  % Replace 'STK11.Application' with your STK version if different
app.Visible = 1;

% Obtain the root object
root = app.Personality2;

% Create a new scenario
root.NewScenario('AircraftGreatArcDemo');
scenario = root.CurrentScenario;

% Set the scenario time period
startTime = '23 Apr 2025 19:00:00.000';
stopTime = '23 Apr 2025 19:20:00.000';
scenario.SetTimePeriod(startTime, stopTime);
scenario.StartTime = startTime;
scenario.StopTime = stopTime;

% Add an aircraft object to the scenario
aircraft = scenario.Children.New('eAircraft', 'MyAircraft');

% Set the propagator to Great Arc
aircraft.SetRouteType('ePropagatorGreatArc');

% Access the route interface
route = aircraft.Route;

% Set the computation method to determine time and acceleration from velocity
route.Method = 'eDetermineTimeAccFromVel';

% Set the altitude reference type to Mean Sea Level (MSL)
route.SetAltitudeRefType('eWayPtAltRefMSL');

% Remove any existing waypoints
route.Waypoints.RemoveAll();

% Define waypoints with [Latitude, Longitude, Altitude (km), Speed (km/s)]
waypoints = [
    35.35, -117.81, 2.06, 0.1;
    35.60, -117.50, 5.00, 0.1;
    36.00, -117.00, 10.00, 0.1
];

% Add waypoints to the route
for i = 1:size(waypoints, 1)
    wp = route.Waypoints.Add();
    wp.Latitude = waypoints(i, 1);
    wp.Longitude = waypoints(i, 2);
    wp.Altitude = waypoints(i, 3);  % Altitude in km
    wp.Speed = waypoints(i, 4);     % Speed in km/s
end

% Propagate the route to compute the trajectory
route.Propagate();
