# Quick Start Guide - Weather HTML App

## 🚀 Launch the App

Open MATLAB and run:
```matlab
cd('c:\Users\ydebray\Downloads\montreal\vscode')
weather_html_app
```

## 📋 Step-by-Step Usage

### Step 1: Choose Location
**Option A - Quick Select:**
- Click one of the city buttons: Montreal 🍁, Paris 🗼, New York 🗽, etc.

**Option B - Custom Location:**
- Enter latitude (e.g., 45.5017 for Montreal)
- Enter longitude (e.g., -73.5673 for Montreal)

### Step 2: Set Date Range
- Start Date: Select the beginning of your analysis period
- End Date: Select the end of your analysis period
- Default: Last 3 months

### Step 3: Fetch Data
- Click "📥 Fetch Weather Data"
- Wait for the status message
- View the data summary with statistics

### Step 4: Analyze Trends
- Click "📊 Perform Regression"
- View the linear regression results:
  - **Slope (m)**: Rate of temperature change per day
  - **Intercept (b)**: Starting temperature value
  - **R² Score**: How well the model fits (closer to 1 = better)
  - **RMSE**: Average prediction error
  - **Trend**: Warming, cooling, or stable
  - **Total Change**: Temperature change over the entire period

## 📊 Understanding the Results

### Regression Equation
```
Temperature = m × Day + b
```
- **m (slope)**: If positive → warming trend, if negative → cooling trend
- **b (intercept)**: Average starting temperature

### R² Score
- **> 0.8**: Excellent fit - strong linear trend
- **0.5 - 0.8**: Good fit - moderate linear trend
- **< 0.5**: Poor fit - weak or no linear trend

### RMSE (Root Mean Square Error)
- Average error in temperature predictions
- Lower is better
- Typical range: 1-5°C for weather data

## 🌍 Pre-configured Cities

| City | Latitude | Longitude |
|------|----------|-----------|
| Montreal | 45.5017 | -73.5673 |
| Paris | 48.8566 | 2.3522 |
| New York | 40.7128 | -74.0060 |
| London | 51.5074 | -0.1278 |
| Tokyo | 35.6762 | 139.6503 |
| Sydney | -33.8688 | 151.2093 |

## 💡 Tips

1. **Date Range**: 30-90 days works best for trend analysis
2. **Seasonal Trends**: Longer periods show seasonal patterns better
3. **API Limits**: Free API, but avoid too frequent requests
4. **R² Score**: If low, data may have high variability or non-linear trend
5. **Interpretation**: Small slopes (< 0.01) indicate stable temperatures

## 🔧 Troubleshooting

**Problem**: "Error fetching data"
- **Solution**: Check internet connection, verify dates are not in the future

**Problem**: "No data available"
- **Solution**: Click "Fetch Weather Data" first before running regression

**Problem**: Low R² score
- **Solution**: This is normal for weather data with high variability

**Problem**: App doesn't open
- **Solution**: Ensure MATLAB R2019b or later, check HTML file is in same folder

## 📁 Files Required

Both files must be in the same directory:
- `weather_html_app.m` (MATLAB code)
- `weather_html_app.html` (HTML interface)

## 🧪 Run Tests

To verify the app works correctly:
```matlab
cd('c:\Users\ydebray\Downloads\montreal\tests')
runtests('testWeatherHtmlApp')
```

## 📖 More Information

See `README_weather_html_app.md` for detailed technical documentation.
