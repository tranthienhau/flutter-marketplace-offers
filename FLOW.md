# Screenshot capture flow

Real captures from the iOS Simulator via an integration-test driver (no mockups).

## Steps

1. Boot the simulator:
   ```bash
   xcrun simctl boot "iPhone 17 Pro"
   open -a Simulator
   ```
2. Scaffold the iOS platform folder (if missing) and get dependencies:
   ```bash
   flutter create . --platforms=ios --project-name flutter_marketplace_offers
   flutter pub get
   ```
3. Drive the screenshot test:
   ```bash
   flutter drive \
     --driver test_driver/integration_test.dart \
     --target integration_test/screenshot_test.dart \
     -d "iPhone 17 Pro"
   ```
4. Build the demo GIF from the PNGs:
   ```bash
   cd screenshots
   ffmpeg -y -framerate 1 -pattern_type glob -i '*.png' \
     -vf "scale=320:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
     -loop 0 demo.gif
   ```

PNGs + `demo.gif` are written to `screenshots/` and embedded in `README.md`.

## How it works

- `test_driver/integration_test.dart` - `integrationDriver(onScreenshot:)` writes each PNG to `screenshots/<name>.png`.
- `integration_test/screenshot_test.dart` - pumps the full app wrapped in a `ProviderScope` (`ProviderScope(child: MarketplaceApp())`). The Discover screen auto-fetches its mock offers, so the test waits with `pump(Duration)` for the list to populate, then:
  1. captures `01-discover` (the offers feed),
  2. taps the heart icons to favorite a couple of offers,
  3. taps the first offer card and captures `02-offer-detail`,
  4. returns and opens the Favorites tab to capture `03-favorites`,
  5. opens the Profile tab to capture `04-profile`.
- The offer cards and detail page show always-on countdown timers (a `Timer.periodic`), so the test uses `await tester.pump(const Duration(milliseconds: 400))` instead of `pumpAndSettle`, which would hang on the infinite animation.
