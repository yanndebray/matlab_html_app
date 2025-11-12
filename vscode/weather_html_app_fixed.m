function weather_html_app_fixed()
    % Weather Linear Regression App with HTML UI - FIXED VERSION
    % This version properly initializes the HTML-MATLAB bridge
    
    % Create main figure
    fig = uifigure('Name', 'Weather Regression Analysis [FIXED]', ...
                   'Position', [100, 100, 1000, 900]);
    
    % Get the path to the HTML file
    htmlFile = fullfile(fileparts(mfilename('fullpath')), 'weather_html_app_fixed.html');
    
    if ~exist(htmlFile, 'file')
        error('HTML file not found: %s', htmlFile);
    end
    
    % Create uihtml component
    htmlComponent = uihtml(fig);
    htmlComponent.Position = [0 0 fig.Position(3) fig.Position(4)];
    
    % Store app data in figure BEFORE loading HTML
    fig.UserData.htmlComponent = htmlComponent;
    fig.UserData.weatherData = struct();
    
    % Setup data changed callback BEFORE loading HTML
    htmlComponent.DataChangedFcn = @(src, event) handleDataChange(fig, event);
    
    % NOW load the HTML
    htmlComponent.HTMLSource = htmlFile;
    
    % Give HTML time to initialize
    pause(1.5);
    
    % Send test message
    sendStatusUpdate(htmlComponent, 'App initialized successfully!', 'success');
    
    fprintf('App launched. If buttons don''t work:\n');
    fprintf('1. Right-click in the window and select "Inspect" or press F12\n');
    fprintf('2. Click the Console tab\n');
    fprintf('3. Look for any error messages\n');
    fprintf('4. Try clicking a button and watch for log messages\n\n');
end

function handleDataChange(fig, event)
    htmlComponent = fig.UserData.htmlComponent;
    data = event.Data;
    
    if isempty(data)
        return;
    end
    
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
        
        result = struct('action', 'updateLocation', ...
                       'cityName', cityData.name, ...
                       'latitude', cityData.lat, ...
                       'longitude', cityData.lon);
        htmlComponent.Data = result;
        
        sendStatusUpdate(htmlComponent, sprintf('Selected: %s', cityData.name), 'success');
    end
end

function fetchWeatherData(fig, data)
    htmlComponent = fig.UserData.htmlComponent;
    
    try
        latitude = data.latitude;
        longitude = data.longitude;
        startDate = data.startDate;
        endDate = data.endDate;
        
        sendStatusUpdate(htmlComponent, 'Fetching weather data...', 'info');
        
        url = sprintf(['https://archive-api.open-meteo.com/v1/archive?' ...
            'latitude=%.4f&longitude=%.4f&start_date=%s&end_date=%s&' ...
            'daily=temperature_2m_max,temperature_2m_min,precipitation_sum&' ...
            'timezone=auto'], latitude, longitude, startDate, endDate);
        
        apiData = webread(url);
        
        dates = datetime(apiData.daily.time, 'InputFormat', 'yyyy-MM-dd');
        tempMax = apiData.daily.temperature_2m_max;
        tempMin = apiData.daily.temperature_2m_min;
        precipitation = apiData.daily.precipitation_sum;
        tempAvg = (tempMax + tempMin) / 2;
        
        fig.UserData.weatherData.dates = dates;
        fig.UserData.weatherData.tempMax = tempMax;
        fig.UserData.weatherData.tempMin = tempMin;
        fig.UserData.weatherData.tempAvg = tempAvg;
        fig.UserData.weatherData.precipitation = precipitation;
        fig.UserData.weatherData.latitude = latitude;
        fig.UserData.weatherData.longitude = longitude;
        
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
    htmlComponent = fig.UserData.htmlComponent;
    weatherData = fig.UserData.weatherData;
    
    if ~isfield(weatherData, 'tempAvg') || isempty(weatherData.tempAvg)
        sendStatusUpdate(htmlComponent, 'No data available. Please fetch data first.', 'error');
        return;
    end
    
    try
        sendStatusUpdate(htmlComponent, 'Performing linear regression...', 'info');
        
        dates = weatherData.dates;
        tempAvg = weatherData.tempAvg;
        
        validIdx = ~isnan(tempAvg);
        dates = dates(validIdx);
        tempAvg = tempAvg(validIdx);
        
        dayNumbers = (1:length(dates))';
        
        X = [ones(length(dayNumbers), 1), dayNumbers];
        coefficients = X \ tempAvg;
        
        b = coefficients(1);
        m = coefficients(2);
        
        predictions = X * coefficients;
        
        residuals = tempAvg - predictions;
        SSE = sum(residuals.^2);
        SST = sum((tempAvg - mean(tempAvg)).^2);
        rSquared = 1 - (SSE / SST);
        RMSE = sqrt(mean(residuals.^2));
        
        if abs(m) < 0.01
            trendText = 'stable (no significant change)';
        elseif m > 0
            trendText = sprintf('warming (%.4f°C per day)', m);
        else
            trendText = sprintf('cooling (%.4f°C per day)', abs(m));
        end
        
        tempChange = m * length(dayNumbers);
        
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
    status = struct('action', 'status', 'message', message, 'type', type);
    htmlComponent.Data = status;
end
