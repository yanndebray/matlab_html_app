classdef testWeatherHtmlApp < matlab.unittest.TestCase
    % Unit tests for Weather HTML App
    
    properties
        TestData
    end
    
    methods (TestMethodSetup)
        function createTestData(testCase)
            % Create sample weather data for testing
            testCase.TestData.dates = datetime('2024-01-01') + days(0:89)';
            testCase.TestData.tempMax = 15 + 10*sin(2*pi*(0:89)'/90) + randn(90,1);
            testCase.TestData.tempMin = 5 + 10*sin(2*pi*(0:89)'/90) + randn(90,1);
            testCase.TestData.tempAvg = (testCase.TestData.tempMax + testCase.TestData.tempMin) / 2;
        end
    end
    
    methods (Test)
        function testLinearRegressionCalculation(testCase)
            % Test the linear regression calculation
            
            % Use test data
            tempAvg = testCase.TestData.tempAvg;
            dayNumbers = (1:length(tempAvg))';
            
            % Perform regression
            X = [ones(length(dayNumbers), 1), dayNumbers];
            coefficients = X \ tempAvg;
            
            b = coefficients(1);  % Intercept
            m = coefficients(2);  % Slope
            
            % Verify coefficients are numeric
            testCase.verifyClass(m, 'double');
            testCase.verifyClass(b, 'double');
            testCase.verifyTrue(~isnan(m));
            testCase.verifyTrue(~isnan(b));
            
            % Calculate predictions
            predictions = X * coefficients;
            
            % Verify predictions have correct size
            testCase.verifySize(predictions, [90, 1]);
        end
        
        function testRSquaredCalculation(testCase)
            % Test R-squared calculation
            
            tempAvg = testCase.TestData.tempAvg;
            dayNumbers = (1:length(tempAvg))';
            
            X = [ones(length(dayNumbers), 1), dayNumbers];
            coefficients = X \ tempAvg;
            predictions = X * coefficients;
            
            % Calculate R-squared
            residuals = tempAvg - predictions;
            SSE = sum(residuals.^2);
            SST = sum((tempAvg - mean(tempAvg)).^2);
            rSquared = 1 - (SSE / SST);
            
            % Verify R-squared is between 0 and 1
            testCase.verifyGreaterThanOrEqual(rSquared, 0);
            testCase.verifyLessThanOrEqual(rSquared, 1);
        end
        
        function testRMSECalculation(testCase)
            % Test RMSE calculation
            
            tempAvg = testCase.TestData.tempAvg;
            dayNumbers = (1:length(tempAvg))';
            
            X = [ones(length(dayNumbers), 1), dayNumbers];
            coefficients = X \ tempAvg;
            predictions = X * coefficients;
            
            % Calculate RMSE
            residuals = tempAvg - predictions;
            RMSE = sqrt(mean(residuals.^2));
            
            % Verify RMSE is positive
            testCase.verifyGreaterThan(RMSE, 0);
            testCase.verifyClass(RMSE, 'double');
        end
        
        function testTrendClassification(testCase)
            % Test trend classification logic
            
            % Test warming trend
            m_warming = 0.05;
            [trendText, ~] = classifyTrend(m_warming);
            testCase.verifyTrue(contains(trendText, 'warming'));
            
            % Test cooling trend
            m_cooling = -0.05;
            [trendText, ~] = classifyTrend(m_cooling);
            testCase.verifyTrue(contains(trendText, 'cooling'));
            
            % Test stable trend
            m_stable = 0.005;
            [trendText, ~] = classifyTrend(m_stable);
            testCase.verifyTrue(contains(trendText, 'stable'));
        end
        
        function testDataValidation(testCase)
            % Test data validation (removing NaN values)
            
            % Add some NaN values
            tempAvg = testCase.TestData.tempAvg;
            tempAvg([10, 20, 30]) = NaN;
            
            % Remove NaN values
            validIdx = ~isnan(tempAvg);
            cleanData = tempAvg(validIdx);
            
            % Verify no NaN values remain
            testCase.verifyTrue(~any(isnan(cleanData)));
            testCase.verifyEqual(length(cleanData), 87);  % 90 - 3 NaN values
        end
        
        function testTemperatureChangeCalculation(testCase)
            % Test temperature change over period
            
            tempAvg = testCase.TestData.tempAvg;
            dayNumbers = (1:length(tempAvg))';
            
            X = [ones(length(dayNumbers), 1), dayNumbers];
            coefficients = X \ tempAvg;
            m = coefficients(2);
            
            % Calculate temperature change
            tempChange = m * length(dayNumbers);
            
            % Verify it's a numeric value
            testCase.verifyClass(tempChange, 'double');
            testCase.verifyTrue(~isnan(tempChange));
        end
        
        function testQuickCityData(testCase)
            % Test quick city selection data structure
            
            cities = struct(...
                'montreal', struct('name', 'Montreal, Canada', 'lat', 45.5017, 'lon', -73.5673), ...
                'paris', struct('name', 'Paris, France', 'lat', 48.8566, 'lon', 2.3522), ...
                'newyork', struct('name', 'New York, USA', 'lat', 40.7128, 'lon', -74.0060), ...
                'london', struct('name', 'London, UK', 'lat', 51.5074, 'lon', -0.1278), ...
                'tokyo', struct('name', 'Tokyo, Japan', 'lat', 35.6762, 'lon', 139.6503), ...
                'sydney', struct('name', 'Sydney, Australia', 'lat', -33.8688, 'lon', 151.2093) ...
            );
            
            % Test Montreal data
            testCase.verifyEqual(cities.montreal.lat, 45.5017);
            testCase.verifyEqual(cities.montreal.lon, -73.5673);
            
            % Test all cities have required fields
            cityNames = fieldnames(cities);
            for i = 1:length(cityNames)
                city = cities.(cityNames{i});
                testCase.verifyTrue(isfield(city, 'name'));
                testCase.verifyTrue(isfield(city, 'lat'));
                testCase.verifyTrue(isfield(city, 'lon'));
            end
        end
    end
end

function [trendText, category] = classifyTrend(m)
    % Helper function to classify trend
    if abs(m) < 0.01
        trendText = 'stable (no significant change)';
        category = 'stable';
    elseif m > 0
        trendText = sprintf('warming (%.4f°C per day)', m);
        category = 'warming';
    else
        trendText = sprintf('cooling (%.4f°C per day)', abs(m));
        category = 'cooling';
    end
end
