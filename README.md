# Lact8

A lactate threshold testing app for iOS that helps athletes identify their aerobic (LT1) and anaerobic (LT2) thresholds and calculate personalized training zones.

## Features

- **Step Test Recording** - Record lactate, heart rate, and power/pace data from incremental step tests
- **Automatic Threshold Detection** - LT1 detected via first significant lactate rise (>0.3 mmol/L); LT2 calculated using the D-max method
- **Multiple Zone Systems** - Choose from 3-Zone (Simple), 7-Zone (Touretski), or 8-Zone (Couzens) training systems
- **Trend Tracking** - Monitor threshold progression over time with charts and statistics
- **Data Export** - Export test results as JSON, CSV, or Markdown
- **Heart Rate Zones** - Automatic HR zone calculation based on threshold heart rates

## Requirements

- iOS 16.0+
- Xcode 15.0+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (for project generation)

## Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/benreeve1984/lact8-iphone.git
   cd lact8-iphone
   ```

2. Generate the Xcode project:
   ```bash
   xcodegen generate
   ```

3. Open in Xcode:
   ```bash
   open Lact8.xcodeproj
   ```

4. Select your development team in Signing & Capabilities

5. Build and run (⌘R)

## How It Works

### Threshold Detection

**LT1 (Aerobic Threshold)**
- Primary: First step where lactate rises >0.3 mmol/L from the previous step
- Fallback: Interpolation to 2.0 mmol/L if no clear rise detected

**LT2 (Anaerobic Threshold)**
- Uses the D-max method: finds the point of maximum perpendicular distance from a line connecting LT1 to the final test point

### Conducting a Test

1. Start at a comfortable warm-up intensity
2. Increase intensity every 5 minutes (20-30W for cycling, 1 km/h for running)
3. Record lactate, heart rate, and power/pace at the end of each step
4. Continue until lactate rises sharply (>4-6 mmol/L) or exhaustion

## Project Structure

```
lact8-iphone/
├── App/                    # App entry point
├── Models/                 # Data models (LactateTest, TestStep)
├── Views/                  # SwiftUI views
│   ├── Components/         # Reusable chart and UI components
│   ├── History/            # Test history list
│   ├── NewTest/            # Test recording interface
│   ├── Onboarding/         # First-launch walkthrough
│   ├── Results/            # Test results and detail views
│   ├── Settings/           # App settings
│   └── Trends/             # Threshold progression charts
├── ViewModels/             # View models
├── Services/               # Business logic (ThresholdCalculator, TrainingZoneCalculator)
├── Constants/              # App constants and thresholds
├── Persistence/            # Core Data stack
├── Validation/             # Input validation
├── Errors/                 # Error types
├── Utilities/              # Helper utilities
└── Resources/              # Assets and Core Data model
```

## Acknowledgements

The lactate testing methodology in this app is based on what I learned from [Alan Couzens](https://alancouzens.substack.com/) via the MadCrew Forum and his excellent Substack book *The Science of Maximal Athletic Development*.

Alan's work on training zone calculation, threshold detection, and the application of sports science principles to endurance training has been invaluable. I highly recommend his writing for anyone interested in the science behind endurance performance.

## Disclaimer

This app is for informational purposes only and does not constitute medical advice. Lactate testing should ideally be performed under professional supervision. Consult a qualified sports scientist or physician before making training decisions based on these results.

## License

MIT License - see LICENSE file for details.

<!-- CI/CD trigger -->
