# 🐛 Weather HTML App - Debugging Guide

## Problem: Buttons Don't Work

If clicking buttons doesn't do anything, follow this debugging process:

## Step 1: Run Debug Version

Launch the debug version with extensive logging:

```matlab
cd('c:\Users\ydebray\Downloads\montreal\vscode')
weather_html_app_debug
```

## Step 2: Watch MATLAB Console

After launching, you should see in MATLAB console:

```
=== DEBUG MODE - Weather HTML App ===
Timestamp: 12-Nov-2024 14:23:45

[DEBUG] Creating uifigure...
[DEBUG] ✓ Figure created
[DEBUG] HTML file path: C:\Users\...\weather_html_app_debug.html
[DEBUG] ✓ HTML file exists
[DEBUG] Creating uihtml component...
[DEBUG] ✓ uihtml component created
[DEBUG] Setting up DataChangedFcn callback...
[DEBUG] ✓ Callback registered
[DEBUG] Waiting for HTML to load...
[DEBUG] Sending test message to HTML...

=== DEBUG SETUP COMPLETE ===
```

**✅ If you see this:** MATLAB side is working!

**❌ If you don't see this:** Problem is with MATLAB setup

## Step 3: Open Browser Console

1. Click anywhere in the HTML window
2. Press **F12** (or right-click → Inspect)
3. Click **Console** tab
4. You should see:

```javascript
[DEBUG] Script loading...
[DEBUG] Timestamp: 2024-11-12T...
[DEBUG] DOM Content Loaded
[DEBUG] Dates initialized
```

**✅ If you see this:** HTML side is loading!

**❌ If console is empty:** HTML not loading properly

## Step 4: Test Button Click

Click the **Montreal 🍁** button and watch BOTH windows:

### In Browser Console (F12):
```javascript
[DEBUG] selectCity() called with: montreal
[DEBUG] Sending data: {action: "quickSelect", city: "montreal"}
[DEBUG] sendToMATLAB() called
[DEBUG] typeof htmlComponent: object
[DEBUG] htmlComponent defined: true
[DEBUG] htmlComponent object: [object Object]
[DEBUG] Setting htmlComponent.Data...
[DEBUG] ✓ Data sent successfully!
```

### In MATLAB Console:
```
[DEBUG] ===== DATA CHANGE EVENT RECEIVED =====
[DEBUG] Timestamp: 12-Nov-2024 14:25:10
[DEBUG] Event.Data class: struct
[DEBUG] Data received:
    action: 'quickSelect'
      city: 'montreal'
[DEBUG] Action detected: quickSelect
[DEBUG] Calling handleQuickSelect...
[DEBUG] handleQuickSelect called
[DEBUG] City requested: montreal
[DEBUG] City found: Montreal, Canada (45.5017, -73.5673)
```

## Common Issues & Solutions

### Issue 1: `htmlComponent is not defined`

**Console shows:**
```javascript
[ERROR] htmlComponent is not defined!
```

**Cause:** HTML-MATLAB bridge not initialized

**Solution:**
The issue is that `uihtml` doesn't automatically expose `htmlComponent` to JavaScript. You need to explicitly set it up.

**Fix the original file** (`weather_html_app.html`):

Add this right after `<script type="text/javascript">`:

```javascript
// Global variable to store the component
var htmlComponent;

// This function will be called by MATLAB
window.setup = function(component) {
    console.log('Setup called with component:', component);
    htmlComponent = component;
    
    // Listen for data changes from MATLAB
    htmlComponent.addEventListener("DataChanged", function(event) {
        console.log('Data received from MATLAB:', event.Data);
        handleMATLABData(event.Data);
    });
};
```

Then in the MATLAB file, after creating `htmlComponent`, add:

```matlab
% Execute the setup function in HTML
htmlComponent.HTMLSource = htmlFile;
pause(0.5);  % Wait for HTML to load

% Call setup function to initialize JavaScript
htmlComponent.executeScript('window.setup(htmlComponent);');
```

### Issue 2: No DataChanged Events

**Symptom:** Nothing happens when clicking buttons, no errors

**Debugging:**
1. In browser console, type: `typeof htmlComponent`
2. Should show: `"object"`
3. If `"undefined"`, the bridge isn't set up

**Solution:** See Issue 1 above

### Issue 3: MATLAB Not Receiving Data

**Browser console shows data sent, but MATLAB console silent**

**Check:**
1. Is `DataChangedFcn` callback registered?
2. Run: `get(htmlComponent, 'DataChangedFcn')`
3. Should show function handle

**Solution:**
```matlab
% Re-register callback
htmlComponent.DataChangedFcn = @(src, event) handleDataChange(fig, event);
```

### Issue 4: HTML File Not Found

**Error:** `HTML file not found! Expected at: ...`

**Solution:**
1. Verify both files in same directory:
   - `weather_html_app.m`
   - `weather_html_app.html`
2. Check file names match exactly (case-sensitive on some systems)

## Quick Test Script

Run this to test if `uihtml` works at all:

```matlab
% Minimal test
fig = uifigure('Name', 'Test');
html = uihtml(fig);
html.Position = [10 10 300 200];
html.HTMLSource = '<html><body><h1>Test</h1><button onclick="alert(''Works!'')">Click</button></body></html>';
```

If this shows a button that works, `uihtml` is functional.

## The Real Fix

Based on MATLAB documentation for `uihtml`, the correct pattern is:

### In MATLAB (weather_html_app.m):

```matlab
% After creating htmlComponent
htmlComponent.HTMLSource = htmlFile;
pause(1.0);  % Give HTML time to load

% Pass the component to JavaScript
htmlComponent.executeScript(['window.htmlComponent = htmlComponent;']);
```

OR use the **Data property** bidirectionally as designed.

### Alternative: Use setup callback

In HTML, instead of accessing global `htmlComponent`, receive it as parameter:

```javascript
// Remove the sendToMATLAB checks
function sendToMATLAB(data) {
    // Direct access - assumes component is available
    window.htmlComponent.Data = data;
}
```

## Expected Behavior

When everything works:

1. **Click Montreal button**
   - Browser: Logs show data sent
   - MATLAB: Logs show data received
   - UI: Latitude/longitude fields update
   - Status: "Selected: Montreal, Canada" appears

2. **Click Fetch Data**
   - Status: "Fetching weather data..."
   - MATLAB: API call logs
   - Status: "Successfully fetched N days"
   - Data cards populate with numbers

3. **Click Perform Regression**
   - Status: "Performing linear regression..."
   - MATLAB: Calculation logs
   - Results section appears
   - Equation and statistics display

## Still Not Working?

Try this minimal working example:

```matlab
function test_uihtml()
    fig = uifigure('Position', [100 100 400 300]);
    h = uihtml(fig);
    h.Position = [10 10 380 280];
    
    htmlCode = ['<html><body>' ...
        '<h2>Test</h2>' ...
        '<button onclick="sendData()">Click Me</button>' ...
        '<div id="result"></div>' ...
        '<script>' ...
        'function sendData() {' ...
        '  console.log("Button clicked");' ...
        '  if (typeof htmlComponent !== "undefined") {' ...
        '    htmlComponent.Data = {test: "Hello from HTML"};' ...
        '  } else {' ...
        '    document.getElementById("result").innerText = "ERROR: htmlComponent not defined";' ...
        '  }' ...
        '}' ...
        '</script></body></html>'];
    
    h.HTMLSource = htmlCode;
    h.DataChangedFcn = @(src, evt) disp(evt.Data);
end
```

If this doesn't work, there may be a MATLAB version issue with `uihtml`.

## Check MATLAB Version

```matlab
>> version
```

`uihtml` requires **R2019b or later**. If you have an older version, you'll need to use traditional MATLAB UI components instead.
