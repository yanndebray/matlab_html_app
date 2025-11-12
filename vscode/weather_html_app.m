function weather_html_app()
    % Weather Linear Regression App with HTML UI
    % Uses uihtml to create an interactive HTML front end
    % Algorithm runs in MATLAB backend
    
    % Create main figure
    fig = uifigure('Name', 'Weather Regression Analysis', ...
                   'Position', [100, 100, 1000, 830]);
    
    % Get the path to the HTML file
    htmlFile = fullfile(fileparts(mfilename('fullpath')), 'weather_html_app.html');
    
    % Create uihtml component
    htmlComponent = uihtml(fig);
    htmlComponent.Position = [0 0 fig.Position(3) fig.Position(4)];
    htmlComponent.HTMLSource = htmlFile;
    
    % Store app data in figure
    fig.UserData.htmlComponent = htmlComponent;
    fig.UserData.weatherData = struct();
    
    % Setup data changed callback
    htmlComponent.DataChangedFcn = @(src, event) handleDataChange(fig, event);
    
    % Wait for HTML to load and send initial data
    pause(0.5);
    sendStatusUpdate(htmlComponent, 'App initialized. Select location and date range.', 'info');
end

function handleDataChange(fig, event)
    % Handle data changes from HTML UI
    
    htmlComponent = fig.UserData.htmlComponent;
    data = event.Data;
    
    if isempty(data)
        return;
    end
    
    % Parse the action from HTML
    if isfield(data, 'action')
        switch data.action
            case 'fetchData'
                fetchWeatherData(fig, data);
            case 'performRegression'
                performLinearRegression(fig);
            case 'quickSelect'
                handleQuickSelect(fig, data);
        end
    end
end

function handleQuickSelect(fig, data)
    % Handle quick city selection
    htmlComponent = fig.UserData.htmlComponent;
    
    cities = struct(...
        'montreal', struct('name', 'Montreal, Canada', 'lat', 45.5017, 'lon', -73.5673), ...
        'paris', struct('name', 'Paris, France', 'lat', 48.8566, 'lon', 2.3522), ...
        'newyork', struct('name', 'New York, USA', 'lat', 40.7128, 'lon', -74.0060), ...
        'london', struct('name', 'London, UK', 'lat', 51.5074, 'lon', -0.1278), ...
        'tokyo', struct('name', 'Tokyo, Japan', 'lat', 35.6762, 'lon', 139.6503), ...
        'sydney', struct('name', 'Sydney, Australia', 'lat', -33.8688, 'lon', 151.2093) ...
    );
    
    if isfield(cities, data.city)
        cityData = cities.(data.city);
        
        % Send city data back to HTML
        result = struct('action', 'updateLocation', ...
                       'cityName', cityData.name, ...
                       'latitude', cityData.lat, ...
                       'longitude', cityData.lon);
        htmlComponent.Data = result;
        
        sendStatusUpdate(htmlComponent, sprintf('Selected: %s', cityData.name), 'success');
    end
end

function fetchWeatherData(fig, data)
    % Fetch weather data from Open-Meteo API
    
    htmlComponent = fig.UserData.htmlComponent;
    
    try
        % Extract parameters
        latitude = data.latitude;
        longitude = data.longitude;
        startDate = data.startDate;
        endDate = data.endDate;
        
        sendStatusUpdate(htmlComponent, 'Fetching weather data...', 'info');
        
        % Build API URL
        url = sprintf(['https://archive-api.open-meteo.com/v1/archive?' ...
            'latitude=%.4f&longitude=%.4f&start_date=%s&end_date=%s&' ...
            'daily=temperature_2m_max,temperature_2m_min,precipitation_sum&' ...
            'timezone=auto'], latitude, longitude, startDate, endDate);
        
        % Fetch data
        apiData = webread(url);
        
        % Process data
        dates = datetime(apiData.daily.time, 'InputFormat', 'yyyy-MM-dd');
        tempMax = apiData.daily.temperature_2m_max;
        tempMin = apiData.daily.temperature_2m_min;
        precipitation = apiData.daily.precipitation_sum;
        tempAvg = (tempMax + tempMin) / 2;
        
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
        
        htmlComponent.Data = result;
        
        sendStatusUpdate(htmlComponent, sprintf('Successfully fetched %d days of data', length(dates)), 'success');
        
    catch ME
        sendStatusUpdate(htmlComponent, sprintf('Error: %s', ME.message), 'error');
    end
end

function performLinearRegression(fig)
    % Perform linear regression on weather data
    
    htmlComponent = fig.UserData.htmlComponent;
    weatherData = fig.UserData.weatherData;
    
    if ~isfield(weatherData, 'tempAvg') || isempty(weatherData.tempAvg)
        sendStatusUpdate(htmlComponent, 'No data available. Please fetch data first.', 'error');
        return;
    end
    
    try
        sendStatusUpdate(htmlComponent, 'Performing linear regression...', 'info');
        
        % Prepare data for regression
        dates = weatherData.dates;
        tempAvg = weatherData.tempAvg;
        
        % Remove NaN values
        validIdx = ~isnan(tempAvg);
        dates = dates(validIdx);
        tempAvg = tempAvg(validIdx);
        
        % Convert dates to day numbers
        dayNumbers = (1:length(dates))';
        
        % Perform linear regression: y = mx + b
        X = [ones(length(dayNumbers), 1), dayNumbers];
        coefficients = X \ tempAvg;
        
        b = coefficients(1);  % Intercept
        m = coefficients(2);  % Slope
        
        % Calculate predictions
        predictions = X * coefficients;
        
        % Calculate statistics
        residuals = tempAvg - predictions;
        SSE = sum(residuals.^2);
        SST = sum((tempAvg - mean(tempAvg)).^2);
        rSquared = 1 - (SSE / SST);
        RMSE = sqrt(mean(residuals.^2));
        
        % Determine trend
        if abs(m) < 0.01
            trendText = 'stable (no significant change)';
        elseif m > 0
            trendText = sprintf('warming (%.4f°C per day)', m);
        else
            trendText = sprintf('cooling (%.4f°C per day)', abs(m));
        end
        
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
        
        htmlComponent.Data = result;
        
        sendStatusUpdate(htmlComponent, 'Regression analysis complete!', 'success');
        
    catch ME
        sendStatusUpdate(htmlComponent, sprintf('Regression error: %s', ME.message), 'error');
    end
end

function sendStatusUpdate(htmlComponent, message, type)
    % Send status update to HTML
    status = struct('action', 'status', 'message', message, 'type', type);
    htmlComponent.Data = status;
end
