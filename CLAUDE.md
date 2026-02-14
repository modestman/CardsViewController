# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

CardsViewController is an iOS Swift library providing a swipeable card stack UI component (Tinder-style). Distributed via CocoaPods and Swift Package Manager. No external dependencies — UIKit only.

- **Swift 5.0**, iOS 11.0+
- **License:** MIT
- **Current version:** 1.3.0 (see `CardsViewController.podspec`)

## Build & Development

The library is distributed via Swift Package Manager. The Example app is in `Example/`.

```bash
# Open the Example project (no pod install needed — uses local SPM package)
open Example/CardsViewController.xcodeproj
```

The Example project references the library as a local SPM package (`XCLocalSwiftPackageReference ".."`), so changes to `Sources/` are picked up automatically.

**Build:** select the `CardsViewController_Example` scheme in Xcode, then Build (Cmd+B).

**Tests:** `Example/Tests/Tests.swift` — run via Xcode (Cmd+U) on the `CardsViewController_Tests` target. Test scaffolding is minimal.

**CLI build (if needed):**
```bash
xcodebuild -project Example/CardsViewController.xcodeproj \
  -scheme CardsViewController_Example \
  -destination 'platform=iOS Simulator,name=iPhone 16' \
  build
```

## Architecture

**Delegate-DataSource pattern** (like UITableView). The library lives in `Sources/CardsViewController/`.

### Core types

- **`CardsViewController`** — Main container view controller. Manages a stack of child view controllers as cards. Only keeps `visibleCardsCount` (default 3) cards in memory.
- **`CardViewController`** protocol — Each card conforms to this. Provides `frontView`, optional `backView` for flip animation.
- **`CardsViewControllerDatasource`** — Provides card count, card view controllers, optional decoration views and transforms.
- **`CardsViewControllerDelegate`** — Handles swipe/tap animations, progress tracking, card lifecycle events. All methods have defaults via `Types+Defaults.swift`.

### Key enums

- `SwipeDirection`: `.up`, `.down`, `.left`, `.right`
- `SwipeAnimation`: `.none`, `.putAtTheEnd`, `.throwOut`
- `TapAnimation`: `.none`, `.flip`

### Internal card model

`Card` struct tracks each card's state (`.inStack`, `.dragging`, `.cancelAnimation`, `.removingAnimation`, `.transformAnimation`), its absolute index in the data vs visible z-order index, and its animator.

### Animation system

Uses `UIViewPropertyAnimator` for interruptible animations. Three animation types as separate structs:
- `ThrowOutAnimation` — card flies off screen
- `CancelAnimation` — spring animation returning card to position
- `ShakeAnimation` — sequential left-right-center shake

`AnimationHelpers` provides direction calculation from velocity, translation for off-screen throw, default stacking transforms, and predefined velocities for programmatic swipes.

### Helpers

- `LayoutGuide` protocol — unifies `UIView` and `UILayoutGuide` for constraint handling
- `UIViewController+Child` — child view controller add/remove helpers
- `CGPoint+Operators` — vector math operators (+, -, *, /)
