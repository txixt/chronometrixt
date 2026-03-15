# watchixt Architecture Explanation

## 🔄 How TimelineView Works

### The Magic of TimelineView

`TimelineView` is a special SwiftUI container that automatically calls its content closure at specified intervals with an updated `context` that contains the current `Date`.

```swift
TimelineView(.animation(minimumInterval: 0.536476, paused: false)) { context in
    // This closure gets called every 0.536476 seconds
    // context.date contains the current Date
    let time = gov.currentTime(for: context.date)
    // ^ This is where the magic happens!
}
```

### The Update Flow

1. **TimelineView schedules next update** → in 0.536476 seconds
2. **System wakes up** → at the scheduled time
3. **Calls closure** → with new `context.date`
4. **Your code calculates time** → `gov.currentTime(for: context.date)`
5. **SwiftUI renders** → with the new time
6. **Repeat** → TimelineView schedules the next update

### Why This Is Efficient

- **No manual state management** - You're not storing time, just calculating it
- **System-controlled** - watchOS decides when updates actually happen
- **Auto-pauses** - When `scenePhase != .active`, it stops completely
- **No drift** - Always calculates from actual `Date`, never accumulates errors

## 📊 The Time Calculation

### Metric Time (Base-10)
```
86,400 Gregorian seconds per day
100,000 metric seconds per day
86,400 ÷ 100,000 = 0.864 Gregorian seconds per metric second

10 hours × 100 minutes × 100 seconds = 100,000 metric seconds
```

### Elevic Time (Base-11)
```
86,400 Gregorian seconds per day  
161,051 elevic seconds per day
86,400 ÷ 161,051 = 0.536476 Gregorian seconds per elevic second

11 hours × 121 minutes × 121 seconds = 161,051 elevic seconds
```

### The Conversion Formula

```swift
func elevic(date: Date) {
    // Get Gregorian seconds since midnight
    let gregSeconds = (hour * 3600) + (minute * 60) + second
    
    // Convert to elevic seconds
    let elevicSeconds = Int(Double(gregSeconds) / 0.536476)
    
    // Extract hour, minute, second from elevic seconds
    hour = elevicSeconds / 14641    // 121² = 14,641 seconds per hour
    minute = (elevicSeconds / 121) % 121
    second = elevicSeconds % 121
}
```

## ⚡️ The Optimization Strategy

### Standard Mode (Every Second)
- **Metric**: Update every 0.864 Greg seconds (every 1 metric second)
- **Elevic**: Update every 0.536476 Greg seconds (every 1 elevic second)
- **Battery**: Moderate drain (100 or 161 updates per day)

### Optimized Mode (Sweeping Second Hand)
- **Metric**: Update every 28.8 Greg seconds (every 33.33 metric seconds)
- **Elevic**: Update every 21.6 Greg seconds (every 40.33 elevic seconds)
- **Battery**: Much better! Only 3 updates per minute
- **Visual**: Second hand smoothly animates between positions

### The Math for Sweeping Updates

**Goal**: Update 3 times per revolution of the second hand

**Metric (100 seconds per revolution):**
```
100 metric seconds ÷ 3 = 33.333 metric seconds per update
33.333 × 0.864 = 28.8 Gregorian seconds
```

**Elevic (121 seconds per revolution):**
```
121 elevic seconds ÷ 3 = 40.333 elevic seconds per update  
40.333 × 0.536476 = 21.637865 Gregorian seconds
```

### How the Animation Works

```swift
ClockHand(rotationDegrees: Double(time.second) * 2.975, ...)
    .animation(.linear(duration: 21.637865), value: time.second)
```

1. **TimelineView updates** → Every 21.6 Greg seconds
2. **Second jumps** → From `second: 40` to `second: 80` (jumped 40 elevic seconds)
3. **SwiftUI animates** → Smoothly rotates over 21.6 seconds
4. **Result** → Appears to sweep continuously!

## 🔧 The TimeBase Switching Problem

### The Issue

```swift
// ❌ This doesn't work - interval is captured at creation
TimelineView(.animation(
    minimumInterval: gov.timeBase == .ten ? 0.864 : 0.536476
)) { ... }
```

When you change `gov.timeBase`, the `TimelineView` doesn't recreate itself, so the interval stays the same.

### The Solution

```swift
// ✅ Force recreation with .id()
TimelineView(...)
    .id(timeBase)  // When timeBase changes, SwiftUI destroys and recreates this view
```

This is wrapped in `TimelineViewWrapper` to keep the code clean.

## 🌙 Always-On Display Optimization

```swift
@Environment(\.isLuminanceReduced) private var isLuminanceReduced

if !isLuminanceReduced {
    // Show second hand only when actively viewing
    ClockHand(second hand)
}
```

**Why this matters:**
- **Always-On Display (AOD)** mode uses a different rendering strategy
- Second hands burn battery in AOD
- Apple's own watch faces hide seconds in AOD
- This can **double** your battery life

## 🎛️ The Toggle Strategy

```swift
@State private var useOptimizedUpdates = false

var body: some View {
    TimelineViewWrapper(
        interval: useOptimizedUpdates ? gov.optimizedInterval : gov.updateInterval
    ) { ... }
}
```

**Testing strategy:**
1. Start with `false` (every second ticking)
2. Verify time accuracy
3. Switch to `true` (sweeping)
4. Measure battery impact
5. Choose based on your preference

## 📱 Watch Size Detection

```swift
private func scaleForWatch(_ size: CGSize) -> CGFloat {
    let diameter = min(size.width, size.height)
    if diameter < 170 {
        return 1.6  // 40mm, 41mm watches
    } else if diameter < 195 {
        return 1.7  // 44mm, 45mm watches
    } else {
        return 1.8  // 49mm Ultra watches
    }
}
```

**Why this is better than fixed scaling:**
- Adapts to any watch size
- Future-proof for new models
- Based on actual screen dimensions
- No device model detection needed

## 🔍 Debugging Tips

### Check if updates are happening
```swift
TimelineView(...) { context in
    let _ = print("Update at: \(context.date)")
    let time = gov.currentTime(for: context.date)
}
```

### Verify interval calculation
```swift
print("Metric interval: \(gov.updateInterval)")  // Should be 0.864
print("Elevic interval: \(gov.updateInterval)")  // Should be 0.536476
```

### Test Always-On Display
1. Tap screen → wrist down
2. Wait 10 seconds
3. Wrist up → check if second hand disappeared

## 🎯 Performance Metrics

| Mode | Updates/Min | Updates/Hour | Battery Impact |
|------|-------------|--------------|----------------|
| **Metric Every Second** | ~69 | ~4,167 | High |
| **Elevic Every Second** | ~112 | ~6,720 | Higher |
| **Metric Optimized** | 2 | 120 | Low |
| **Elevic Optimized** | 2.77 | 166 | Low |
| **AOD with No Seconds** | 1.67 | 100 | Very Low |

## 🚀 Future Optimizations

1. **Complications** - Add watch face complications
2. **Background refresh** - Update time when not visible
3. **Haptics** - Vibrate on the hour
4. **Time zones** - Support multiple zones
5. **Alarms** - Native metric/elevic alarms

## 🤔 Common Questions

**Q: Why not use a regular Timer?**
A: `TimelineView` is system-managed, pauses automatically, and integrates with watchOS power management.

**Q: Does the calculation happen every frame?**
A: No! Only when TimelineView triggers (every 0.5-0.8 seconds), not every 60fps frame.

**Q: Why calculate from Date instead of incrementing?**
A: Prevents drift, handles app suspension, and simplifies logic.

**Q: Can I use this for seconds-precision alarms?**
A: Yes! TimelineView is accurate to the system clock.

**Q: What about complications?**
A: Complications use `TimelineProvider`, a different but related API.
