# 🔧 SOLUTION: Buttons Not Working - HTML-MATLAB Bridge Issue

## The Problem

When clicking buttons in the HTML interface, nothing happens because the `htmlComponent` object is not accessible to JavaScript.

## Root Cause

The `uihtml` component in MATLAB automatically calls a `setup()` function in your HTML (if it exists), passing the component as a parameter. However, the original code tried to access a global `htmlComponent` variable that was never defined.

## The Fix

### Three Versions Available:

1. **`weather_html_app_fixed.m/.html`** - Working version with proper setup ✅
2. **`weather_html_app_debug.m/.html`** - Debug version with extensive logging 🐛
3. **`weather_html_app.m/.html`** - Original (needs manual fix) ❌

## Quick Start: Use the Fixed Version

```matlab
cd('c:\Users\ydebray\Downloads\montreal\vscode')
weather_html_app_fixed
```

This should work immediately!

## What Was Fixed?

### In HTML (weather_html_app_fixed.html):

**Before (BROKEN):**
```javascript
function sendToMATLAB(data) {
    if (typeof htmlComponent !== 'undefined') {  // ❌ htmlComponent never defined!
        htmlComponent.Data = data;
    }
}
```

**After (FIXED):**
```javascript
// Store the component when MATLAB calls setup()
function setup(htmlComponent) {
    window.matlabComponent = htmlComponent;  // ✅ Save globally!
    
    htmlComponent.addEventListener("DataChanged", function(event) {
        handleMATLABData(event.Data);
    });
}

function sendToMATLAB(data) {
    if (typeof window.matlabComponent !== 'undefined') {
        window.matlabComponent.Data = data;  // ✅ Use saved component!
    }
}
```

### In MATLAB (weather_html_app_fixed.m):

**Key Changes:**
```matlab
% Setup callback BEFORE loading HTML
htmlComponent.DataChangedFcn = @(src, event) handleDataChange(fig, event);

% THEN load HTML
htmlComponent.HTMLSource = htmlFile;

% Give it time to initialize
pause(1.5);
```

## How to Fix Your Original Files

If you want to fix the original `weather_html_app.m/.html` instead of using the fixed version:

### Step 1: Edit weather_html_app.html

Find this section:
```javascript
function setup(htmlComponent) {
    htmlComponent.addEventListener("DataChanged", function(event) {
        handleMATLABData(event.Data);
    });
}
```

Replace with:
```javascript
function setup(htmlComponent) {
    console.log('setup() called - saving component');
    window.matlabComponent = htmlComponent;
    
    htmlComponent.addEventListener("DataChanged", function(event) {
        handleMATLABData(event.Data);
    });
}
```

### Step 2: Still in weather_html_app.html

Find this function:
```javascript
function sendToMATLAB(data) {
    if (typeof htmlComponent !== 'undefined') {
        htmlComponent.Data = data;
    }
}
```

Replace with:
```javascript
function sendToMATLAB(data) {
    if (typeof window.matlabComponent !== 'undefined') {
        window.matlabComponent.Data = data;
    } else {
        console.error('MATLAB component not initialized');
    }
}
```

### Step 3: Test!

```matlab
weather_html_app
```

Click the Montreal button - it should work now!

## Debugging Steps

If it still doesn't work after fixing:

### 1. Run Debug Version
```matlab
weather_html_app_debug
```

### 2. Open Browser Console
- Click in HTML window
- Press **F12**
- Go to **Console** tab

### 3. Click Montreal Button

You should see:
```
[SETUP] Called by MATLAB with component: [object Object]
[HTML→MATLAB] selectCity: montreal
[SEND] Attempting to send: {action: "quickSelect", city: "montreal"}
[SEND] Component exists: true
[SEND] Sending via Data property...
[SEND] ✓ Sent successfully
```

### 4. Check MATLAB Console

You should see:
```
[DEBUG] ===== DATA CHANGE EVENT RECEIVED =====
[DEBUG] Action detected: quickSelect
[DEBUG] City requested: montreal
[DEBUG] City found: Montreal, Canada (45.5017, -73.5673)
```

## Common Error Messages

### "htmlComponent is not defined"
**Cause:** setup() function not called or component not saved  
**Solution:** Use the fixed version or apply manual fixes above

### "MATLAB component not initialized"
**Cause:** setup() hasn't run yet  
**Solution:** Add `pause(1.5)` after loading HTML in MATLAB

### No error but nothing happens
**Cause:** DataChangedFcn not registered  
**Solution:** Register callback BEFORE loading HTML

## Testing the Fix

### Test 1: Quick City Selection
1. Click "Montreal 🍁"
2. Latitude should change to 45.5017
3. Longitude should change to -73.5673
4. Status should say "Selected: Montreal, Canada"

### Test 2: Fetch Data
1. Keep Montreal coordinates
2. Click "Fetch Weather Data"
3. Should see "Fetching..." then "Successfully fetched..."
4. Data cards should show numbers

### Test 3: Regression
1. After fetching data, click "Perform Regression"
2. Should see "Performing..." then "complete!"
3. Results section appears with equation and stats

## Why This Happens

MATLAB's `uihtml` component uses a specific initialization pattern:

1. MATLAB creates the uihtml component
2. MATLAB loads your HTML file
3. MATLAB automatically looks for a `setup()` function
4. If found, MATLAB calls `setup(htmlComponent)` 
5. Your HTML must save this parameter to use later

The original code assumed `htmlComponent` would be a global variable, but it's only available as a parameter to `setup()`.

## Files Summary

| File | Status | Purpose |
|------|--------|---------|
| `weather_html_app_fixed.m` | ✅ Working | Use this! |
| `weather_html_app_fixed.html` | ✅ Working | Goes with above |
| `weather_html_app_debug.m` | 🐛 Debug | For troubleshooting |
| `weather_html_app_debug.html` | 🐛 Debug | With console logs |
| `weather_html_app.m` | ❌ Broken | Needs manual fix |
| `weather_html_app.html` | ❌ Broken | Needs manual fix |
| `DEBUG_GUIDE.md` | 📘 Doc | Debugging instructions |
| `SOLUTION.md` | 📘 Doc | This file |

## Next Steps

1. **Try the fixed version:**
   ```matlab
   weather_html_app_fixed
   ```

2. **If it works:** You're done! 🎉

3. **If not:** Run debug version and follow DEBUG_GUIDE.md

4. **Still stuck:** Check MATLAB version (needs R2019b+)

## Prevention for Future Apps

When creating new apps with `uihtml`, always use this pattern:

**In HTML:**
```javascript
var matlabComponent;  // Global variable

function setup(component) {
    matlabComponent = component;  // Save it!
    // ... setup event listeners ...
}

function sendData(data) {
    matlabComponent.Data = data;  // Use it!
}
```

**In MATLAB:**
```matlab
% Create component
htmlComp = uihtml(fig);

% Register callback FIRST
htmlComp.DataChangedFcn = @myCallback;

% Load HTML AFTER
htmlComp.HTMLSource = myHtmlFile;

% Wait for initialization
pause(1.0);
```

This ensures the bridge is properly established before any user interaction.
