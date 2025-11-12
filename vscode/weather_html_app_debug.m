function weather_html_app_debug()
    % Weather HTML App - DEBUG VERSION
    % This version includes extensive logging to help diagnose issues
    
    fprintf('\n=== DEBUG MODE - Weather HTML App ===\n');
    fprintf('Timestamp: %s\n\n', datetime('now'));
    
    % Create main figure
    fprintf('[DEBUG] Creating uifigure...\n');
    fig = uifigure('Name', 'Weather Regression Analysis [DEBUG]', ...
                   'Position', [100, 100, 1000, 700]);
    fprintf('[DEBUG] ✓ Figure created\n');
    
    % Get the path to the HTML file
    htmlFile = fullfile(fileparts(mfilename('fullpath')), 'weather_html_app_debug.html');
    fprintf('[DEBUG] HTML file path: %s\n', htmlFile);
    
    if ~exist(htmlFile, 'file')
        error('[ERROR] HTML file not found! Expected at: %s', htmlFile);
    end
    fprintf('[DEBUG] ✓ HTML file exists\n');
    
    % Create uihtml component
    fprintf('[DEBUG] Creating uihtml component...\n');
    htmlComponent = uihtml(fig);
    htmlComponent.Position = [0 0 fig.Position(3) fig.Position(4)];
    htmlComponent.HTMLSource = htmlFile;
    fprintf('[DEBUG] ✓ uihtml component created\n');
    
    % Store app data in figure
    fig.UserData.htmlComponent = htmlComponent;
    fig.UserData.weatherData = struct();
    fig.UserData.debugLog = {};
    
    % Setup data changed callback
    fprintf('[DEBUG] Setting up DataChangedFcn callback...\n');
    htmlComponent.DataChangedFcn = @(src, event) handleDataChange(fig, event);
    fprintf('[DEBUG] ✓ Callback registered\n');
    
    % Wait for HTML to load
    fprintf('[DEBUG] Waiting for HTML to load...\n');
    pause(1.0);
    
    % Send initial test message
    fprintf('[DEBUG] Sending test message to HTML...\n');
    testData = struct('action', 'test', 'message', 'MATLAB is connected!');
    htmlComponent.Data = testData;
    
    fprintf('\n=== DEBUG SETUP COMPLETE ===\n');
    fprintf('Instructions:\n');
    fprintf('1. Open the browser console (F12) in the HTML window\n');
    fprintf('2. Click any button and watch both this window and console\n');
    fprintf('3. Check if you see "Data received from MATLAB" messages\n\n');
    
    sendStatusUpdate(htmlComponent, 'DEBUG MODE: App initialized. Check MATLAB console for logs.', 'info');
end

function handleDataChange(fig, event)
    % Handle data changes from HTML UI with extensive logging
    
    fprintf('\n[DEBUG] ===== DATA CHANGE EVENT RECEIVED =====\n');
    fprintf('[DEBUG] Timestamp: %s\n', datetime('now'));
    
    htmlComponent = fig.UserData.htmlComponent;
    data = event.Data;
    
    fprintf('[DEBUG] Event class: %s\n', class(event));
    fprintf('[DEBUG] Event.Data class: %s\n', class(data));
    
    if isempty(data)
        fprintf('[WARNING] Received empty data!\n');
        return;
    end
    
    fprintf('[DEBUG] Data received:\n');
    disp(data);
    
    % Parse the action from HTML
    if isfield(data, 'action')
        fprintf('[DEBUG] Action detected: %s\n', data.action);
        
        switch data.action
            case 'test'
                fprintf('[DEBUG] Test action - connection working!\n');
                sendStatusUpdate(htmlComponent, 'Test successful! MATLAB received your click.', 'success');
                
            case 'fetchData'
                fprintf('[DEBUG] Calling fetchWeatherData...\n');
                fetchWeatherData(fig, data);
                
            case 'performRegression'
                fprintf('[DEBUG] Calling performLinearRegression...\n');
                performLinearRegression(fig);
                
            case 'quickSelect'
                fprintf('[DEBUG] Calling handleQuickSelect...\n');
                handleQuickSelect(fig, data);
                
            otherwise
                fprintf('[WARNING] Unknown action: %s\n', data.action);
        end
    else
        fprintf('[WARNING] No action field in data!\n');
    end
    
    fprintf('[DEBUG] ===== EVENT HANDLING COMPLETE =====\n\n');
end

function handleQuickSelect(fig, data)
    fprintf('[DEBUG] handleQuickSelect called\n');
    htmlComponent = fig.UserData.htmlComponent;
    
    cities = struct(...
        'montreal', struct('name', 'Montreal, Canada', 'lat', 45.5017, 'lon', -73.5673), ...
        'paris', struct('name', 'Paris, France', 'lat', 48.8566, 'lon', 2.3522), ...
        'newyork', struct('name', 'New York, USA', 'lat', 40.7128, 'lon', -74.0060), ...
        'london', struct('name', 'London, UK', 'lat', 51.5074, 'lon', -0.1278), ...
        'tokyo', struct('name', 'Tokyo, Japan', 'lat', 35.6762, 'lon', 139.6503), ...
        'sydney', struct('name', 'Sydney, Australia', 'lat', -33.8688, 'lon', 151.2093) ...
    );
    
    fprintf('[DEBUG] City requested: %s\n', data.city);
    
    if isfield(cities, data.city)
        cityData = cities.(data.city);
        fprintf('[DEBUG] City found: %s (%.4f, %.4f)\n', cityData.name, cityData.lat, cityData.lon);
        
        % Send city data back to HTML
        result = struct('action', 'updateLocation', ...
                       'cityName', cityData.name, ...
                       'latitude', cityData.lat, ...
                       'longitude', cityData.lon);
        htmlComponent.Data = result;
        
        sendStatusUpdate(htmlComponent, sprintf('Selected: %s', cityData.name), 'success');
    else
        fprintf('[WARNING] City not found: %s\n', data.city);
    end
end

function fetchWeatherData(fig, data)
    fprintf('[DEBUG] fetchWeatherData called\n');
    htmlComponent = fig.UserData.htmlComponent;
    
    try
        % Extract parameters
        latitude = data.latitude;
        longitude = data.longitude;
        startDate = data.startDate;
        endDate = data.endDate;
        
        fprintf('[DEBUG] Parameters:\n');
        fprintf('  Latitude: %.4f\n', latitude);
        fprintf('  Longitude: %.4f\n', longitude);
        fprintf('  Start Date: %s\n', startDate);
        fprintf('  End Date: %s\n', endDate);
        
        sendStatusUpdate(htmlComponent, 'Fetching weather data...', 'info');
        
        % Build API URL
        url = sprintf(['https://archive-api.open-meteo.com/v1/archive?' ...
            'latitude=%.4f&longitude=%.4f&start_date=%s&end_date=%s&' ...
            'daily=temperature_2m_max,temperature_2m_min,precipitation_sum&' ...
            'timezone=auto'], latitude, longitude, startDate, endDate);
        
        fprintf('[DEBUG] API URL: %s\n', url);
        fprintf('[DEBUG] Calling webread...\n');
        
        % Fetch data
        apiData = webread(url);
        
        fprintf('[DEBUG] ✓ Data received from API\n');
        
        % Process data
        dates = datetime(apiData.daily.time, 'InputFormat', 'yyyy-MM-dd');
        tempMax = apiData.daily.temperature_2m_max;
        tempMin = apiData.daily.temperature_2m_min;
        precipitation = apiData.daily.precipitation_sum;
        tempAvg = (tempMax + tempMin) / 2;
        
        fprintf('[DEBUG] Processed %d days of data\n', length(dates));
        
        % Store data
        fig.UserData.weatherData.dates = dates;
        fig.UserData.weatherData.tempMax = tempMax;
        fig.UserData.weatherData.tempMin = tempMin;
        fig.UserData.weatherData.tempAvg = tempAvg;
        fig.UserData.weatherData.precipitation = precipitation;
        fig.UserData.weatherData.latitude = latitude;
        fig.UserData.weatherData.longitude = longitude;
        
        % Send data to HTML for display
        result = struct(...
            'action', 'displayData', ...
            'dates', cellstr(string(dates, 'yyyy-MM-dd')), ...
            'tempMax', tempMax, ...
            'tempMin', tempMin, ...
            'tempAvg', tempAvg, ...
            'precipitation', precipitation, ...
            'dataPoints', length(dates) ...
        );
        
        fprintf('[DEBUG] Sending results to HTML...\n');
        htmlComponent.Data = result;
        
        sendStatusUpdate(htmlComponent, sprintf('Successfully fetched %d days of data', length(dates)), 'success');
        fprintf('[DEBUG] ✓ fetchWeatherData complete\n');
        
    catch ME
        fprintf('[ERROR] Exception in fetchWeatherData:\n');
        fprintf('  ID: %s\n', ME.identifier);
        fprintf('  Message: %s\n', ME.message);
        fprintf('  Stack:\n');
        for i = 1:length(ME.stack)
            fprintf('    %s (line %d)\n', ME.stack(i).name, ME.stack(i).line);
        end
        sendStatusUpdate(htmlComponent, sprintf('Error: %s', ME.message), 'error');
    end
end

function performLinearRegression(fig)
    fprintf('[DEBUG] performLinearRegression called\n');
    htmlComponent = fig.UserData.htmlComponent;
    weatherData = fig.UserData.weatherData;
    
    if ~isfield(weatherData, 'tempAvg') || isempty(weatherData.tempAvg)
        fprintf('[WARNING] No weather data available\n');
        sendStatusUpdate(htmlComponent, 'No data available. Please fetch data first.', 'error');
        return;
    end
    
    try
        sendStatusUpdate(htmlComponent, 'Performing linear regression...', 'info');
        
        % Prepare data for regression
        dates = weatherData.dates;
        tempAvg = weatherData.tempAvg;
        
        fprintf('[DEBUG] Data points: %d\n', length(tempAvg));
        
        % Remove NaN values
        validIdx = ~isnan(tempAvg);
        dates = dates(validIdx);
        tempAvg = tempAvg(validIdx);
        
        fprintf('[DEBUG] Valid data points: %d\n', length(tempAvg));
        
        % Convert dates to day numbers
        dayNumbers = (1:length(dates))';
        
        % Perform linear regression: y = mx + b
        X = [ones(length(dayNumbers), 1), dayNumbers];
        coefficients = X \ tempAvg;
        
        b = coefficients(1);  % Intercept
        m = coefficients(2);  % Slope
        
        fprintf('[DEBUG] Slope (m): %.6f\n', m);
        fprintf('[DEBUG] Intercept (b): %.6f\n', b);
        
        % Calculate predictions
        predictions = X * coefficients;
        
        % Calculate statistics
        residuals = tempAvg - predictions;
        SSE = sum(residuals.^2);
        SST = sum((tempAvg - mean(tempAvg)).^2);
        rSquared = 1 - (SSE / SST);
        RMSE = sqrt(mean(residuals.^2));
        
        fprintf('[DEBUG] R²: %.6f\n', rSquared);
        fprintf('[DEBUG] RMSE: %.6f\n', RMSE);
        
        % Determine trend
        if abs(m) < 0.01
            trendText = 'stable (no significant change)';
        elseif m > 0
            trendText = sprintf('warming (%.4f°C per day)', m);
        else
            trendText = sprintf('cooling (%.4f°C per day)', abs(m));
        end
        
        fprintf('[DEBUG] Trend: %s\n', trendText);
        
        % Calculate temperature change over period
        tempChange = m * length(dayNumbers);
        
        % Send results to HTML
        result = struct(...
            'action', 'displayRegression', ...
            'slope', m, ...
            'intercept', b, ...
            'rSquared', rSquared, ...
            'rmse', RMSE, ...
            'trendText', trendText, ...
            'tempChange', tempChange, ...
            'predictions', predictions, ...
            'residuals', residuals, ...
            'dates', cellstr(string(dates, 'yyyy-MM-dd')), ...
            'tempAvg', tempAvg ...
        );
        
        fprintf('[DEBUG] Sending results to HTML...\n');
        htmlComponent.Data = result;
        
        sendStatusUpdate(htmlComponent, 'Regression analysis complete!', 'success');
        fprintf('[DEBUG] ✓ performLinearRegression complete\n');
        
    catch ME
        fprintf('[ERROR] Exception in performLinearRegression:\n');
        fprintf('  ID: %s\n', ME.identifier);
        fprintf('  Message: %s\n', ME.message);
        sendStatusUpdate(htmlComponent, sprintf('Regression error: %s', ME.message), 'error');
    end
end

function sendStatusUpdate(htmlComponent, message, type)
    fprintf('[DEBUG] Status: [%s] %s\n', upper(type), message);
    status = struct('action', 'status', 'message', message, 'type', type);
    htmlComponent.Data = status;
end
