# Weather HTML App - Visual Guide

## 🎨 App Screenshots (Text Descriptions)

### Main Interface
```
╔══════════════════════════════════════════════════════════════╗
║     🌤️ Weather Linear Regression Analysis                    ║
║   Analyze temperature trends with machine learning            ║
║                  powered by MATLAB                            ║
╠══════════════════════════════════════════════════════════════╣
║                                                              ║
║  🌍 Quick City Selection                                     ║
║  ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌─────────┐             ║
║  │Montreal│ │  Paris  │ │New York │ │ London  │          ║
║  │   🍁   │ │   🗼    │ │   🗽    │ │   🎡   │          ║
║  └─────────┘ └─────────┘ └─────────┘ └─────────┘          ║
║  ┌─────────┐ ┌─────────┐                                    ║
║  │  Tokyo  │ │ Sydney  │                                    ║
║  │   🗾   │ │   🦘    │                                    ║
║  └─────────┘ └─────────┘                                    ║
║                                                              ║
║  📍 Location & Date Range                                    ║
║  Latitude:  [45.5017    ] Longitude: [-73.5673  ]          ║
║  Start:     [2024-08-15 ] End:       [2024-11-12]          ║
║                                                              ║
║  [ 📥 Fetch Weather Data ] [ 📊 Perform Regression ]        ║
║                                                              ║
║  ℹ️ Status: Ready to fetch data...                          ║
║                                                              ║
╚══════════════════════════════════════════════════════════════╝
```

### After Fetching Data
```
╔══════════════════════════════════════════════════════════════╗
║  📊 Weather Data Summary                                     ║
║  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐       ║
║  │ Data Points  │ │  Avg Temp    │ │  Max Temp    │       ║
║  │     90       │ │   12.3°C     │ │   18.5°C     │       ║
║  └──────────────┘ └──────────────┘ └──────────────┘       ║
║  ┌──────────────┐                                          ║
║  │  Min Temp    │                                          ║
║  │   5.2°C      │                                          ║
║  └──────────────┘                                          ║
║                                                             ║
║  ✅ Successfully fetched 90 days of data                    ║
╚══════════════════════════════════════════════════════════════╝
```

### After Regression Analysis
```
╔══════════════════════════════════════════════════════════════╗
║  📈 Linear Regression Results                                ║
║                                                              ║
║         Temperature = -0.0823 × Day + 18.45                 ║
║                                                              ║
║  ┌──────────────┐ ┌──────────────┐ ┌──────────────┐       ║
║  │  Slope (m)   │ │ Intercept(b) │ │  R² Score    │       ║
║  │  -0.0823     │ │    18.45     │ │   0.8234     │       ║
║  └──────────────┘ └──────────────┘ └──────────────┘       ║
║  ┌──────────────┐                                          ║
║  │    RMSE      │                                          ║
║  │   2.45°C     │                                          ║
║  └──────────────┘                                          ║
║                                                             ║
║  Trend Analysis:                                           ║
║  🔵 cooling (0.0823°C per day)                             ║
║                                                             ║
║  Temperature Change:                                        ║
║  📉 Temperature decreased by 7.41°C over the period        ║
║                                                             ║
║  ✅ Regression analysis complete!                           ║
╚══════════════════════════════════════════════════════════════╝
```

## 🎨 Color Scheme

### Gradient Background
```
Primary: #667eea → #764ba2 (Purple-Blue gradient)
```

### UI Elements
- **Buttons**: Purple gradient with hover effects
- **Input Fields**: White with purple focus border
- **Cards**: White background with subtle shadows
- **Status Messages**:
  - Info: Blue (#d1ecf1)
  - Success: Green (#d4edda)
  - Error: Red (#f8d7da)

### Typography
- **Headers**: Segoe UI, bold, 32px
- **Body**: Segoe UI, 14-16px
- **Stats**: 28px, bold, purple (#667eea)

## 📱 Responsive Design

### Grid Layout
```
┌─────────────────────────────────────────┐
│  Quick Cities (Auto-fit grid)          │
│  Min: 150px, Max: 1fr                  │
├─────────────────────────────────────────┤
│  Location Inputs (4-column grid)       │
│  Min: 200px, Max: 1fr                  │
├─────────────────────────────────────────┤
│  Stats Cards (Auto-fit grid)           │
│  Min: 200px, Max: 1fr                  │
└─────────────────────────────────────────┘
```

## 🔄 User Flow Diagram

```
START
  │
  ▼
┌─────────────────┐
│ Open App        │
└────────┬────────┘
         │
         ▼
┌─────────────────┐      ┌──────────────────┐
│ Quick Select    │ OR   │ Manual Entry     │
│ City Button     │      │ Lat/Lon & Dates  │
└────────┬────────┘      └────────┬─────────┘
         │                        │
         └────────┬───────────────┘
                  ▼
         ┌─────────────────┐
         │ Click "Fetch    │
         │ Weather Data"   │
         └────────┬────────┘
                  │
                  ▼
         ┌─────────────────┐
         │ MATLAB fetches  │
         │ data from API   │
         └────────┬────────┘
                  │
                  ▼
         ┌─────────────────┐
         │ View Data       │
         │ Summary         │
         └────────┬────────┘
                  │
                  ▼
         ┌─────────────────┐
         │ Click "Perform  │
         │ Regression"     │
         └────────┬────────┘
                  │
                  ▼
         ┌─────────────────┐
         │ MATLAB computes │
         │ linear regression│
         └────────┬────────┘
                  │
                  ▼
         ┌─────────────────┐
         │ View Results    │
         │ & Trend Analysis│
         └────────┬────────┘
                  │
                  ▼
                 END
```

## 🔧 Component Breakdown

### HTML Structure
```html
body
└── container
    ├── header
    │   ├── h1 (title)
    │   └── p (subtitle)
    └── content
        ├── section (Quick Cities)
        │   └── quick-cities grid
        │       └── city-btn (×6)
        ├── section (Location & Dates)
        │   ├── input-group
        │   │   ├── latitude input
        │   │   ├── longitude input
        │   │   ├── startDate input
        │   │   └── endDate input
        │   ├── buttons
        │   └── status div
        ├── section (Data Summary)
        │   └── stats-grid
        │       └── stat-card (×4)
        └── section (Regression Results)
            ├── equation display
            ├── stats-grid
            │   └── stat-card (×4)
            └── chart-placeholder
                └── trend analysis
```

### MATLAB Structure
```matlab
weather_html_app()
├── Create uifigure
├── Create uihtml component
├── Load HTML file
└── Setup callbacks
    ├── handleDataChange()
    │   ├── fetchWeatherData()
    │   ├── performLinearRegression()
    │   └── handleQuickSelect()
    └── sendStatusUpdate()
```

## 📊 Data Flow

### HTML → MATLAB
```javascript
User Action
    ↓
JavaScript Event Handler
    ↓
Prepare Data Object
    ↓
htmlComponent.Data = {...}
    ↓
MATLAB Receives Event
    ↓
DataChangedFcn Triggered
    ↓
handleDataChange() Routes Action
```

### MATLAB → HTML
```matlab
MATLAB Computation
    ↓
Prepare Result Struct
    ↓
htmlComponent.Data = result
    ↓
JavaScript Receives Data
    ↓
handleMATLABData() Routes Action
    ↓
Update UI Elements
    ↓
User Sees Results
```

## 🎯 Key Interactions

### Button Hover Effect
```css
Default State:
  - Gradient background
  - No transform

Hover State:
  - Move up 2px (translateY(-2px))
  - Box shadow (0 8px 20px rgba(...))
  - Smooth 0.2s transition
```

### Input Focus Effect
```css
Default State:
  - Border: 2px solid #e0e0e0
  - No outline

Focus State:
  - Border: 2px solid #667eea (purple)
  - Smooth 0.3s transition
```

### Status Messages
```css
Info: Blue background, dark blue text
Success: Green background, dark green text
Error: Red background, dark red text

Animation: Fade in when displayed
```

## 📏 Dimensions

- **Container**: max-width 1200px
- **Header**: padding 30px
- **Sections**: padding 25px, margin 30px
- **Cards**: padding 20px
- **Buttons**: padding 14px×30px
- **Inputs**: padding 12px
- **Border Radius**: 8-20px (varies)

## 🌈 Visual Hierarchy

1. **Primary**: Main title, action buttons
2. **Secondary**: Section titles, city buttons
3. **Tertiary**: Labels, descriptions
4. **Data**: Large stat values, equation

Color intensities guide attention to most important elements.
