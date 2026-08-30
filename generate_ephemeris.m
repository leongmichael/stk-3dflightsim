function generate_ephemeris(excel_file, output_file)
%GENERATE_EPHEMERIS Convert flight Excel data to an STK ephemeris (.e) file.
%
%   generate_ephemeris
%       Uses the Excel and output paths in config.m.
%
%   generate_ephemeris(excel_file)
%   generate_ephemeris(excel_file, output_file)
%
%   The spreadsheet must include columns:
%       time (s), ecef x (ft), ecef y (ft), ecef z (ft), vx, vy, vz
%
%   Positions are converted from feet to meters. Velocity is written as
%   provided (ECEF components). See README.md for the full column list.

    cfg = config();
    if nargin < 1 || isempty(excel_file)
        excel_file = cfg.excel_file;
    end
    if nargin < 2 || isempty(output_file)
        output_file = cfg.ephemeris_file;
    end

    if ~isfile(excel_file)
        error('generate_ephemeris:file_not_found', ...
            'Excel file not found: %s', excel_file);
    end

    fprintf('Reading %s...\n', excel_file);
    data = readtable(excel_file, 'VariableNamingRule', 'preserve');
    required = ["time (s)", "ecef x (ft)", "ecef y (ft)", "ecef z (ft)", ...
                "vx", "vy", "vz"];
    missing = required(~ismember(required, string(data.Properties.VariableNames)));
    if ~isempty(missing)
        error('generate_ephemeris:missing_columns', ...
            'Spreadsheet is missing required columns: %s', strjoin(missing, ', '));
    end

    ft_to_m = 0.3048;
    t  = data.("time (s)");
    x  = data.("ecef x (ft)") * ft_to_m;
    y  = data.("ecef y (ft)") * ft_to_m;
    z  = data.("ecef z (ft)") * ft_to_m;
    vx = data.vx;
    vy = data.vy;
    vz = data.vz;
    n  = numel(t);

    epoch_string = datestr(cfg.epoch, 'dd mmm yyyy HH:MM:SS');
    fprintf('Writing %d points to %s (epoch %s UTC)...\n', n, output_file, epoch_string);

    fid = fopen(output_file, 'w');
    if fid < 0
        error('generate_ephemeris:write_failed', 'Could not open %s for writing.', output_file);
    end
    closer = onCleanup(@() fclose(fid));

    fprintf(fid, ['stk.v.11.0\n', ...
                  'BEGIN Ephemeris\n', ...
                  'NumberOfEphemerisPoints %d\n', ...
                  'ScenarioEpoch %s.000000\n', ...
                  'InterpolationMethod Lagrange\n', ...
                  'InterpolationOrder 5\n', ...
                  'CentralBody Earth\n', ...
                  'CoordinateSystem Fixed\n', ...
                  'EphemerisTimePosVel\n'], n, epoch_string);

    for i = 1:n
        fprintf(fid, '%.6f %.3f %.3f %.3f %.6f %.6f %.6f\n', ...
            t(i), x(i), y(i), z(i), vx(i), vy(i), vz(i));
    end
    fprintf(fid, 'END Ephemeris\n');

    clear closer
    fprintf('Saved %s\n', output_file);
end
