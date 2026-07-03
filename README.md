# Nox - Roblox UI Library Documentation

> A comprehensive, Material Design 3 inspired UI library for Roblox with theming, animations, and an extensive component system.

---

## Table of Contents

1. [Getting Started](#getting-started)
2. [Library Setup & Dependencies](#library-setup--dependencies)
3. [Creating a Window](#creating-a-window)
4. [Window Configuration](#window-configuration)
5. [Theming System](#theming-system)
   - [Built-in Themes](#built-in-themes)
   - [Runtime Theme Switching](#runtime-theme-switching)
   - [Custom Themes](#custom-themes)
6. [Tab System](#tab-system)
7. [UI Elements](#ui-elements)
   - [Label](#label)
   - [Section](#section)
   - [Divider](#divider)
   - [Button](#button)
   - [Switch (Toggle)](#switch-toggle)
   - [Slider](#slider)
   - [Dropdown](#dropdown)
   - [TextBox](#textbox)
8. [Dialog System](#dialog-system)
9. [Notification System](#notification-system)
10. [Search Functionality](#search-functionality)
11. [Icon System](#icon-system)
12. [Window Controls](#window-controls)
13. [Internal Architecture](#internal-architecture)
14. [API Reference](#api-reference)
15. [Example Usage](#example-usage)

---

## Getting Started

### Loading the Library

```lua
local NoxLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/fiangg20/nox/refs/heads/main/source.lua"))()
```

### Creating Your First Window

```lua
local NoxLibrary = loadstring(game:HttpGet("https://raw.githubusercontent.com/fiangg20/nox/refs/heads/main/source.lua"))()

local UI = NoxLibrary:Create({
    Title = "My Script Hub",
    SizeX = 400,
    SizeY = 500,
    Theme = "Purple",
    ToggleKey = Enum.KeyCode.RightShift,
    Search = true,
    SearchPlaceholder = "Search elements..."
})
```

---

## Library Setup & Dependencies

NoxLibrary initializes the following Roblox services on load:

| Service | Variable | Purpose |
|---------|----------|---------|
| `TweenService` | `tw` | UI animations and transitions |
| `UserInputService` | `uis` | Input handling (mouse, touch, keyboard) |
| `RunService` | `rs` | Render-stepped tracking for dragging |
| `Players` | `plrs` | Access to LocalPlayer for avatar thumbnails |
| `CoreGui` | `cg` | Parent container for the ScreenGui |
| `HttpService` | `http` | JSON encoding for font configuration |

### Asset Management

On first load, the library:
1. Creates a folder named `NoxAssets` in your executor's workspace
2. Downloads `GoogleSans.ttf` from the remote repository
3. Generates a JSON font configuration file (`m3font.json`)
4. Downloads `MaterialIcons.ttf` (filled icons) and `MaterialIconsOutlined.otf` (outlined icons), along with their JSON configs.
5. Registers the fonts using Roblox's `Font.new()` with `getcustomasset()`

## Icon System

The library loads Material Icons via custom fonts. Icons can be referenced by:
- **Material icon name**: [Material Symbols & Icons](https://fonts.google.com/icons)
- **Direct asset ID**: `"rbxassetid://12345678"`
- **Custom asset**: `"rbxasset://path/to/asset"`

### Internal Icon Mapping
For backward compatibility and ease of use, Nox automatically maps these common icon names to their Material equivalents:
| Input Name | Mapped Material Icon |
|------------|----------------------|
| `x` | `close` |
| `minimize` | `remove` |
| `maximize` | `crop_square` |
| `search` | `search` |
| `chevron-down` | `expand_more` |
| `circle-x` | `cancel` |

If icon loading fails or an invalid name is passed, a warning is printed and icons will not render.

---

## Creating a Window

The `Create` method is the entry point for building your UI.

```lua
local UI = NoxLibrary:Create(config)
```

### Configuration Table

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `Title` | `string` | `"Nox"` | Window title displayed in the header |
| `SizeX` | `number` | `380` | Initial window width in pixels |
| `SizeY` | `number` | `520` | Initial window height in pixels |
| `ToggleKey` | `Enum.KeyCode` | `Enum.KeyCode.K` | Key to toggle minimize/restore |
| `Theme` | `string` | `"Default"` | Initial color theme name |
| `Search` | `boolean` | `false` | Enable the search bar |
| `SearchPlaceholder` | `string` | `"Search..."` | Placeholder text for the search box |
| `OnSearch` | `function` | `nil` | Callback fired on search text change |
| `SearchAvatar` | `string` | Local player's headshot | Avatar image URL for the search bar |

### Return Value

The `Create` method returns a library object (`lib`) containing all methods for building your UI. The library object is a table with the following metatable:

```lua
setmetatable(lib, {
    __index = {
        SetTitle = function(self, newTitle)
            top.Text = newTitle
        end
    }
})
```

This means you can call `UI:SetTitle("New Title")` even though `SetTitle` is defined on the metatable.

---

## Window Configuration

### Window Appearance

The window frame is created with:
- **Background**: Uses the theme's `bg` color
- **Corner Radius**: 16 pixels (`UICorner` with `{0, 16}`)
- **Clips Descendants**: Enabled to prevent content overflow
- **Display Order**: `1000000` (very high to overlay most UIs)
- **ZIndex Behavior**: Sibling-based

### Window Controls

The top-right corner contains two control buttons:

| Button | Icon | Behavior |
|--------|------|----------|
| Minimize/Maximize | `minimize` / `maximize` icon | Toggles between full height and collapsed header-only view |
| Close | `x` icon | Shows confirmation dialog, then plays exit animation and destroys the GUI |

### Toggle Key

If `ToggleKey` is provided, pressing that key (when not captured by the game) toggles the minimize state.

```lua
local UI = NoxLibrary:Create({
    ToggleKey = Enum.KeyCode.RightShift
})
```

### Window Dragging

The entire window can be dragged by clicking and dragging anywhere on the title bar area. The drag system uses:
- `InputBegan` on the window to detect drag start
- `InputChanged` from `UserInputService` to track mouse/touch movement
- `RunService.RenderStepped` to update position smoothly

### Window Resizing

A resize handle (30x30 pixels) is located at the bottom-right corner:
- Minimum window size: 320x400 pixels
- Disabled when window is minimized

---

## Theming System

### Built-in Themes

NoxLibrary includes 6 pre-defined color themes following Material Design 3 principles:

#### Purple (Default Accent)
```
Background:   #1C1B1F  (rgb(28, 27, 31))
Foreground:   #E6E1E5  (rgb(230, 225, 229))
Primary:      #D0BCFF  (rgb(208, 188, 255))
On Primary:   #381E72  (rgb(56, 30, 114))
Inactive:     #2B2930  (rgb(43, 41, 48))
Outline:      #938F99  (rgb(147, 143, 153))
```

#### Blue
```
Background:   #1A1C1E  (rgb(26, 28, 30))
Foreground:   #E2E2E6  (rgb(226, 226, 230))
Primary:      #A2C9FF  (rgb(162, 201, 255))
On Primary:   #00325A  (rgb(0, 50, 90))
Inactive:     #282A2E  (rgb(40, 42, 46))
Outline:      #8D9199  (rgb(141, 145, 153))
```

#### Red
```
Background:   #201A19  (rgb(32, 26, 25))
Foreground:   #EDE0DE  (rgb(237, 224, 222))
Primary:      #FFB4A8  (rgb(255, 180, 168))
On Primary:   #690005  (rgb(105, 0, 5))
Inactive:     #322826  (rgb(50, 40, 38))
Outline:      #A08C89  (rgb(160, 140, 137))
```

#### Green
```
Background:   #1A1C19  (rgb(26, 28, 25))
Foreground:   #E1E3DF  (rgb(225, 227, 223))
Primary:      #8FD787  (rgb(143, 215, 135))
On Primary:   #00390A  (rgb(0, 57, 10))
Inactive:     #282B28  (rgb(40, 43, 40))
Outline:      #8E918F  (rgb(142, 145, 143))
```

#### Orange
```
Background:   #201B18  (rgb(32, 27, 24))
Foreground:   #ECE0DB  (rgb(236, 224, 219))
Primary:      #FFB77B  (rgb(255, 183, 123))
On Primary:   #4C2600  (rgb(76, 38, 0))
Inactive:     #322A26  (rgb(50, 42, 38))
Outline:      #9F8D84  (rgb(159, 141, 132))
```

#### Default (Dark with Purple Accent)
```
Background:   #000000  (rgb(0, 0, 0))
Foreground:   #E6E1E5  (rgb(230, 225, 229))
Primary:      #D0BCFF  (rgb(208, 188, 255))
On Primary:   #381E72  (rgb(56, 30, 114))
Inactive:     #1C1C1E  (rgb(28, 28, 30))
Outline:      #938F99  (rgb(147, 143, 153))
```

### Color Role Definitions

| Role | Purpose |
|------|---------|
| `bg` | Window background, elevated surfaces |
| `fg` | Primary text color |
| `pri` | Primary accent (buttons, active states, indicators) |
| `onpri` | Text/icon color on primary backgrounds |
| `inact` | Inactive/disabled surfaces, input backgrounds |
| `out` | Secondary text, outlines, inactive icons |

### Runtime Theme Switching

Change the entire UI theme at runtime with smooth transitions:

```lua
UI:ChangePalette("Blue")
```

All tracked UI elements are tweened to their new colors over **0.5 seconds** with Exponential easing. The following element types are updated:
- Background elements → `bg`
- Text labels → `fg`
- Primary accent elements → `pri`
- Tonal surfaces → `inact` blended with `pri` at 15%
- On-primary elements → `onpri`
- Inactive elements → `inact`
- Switch tracks → `pri` or `inact` based on state
- Switch thumbs → `onpri` or `out` based on state
- Tab buttons → `pri` (active) or `out` (inactive)
- Icons → `out`
- Slider values → `out`
- Dialog backgrounds → `bg` blended with `pri` at 11%
- Dialog text → `fg`
- TextBox elements (label, line, background) → based on focus state

### Custom Themes

Create your own color theme:

```lua
UI:AddTheme("MyTheme", {
    Background = Color3.fromRGB(30, 30, 35),      -- or "bg"
    Text = Color3.fromRGB(240, 240, 240),           -- or "fg"
    Primary = Color3.fromRGB(100, 200, 255),        -- or "pri"
    TextOnPrimary = Color3.fromRGB(0, 20, 40),      -- or "onpri"
    Surface = Color3.fromRGB(45, 45, 50),           -- or "inact"
    Outline = Color3.fromRGB(120, 120, 130)         -- or "out"
})
```

**Accepted Keys:** The `AddTheme` function accepts multiple aliases for each color role:

| Role | Accepted Keys |
|------|---------------|
| `bg` | `Background`, `bg` |
| `fg` | `Text`, `TextColor`, `fg` |
| `pri` | `Primary`, `PrimaryColor`, `pri` |
| `onpri` | `TextOnPrimary`, `onpri` |
| `inact` | `Surface`, `Inactive`, `inact` |
| `out` | `Outline`, `Border`, `out` |

Any missing values fall back to the **Default** theme's colors.

---

## Tab System

### Adding Tabs

```lua
local MainTab = UI:AddTab({
    Title = "Main",
    Icon = "home"  -- Material icon name or asset ID
})

local SettingsTab = UI:AddTab({
    Title = "Settings",
    Icon = "settings"
})
```

### Tab Properties

| Property | Type | Description |
|----------|------|-------------|
| `Title` | `string` | Tab display text |
| `Icon` | `string` | Material icon name or asset ID |

### Tab Scrolling

The tab bar supports horizontal scrolling with:
- **Mouse/touch drag**: Click and drag to scroll through tabs
- **Automatic canvas sizing**: Tabs expand dynamically
- **Center alignment**: Tabs are centered by default

### Tab Indicator

A Material Design 3-style indicator animates beneath the active tab:
- **Color**: Primary theme color
- **Width**: Matches the text content width
- **Height**: 3 pixels
- **Animation**: Smoothly transitions position and size using Exponential easing over 0.4 seconds

### Tab Switching Animation

When switching between tabs:
- The outgoing tab container slides in the exit direction
- The incoming tab container slides in from the opposite direction
- Direction is determined by tab index (right for forward, left for backward)
- First tab activation has no directional slide

### Selecting Tabs Programmatically

```lua
UI:SelectTab("Main")
```

This activates the tab with the matching text, updates the indicator, and plays the transition animation.

### Tab Return Value

`AddTab` returns a table with methods:

| Method | Parameters | Description |
|--------|-----------|-------------|
| `SetText` | `newText: string` | Updates the tab's display text |

---

## UI Elements

### Element Counter

All elements are automatically assigned a `LayoutOrder` value via `lib.ElementCounter`, which increments with each element added. This ensures consistent ordering within the scrolling container.

### Element Registration

All interactive elements are registered in `lib.SearchRegistry` for the search functionality. Each entry contains:
- `obj`: The UI instance
- `type`: Element type (typically `"item"`)
- `rawText`: Original searchable text
- `text`: Lowercase searchable text
- `isSearchable`: Whether the element has search text
- `parentSection`: Parent section reference
- `parentTab`: Parent tab button reference

---

### Label

A simple text display element with optional icon.

```lua
local label = UI:AddLabel({
    Text = "Welcome to the script!",
    Icon = "info"  -- optional
})
```

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Text` | `string` | `"Label"` | Display text (supports RichText) |
| `Icon` | `string` | `nil` | Material icon name or asset ID |

#### Return Methods

| Method | Parameters | Description |
|--------|-----------|-------------|
| `SetText` | `newText: string` | Updates the label text |

---

### Section

A header text that groups related elements together.

```lua
local section = UI:AddSection({
    Text = "Player Modifications"
})
```

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Text` | `string` | `"Section"` | Section header text (supports RichText) |

#### Styling
- **Font Weight**: SemiBold
- **Text Size**: 14
- **Text Color**: `out` (outline/secondary color)
- **Alignment**: Bottom-left
- **Height**: 28 pixels

#### Return Methods

| Method | Parameters | Description |
|--------|-----------|-------------|
| `SetText` | `newText: string` | Updates the section header text |

---

### Divider

A horizontal line separator between elements.

```lua
UI:AddDivider()
```

#### Styling
- **Height**: 1 pixel
- **Color**: `inact` (inactive surface color)
- **Span**: Full width of the container

---

### Button

Interactive button with multiple Material Design 3 variants.

```lua
local button = UI:AddButton({
    Text = "Click Me",
    Type = "filled",
    Icon = "lightbulb"
    Width = 200,        -- optional, for fixed width
    Callback = function()
        print("Button clicked!")
    end
})
```

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Text` | `string` | `"Button"` | Button label text |
| `Type` | `string` | `"filled"` | Button style variant |
| `Icon` | `string` | `nil` | Button icon
| `Width` | `number` | `nil` | Fixed width (full-width if omitted) |
| `Callback` | `function` | `nil` | Function called on click |

#### Button Types

| Type | Appearance | Background | Text Color |
|------|-----------|------------|------------|
| `"filled"` | Solid primary color | `pri` | `onpri` |
| `"tonal"` | Muted primary tint | `inact` + `pri` at 15% | `fg` |
| `"outlined"` | Transparent with border | Transparent + `out` stroke | `pri` |
| `"text"` | Text only, no background | Transparent | `pri` |

#### Button Interactions
- **Hover**: Background color shifts to hover state over 0.2s
- **Ripple**: Material Design ripple effect on click (using `onpri` color at 85% transparency)
- **Corner Radius**: Pill-shaped (fully rounded)

#### Return Methods

| Method | Parameters | Description |
|--------|-----------|-------------|
| `SetText` | `newText: string` | Updates the button label |

---

### Switch (Toggle)

A toggle switch component for boolean values.

```lua
local switch = UI:AddSwitch({
    Title = "Enable ESP",
    Default = false,
    Icon = "eye",       -- optional leading icon
    Callback = function(state)
        print("Switch is now:", state)
    end
})
```

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Title` | `string` | `"Switch"` | Display label |
| `Default` | `boolean` | `false` | Initial toggle state |
| `Icon` | `string` | `nil` | Material icon name or asset ID |
| `Callback` | `function` | `nil` | Called with new boolean state |

#### Visual States

**OFF State:**
- Track: `inact` color (52x32 pixels)
- Thumb: `out` color (16x16 pixels, left-positioned)

**ON State:**
- Track: `pri` color (52x32 pixels)
- Thumb: `onpri` color (24x24 pixels, right-positioned at x=36)

#### Animation
- Track color tweens over 0.3s
- Thumb size and position tweens with Exponential easing over 0.3s

#### Return Methods

| Method | Parameters | Description |
|--------|-----------|-------------|
| `SetText` | `newText: string` | Updates the label text |
| `SetValue` | `newState: boolean` | Programmatically sets toggle state |

---

### Slider

A range slider for numeric values with multiple size variants.

```lua
local slider = UI:AddSlider({
    Title = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 16,
    ShowValue = true,
    Size = "m",         -- xs, s, m, l, xl
    Icon = "zap",       -- optional, shown in active track
    Callback = function(value)
        print("Speed:", value)
    end
})
```

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Title` | `string` | `"Slider"` | Display label |
| `Min` | `number` | `0` | Minimum value |
| `Max` | `number` | `100` | Maximum value |
| `Default` | `number` | `Min` | Starting value |
| `ShowValue` | `boolean` | `true` | Show numeric value label |
| `Size` | `string` | `"xs"` | Size variant |
| `Icon` | `string` | `nil` | Lucide icon for the active track |
| `Callback` | `function` | `nil` | Called with new value on release |

#### Size Variants

| Size | Track Height | Corner Radius | Total Height | Icon Size |
|------|-------------|---------------|--------------|-----------|
| `xs` | 16 | 8 | 44 | 0 (hidden) |
| `s` | 24 | 8 | 44 | 0 (hidden) |
| `m` | 40 | 12 | 52 | 24 |
| `l` | 56 | 16 | 68 | 24 |
| `xl` | 96 | 28 | 108 | 32 |

#### Visual Structure
- **Active Track** (left): `pri` color, contains optional icon
- **Inactive Track** (right): `inact` color, contains small dot indicator
- **Thumb**: `pri` color, 4px wide vertical bar at the value position
- **Gap**: 12 pixels total gap between active and inactive tracks

#### Interactions
- **Click**: Jumps thumb to click position (animated over 0.3s)
- **Drag**: Smooth real-time thumb following (0.05s animation)
- **Value Display**: Formatted to 2 decimal places

#### Return Methods

| Method | Parameters | Description |
|--------|-----------|-------------|
| `SetText` | `newText: string` | Updates the title label |
| `SetValue` | `newValue: number` | Programmatically sets slider value |

---

### Dropdown

A selection component that opens a dropdown menu of options.

```lua
local dropdown = UI:AddDropdown({
    Title = "Select Team",
    Options = {"Red", "Blue", "Green", "Yellow"},
    Default = 1,
    Icon = "users",     -- optional leading icon
    Callback = function(selected)
        print("Selected:", selected)
    end
})
```

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Title` | `string` | `"Dropdown"` | Field label (always displayed floating) |
| `Options` | `table` | `{}` | Array of option strings |
| `Default` | `number` | `1` | Index of initially selected option |
| `Icon` | `string` | `nil` | Material icon name or asset ID |
| `Callback` | `function` | `nil` | Called with selected option string |

#### Visual States

**Closed State:**
- Background: `inact` color
- Chevron icon pointing down
- Shows selected value
- Bottom line in `out` color

**Open State:**
- Chevron rotates 180° over 0.3s
- Bottom line highlights to `pri` color
- Dropdown menu appears below the field

#### Dropdown Menu
- **Max Height**: 144 pixels (3 options) with scrolling
- **Background**: `bg` blended with `pri` at 8%
- **Item Height**: 48 pixels each
- **Selected Item**: `inact` blended with `pri` at 15%
- **Hover**: Other items get 70% background transparency
- **Ripple Effect**: Each option has ripple on click

#### Return Methods

| Method | Parameters | Description |
|--------|-----------|-------------|
| `SetText` | `newText: string` | Updates the field label |
| `SetValue` | `newValue: string` | Sets selected value by string |
| `Refresh` | `newOptions: table, newDefaultIdx: number` | Replaces all options and selection |

---

### TextBox

A Material Design 3 style text input with floating label animation.

```lua
local textbox = UI:AddTextBox({
    Title = "Username",
    SupportText = "Enter your display name",  -- optional helper text
    Icon = "user",                             -- optional leading icon
    Callback = function(text, enterPressed)
        if enterPressed then
            print("Submitted:", text)
        end
    end
})
```

#### Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Title` | `string` | `"TextBox"` | Field label (floats on focus) |
| `SupportText` | `string` | `nil` | Helper text displayed below the field |
| `Icon` | `string` | `nil` | Material icon name or asset ID |
| `Callback` | `function` | `nil` | Called on focus lost with `(text, enterPressed)` |

#### Floating Label Animation

| State | Position | Size | Color |
|-------|----------|------|-------|
| Resting (no text) | y=18 | 15px | `out` |
| Floating (focused or has text) | y=6 | 11px | `pri` (focused) or `out` (unfocused) |

#### Features
- **Clear Button**: `circle-x` icon appears when text is present, clears the field on click
- **Bottom Line**: Single pixel line that highlights to `pri` color and expands to 2px when focused
- **Text Wrapping**: Supports multi-line with automatic height
- **Hover**: Background subtly lightens on mouse enter

#### Return Methods

| Method | Parameters | Description |
|--------|-----------|-------------|
| `SetText` | `newText: string` | Updates the field label (not the input value) |
| `SetValue` | `newValue: any` | Sets the text box content |

---

## Dialog System

Create modal confirmation dialogs with custom buttons.

```lua
UI:AddDialog({
    Title = "Confirm Action",
    Description = "Are you sure you want to reset all settings?",
    Buttons = {
        {
            Text = "Cancel",
            Type = "text",
            Callback = nil
        },
        {
            Text = "Reset",
            Type = "filled",
            Callback = function()
                print("Settings reset!")
            end
        }
    }
})
```

### Dialog Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Title` | `string` | `"Dialog Title"` | Dialog heading |
| `Description` | `string` | `"Dialog description..."` | Body text |
| `Buttons` | `table` | `{OK button}` | Array of button configurations |

### Button Configuration

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `Text` | `string` | `"Button"` | Button label |
| `Type` | `string` | `"text"` | `"text"` or `"filled"` |
| `Callback` | `function` | `nil` | Function called when button is clicked |

### Button Types
- **Text**: Transparent background, primary colored text
- **Filled**: Solid primary background, `onpri` colored text

### Dialog Behavior
- **Overlay**: Semi-transparent background overlay (60% opacity) blocks interaction with underlying UI
- **Background**: Elevated surface using `bg` blended with `pri` at 11%
- **Corner Radius**: 28 pixels
- **Padding**: 24 pixels on all sides
- **Animation**: Slides up from 20px below center with fade-in over 0.4s
- **Close**: Dialog automatically closes after button click with reverse animation

---

## Notification System

Display snackbar-style notifications at the bottom of the screen.

```lua
UI:Notify({
    Text = "Settings saved successfully!",
    Duration = 4,
    Actions = {
        {
            Text = "Undo",
            Callback = function()
                print("Undo clicked")
            end
        }
    }
})
```

### Notification Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `Text` | `string` | `"Notification"` | Main notification message (supports RichText) |
| `Duration` | `number` | `4` | Display time in seconds |
| `Actions` | `table` | `{}` | Optional action buttons (max 2) |

### Action Configuration

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `Text` | `string` | `"Action"` | Button label |
| `Callback` | `function` | `nil` | Called when action is clicked |

### Notification Behavior
- **Position**: Bottom-center of screen
- **Stacking**: Multiple notifications stack vertically with 8px gap
- **Background**: `bg` blended with white at 15%
- **Corner Radius**: 4 pixels
- **Height**: 48 pixels minimum
- **Auto-size**: Expands horizontally to fit content
- **Close Button**: `x` icon on the right side
- **Animation**: Slides up with fade over 0.4s, exits with slide-down over 0.3s
- **Auto-dismiss**: Automatically dismisses after duration expires
- **Early Dismiss**: Clicking action or close button immediately dismisses

### Limitations
- Maximum **2 action buttons** per notification

---

## Search Functionality

When enabled, a search bar appears below the window title.

```lua
local UI = NoxLibrary:Create({
    Search = true,
    SearchPlaceholder = "Search features...",
    SearchAvatar = "rbxthumb://type=AvatarHeadShot&id=123456&w=48&h=48",
    OnSearch = function(query)
        print("Searching for:", query)
    end
})
```

### Search Bar Features
- **Avatar Display**: Shows player avatar (hidden when typing)
- **Search Icon**: Lucide `search` icon (turns primary color when focused)
- **Clear Button**: `x` icon appears when text is present
- **Floating Results**: Dropdown panel below search bar with matching elements

### Search Behavior
- Results panel shows elements whose text contains the query (case-insensitive)
- Each result is clickable and navigates to the corresponding element:
  1. Switches to the parent tab
  2. Scrolls the container to center the element
- "No results found" message displayed when empty
- Results panel auto-hides when search loses focus

### Custom Search Avatar

By default uses the local player's headshot:
```
rbxthumb://type=AvatarHeadShot&id={LocalPlayer.UserId}&w=48&h=48
```

Provide a custom URL via the `SearchAvatar` configuration field.

---

## Icon System

### Icon Resolution

The `parseIcon` function resolves icons in this priority:

1. **Roblox Asset ID**: If string contains `rbxassetid://` or `rbxasset://`, returns as-is
2. **Lucide Icon Name**: Looks up in the loaded Lucide icons table
3. **Fallback**: Returns `nil` and prints a warning

### Common Lucide Icons

The following icon names are commonly used within the library:

| Icon Name | Used In |
|-----------|---------|
| `search` | Search bar |
| `x` | Close button, clear button |
| `minimize` | Window minimize |
| `maximize` | Window maximize (after minimize) |
| `chevron-down` | Dropdown arrow |
| `circle-x` | TextBox clear button |
| `home`, `settings`, `eye`, `users`, `zap`, `info`, `user` | Common user-provided icons |

### Icon Styling

- Icons are `ImageLabel` instances with `BackgroundTransparency = 1`
- Default color: `out` (outline color from theme)
- Size varies by component (typically 18-24 pixels)

---

## Window Controls

### Minimize/Maximize

```lua
-- Toggle via button
-- Uses minimize/maximize icons with smooth height animation

-- Toggle via keybind (if configured)
-- Press ToggleKey to collapse/expand
```

When minimized:
- Window height animates to 64 pixels (header only)
- Resize handle becomes invisible
- Content is clipped

### Close

The close button shows a confirmation dialog before destroying:
1. Dialog asks for confirmation
2. On confirm: plays exit animation (height collapses, transparency fades)
3. After 0.4s animation: destroys the ScreenGui

### SetTitle

```lua
UI:SetTitle("New Window Title")
```

Updates the window title text dynamically.

---

## Internal Architecture

### Object Tracking Tables

The library maintains several tables for runtime theme switching:

| Table | Content | Theme Property |
|-------|---------|----------------|
| `objs.bg` | Background frames | `BackgroundColor3 → bg` |
| `objs.fg` | Text labels | `TextColor3 → fg` |
| `objs.pri` | Primary accent elements | `BackgroundColor3 → pri` |
| `objs.onpri` | On-primary elements | `TextColor3/ImageColor3 → onpri` |
| `objs.inact` | Inactive surfaces | `BackgroundColor3 → inact` |
| `objs.out` | Outline/icon elements | `BackgroundColor3 → out` |
| `objs.s_trk` | Switch tracks | State-based: `pri` or `inact` |
| `objs.s_thm` | Switch thumbs | State-based: `onpri` or `out` |
| `objs.tab_btn` | Tab buttons | State-based: `pri` or `out` |
| `objs.tbox` | TextBox elements | Focus-based coloring |
| `objs.icon` | Icons and strokes | `ImageColor3/Color → out` |
| `objs.dlg_bg` | Dialog backgrounds | `BackgroundColor3` blend |
| `objs.dlg_fg` | Dialog text | `TextColor3 → fg` |
| `objs.sl_val` | Slider values | `TextColor3 → out` |
| `objs.tonal_bg` | Tonal button backgrounds | `inact` + `pri` blend |

### Library State Table

The `lib` object maintains these internal fields:

| Field | Type | Description |
|-------|------|-------------|
| `Tabs` | `table` | Array of tab data `{btn, data}` |
| `TabContainers` | `table` | Array of scrolling frames per tab |
| `ActiveTabIndex` | `number` | Currently active tab index (0 = none) |
| `CurrentBuildContainer` | `ScrollingFrame` | Container for the current tab |
| `UseTabs` | `boolean` | Whether tabs have been initialized |
| `ElementCounter` | `number` | Auto-incrementing layout order counter |
| `SearchRegistry` | `table` | All searchable elements |
| `CurrentSearchTab` | `TextButton` | Currently active tab for search |
| `CurrentSearchSection` | `nil/table` | Currently active section |

### Tween Helper

```lua
local function t(object, property, value, duration)
    tw:Create(object, TweenInfo.new(duration or 0.3, 
        Enum.EasingStyle.Exponential, 
        Enum.EasingDirection.Out), 
        {[property] = value}):Play()
end
```

Default tween configuration:
- **Duration**: Configurable (default 0.3s)
- **Easing Style**: Exponential
- **Easing Direction**: Out

### Ripple Effect

Material Design ripple animation on interactive elements:

1. Creates a `CanvasGroup` mask matching the target's corner radius
2. Spawns a circular frame at the input position
3. Animates the circle to 1.5x the target's max dimension
4. Fades circle to full transparency over 0.4s with Sine easing
5. Automatically cleans up after animation completes

---

## API Reference

### Library-Level Functions

| Function | Parameters | Returns | Description |
|----------|-----------|---------|-------------|
| `NoxLibrary.Create` | `data: table` | `lib` object | Creates a new window |

### Window Methods (lib object)

| Method | Parameters | Returns | Description |
|--------|-----------|---------|-------------|
| `AddTab` | `data: {Title, Icon}` | `Tab` object | Creates a new tab |
| `SelectTab` | `tabText: string` | `nil` | Activates a tab by name |
| `AddLabel` | `data: {Text, Icon}` | `Label` object | Adds a text label |
| `AddSection` | `data: {Text}` | `Section` object | Adds a section header |
| `AddDivider` | `none` | `nil` | Adds a horizontal divider |
| `AddButton` | `data: {Text, Type, Width, Callback}` | `Button` object | Adds a button |
| `AddSwitch` | `data: {Title, Default, Icon, Callback}` | `Switch` object | Adds a toggle switch |
| `AddSlider` | `data: {Title, Min, Max, Default, ShowValue, Size, Icon, Callback}` | `Slider` object | Adds a numeric slider |
| `AddDropdown` | `data: {Title, Options, Default, Icon, Callback}` | `Dropdown` object | Adds a dropdown selector |
| `AddTextBox` | `data: {Title, SupportText, Icon, Callback}` | `TextBox` object | Adds a text input |
| `AddDialog` | `data: {Title, Description, Buttons}` | `nil` | Shows a modal dialog |
| `Notify` | `data: {Text, Duration, Actions}` | `nil` | Shows a notification |
| `ChangePalette` | `themeName: string` | `nil` | Changes the active theme |
| `AddTheme` | `themeName: string, themeData: table` | `nil` | Registers a custom theme |
| `RegisterElement` | `element: Instance, searchText: string, elementType: string` | `nil` | Registers element for search |
| `SetTitle` | `newTitle: string` | `nil` | Updates window title |

### Return Object Methods

All element-returned tables support these methods where applicable:

| Method | Element Types | Description |
|--------|--------------|-------------|
| `SetText` | Label, Section, Button, Switch, Slider, Dropdown, TextBox | Updates display text |
| `SetValue` | Switch, Slider, Dropdown, TextBox | Updates the element's value |
| `Refresh` | Dropdown | Replaces options list |

---

## Example Usage

### Complete Example

```lua
local NoxLibrary = loadstring(game:HttpGet("[https://raw.githubusercontent.com/fiangg20/nox/refs/heads/main/source.lua](https://raw.githubusercontent.com/fiangg20/nox/refs/heads/main/source.lua)"))()

-- Create the main window
local UI = NoxLibrary:Create({
    Title = "My Script Hub",
    SizeX = 420,
    SizeY = 540,
    Theme = "Purple",
    ToggleKey = Enum.KeyCode.RightShift,
    Search = true,
    SearchPlaceholder = "Search features..."
})

-- Main tab content
local MainTab = UI:AddTab({
    Title = "Main",
    Icon = "home"
})

UI:AddSection({Text = "Player Features"})

local speedSlider = UI:AddSlider({
    Title = "Walk Speed",
    Min = 16,
    Max = 200,
    Default = 16,
    Size = "m",
    Icon = "bolt",
    Callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = value
    end
})

local jumpSlider = UI:AddSlider({
    Title = "Jump Power",
    Min = 50,
    Max = 300,
    Default = 50,
    Size = "m",
    Callback = function(value)
        game.Players.LocalPlayer.Character.Humanoid.JumpPower = value
    end
})

UI:AddDivider()

UI:AddSection({Text = "Combat"})

local espSwitch = UI:AddSwitch({
    Title = "Enable ESP",
    Default = false,
    Icon = "visibility",
    Callback = function(state)
        if state then
            print("ESP Enabled")
        else
            print("ESP Disabled")
        end
    end
})

local teamDropdown = UI:AddDropdown({
    Title = "Target Team",
    Options = {"All", "Red", "Blue", "Neutral"},
    Default = 1,
    Icon = "group",
    Callback = function(selected)
        print("Targeting:", selected)
    end
})

-- Visuals tab content
local VisualTab = UI:AddTab({
    Title = "Visuals",
    Icon = "visibility"
})

UI:AddButton({
    Text = "Apply Fullbright",
    Type = "filled",
    Icon = "light_mode",
    Callback = function()
        game.Lighting.Brightness = 2
        game.Lighting.ClockTime = 14
        UI:Notify({
            Text = "Fullbright applied!",
            Duration = 3
        })
    end
})

UI:AddButton({
    Text = "Reset Lighting",
    Type = "tonal",
    Icon = "refresh",
    Callback = function()
        game.Lighting.Brightness = 1
        game.Lighting.ClockTime = 12
    end
})

-- Settings tab content
local SettingsTab = UI:AddTab({
    Title = "Settings",
    Icon = "settings"
})

UI:AddSection({Text = "Configuration"})

local usernameBox = UI:AddTextBox({
    Title = "Display Name",
    SupportText = "This name will be shown to other players",
    Icon = "person",
    Callback = function(text, enterPressed)
        if enterPressed and text ~= "" then
            UI:Notify({
                Text = "Display name set to: " .. text,
                Duration = 4
            })
        end
    end
})

-- Theme switching buttons
UI:AddSection({Text = "Appearance"})

UI:AddButton({
    Text = "Purple Theme",
    Type = "outlined",
    Width = 140,
    Icon = "palette",
    Callback = function()
        UI:ChangePalette("Purple")
    end
})

UI:AddButton({
    Text = "Blue Theme",
    Type = "outlined",
    Width = 140,
    Icon = "water_drop",
    Callback = function()
        UI:ChangePalette("Blue")
    end
})

UI:AddButton({
    Text = "Green Theme",
    Type = "outlined",
    Width = 140,
    Icon = "eco",
    Callback = function()
        UI:ChangePalette("Green")
    end
})

-- Notification on load
UI:Notify({
    Text = "Script loaded successfully!",
    Duration = 5,
    Actions = {
        {
            Text = "Thanks!",
            Callback = function()
                print("User acknowledged")
            end
        }
    }
})
```

### Custom Theme Example

```lua
UI:AddTheme("Neon", {
    Background = Color3.fromRGB(10, 10, 15),
    Text = Color3.fromRGB(240, 255, 255),
    Primary = Color3.fromRGB(0, 255, 200),
    TextOnPrimary = Color3.fromRGB(0, 30, 20),
    Surface = Color3.fromRGB(20, 25, 30),
    Outline = Color3.fromRGB(0, 200, 150)
})

-- Apply the custom theme
UI:ChangePalette("Neon")
```

### Dialog Example

```lua
UI:AddButton({
    Text = "Reset All Settings",
    Type = "text",
    Callback = function()
        UI:AddDialog({
            Title = "Reset Settings?",
            Description = "This will reset all your configured values to their defaults. This action cannot be undone.",
            Buttons = {
                {
                    Text = "Cancel",
                    Type = "text",
                    Callback = nil
                },
                {
                    Text = "Reset All",
                    Type = "filled",
                    Callback = function()
                        speedSlider:SetValue(16)
                        jumpSlider:SetValue(50)
                        espSwitch:SetValue(false)
                        teamDropdown:SetValue("All")
                        UI:Notify({Text = "All settings reset!", Duration = 3})
                    end
                }
            }
        })
    end
})
```

---

## Technical Notes

### Performance Considerations
- **Tweening**: The library heavily uses `TweenService` for smooth animations. Exponential easing provides a natural feel.
- **Object Tracking**: Theme switching iterates through all tracked objects. For very large UIs, this may cause a brief frame drop.
- **RenderStepped Connections**: Dragging and slider interactions use `RunService.RenderStepped` / `InputChanged` for responsiveness.
- **Memory**: The `SearchRegistry` grows with each element. For long-running scripts with dynamically created elements, consider cleanup.

### Security & Executor Compatibility
- Uses `getcustomasset()` for font loading (requires executor support)
- Uses `isfolder()`, `makefolder()`, `isfile()`, `writefile()`, `game:HttpGet()` (standard executor functions)
- Loads Lucide icons from a remote URL via `loadstring(game:HttpGet())`

### Known Limitations
- Maximum 2 notification action buttons
- Search results panel max height: 200 pixels
- Dialog button count is not explicitly limited but designed for 1-3 buttons
- Window minimum size: 320x400 pixels
- Dropdown max visible options: 3 (with scrolling)

---

## Credits

- **Font**: Google Sans Flex by Google
- **Icons**: Material Icons by Google
- **Design System**: Material Design 3 by Google
- **Created by**: UltraSirius (@fyandevelopers on Roblox)

---

Debugging Suite Available in **ScriptBlox**
