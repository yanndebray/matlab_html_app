function launch_weather_html_app()
    % Launch Weather Linear Regression HTML App
    % Simple launcher script
    
    fprintf('\n');
    fprintf('==============================================\n');
    fprintf('   Weather Linear Regression HTML App\n');
    fprintf('==============================================\n');
    fprintf('\n');
    fprintf('Launching app with HTML interface...\n');
    fprintf('\n');
    
    % Get the directory of this script
    scriptPath = fileparts(mfilename('fullpath'));
    
    % Check if required files exist
    mFile = fullfile(scriptPath, 'weather_html_app.m');
    htmlFile = fullfile(scriptPath, 'weather_html_app.html');
    
    if ~exist(mFile, 'file')
        error('Cannot find weather_html_app.m in the current directory');
    end
    
    if ~exist(htmlFile, 'file')
        error('Cannot find weather_html_app.html in the current directory');
    end
    
    fprintf('✓ Found MATLAB file: %s\n', mFile);
    fprintf('✓ Found HTML file: %s\n', htmlFile);
    fprintf('\n');
    fprintf('Opening app window...\n');
    fprintf('\n');
    fprintf('Instructions:\n');
    fprintf('1. Select a city or enter custom coordinates\n');
    fprintf('2. Choose date range (default: last 3 months)\n');
    fprintf('3. Click "Fetch Weather Data"\n');
    fprintf('4. Click "Perform Regression" to analyze trends\n');
    fprintf('\n');
    fprintf('==============================================\n');
    fprintf('\n');
    
    % Launch the app
    weather_html_app();
end
