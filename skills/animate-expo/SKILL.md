---
name: animate-expo
description: Build or review motion in React Native and Expo, including gestures, haptics, screen transitions and animation performance.
---

# Expo motion

Start from the installed Expo SDK, Reanimated, Gesture Handler and navigation versions. Reuse platform navigation and existing components when they cover the interaction; do not replace working animation code merely to standardize a library.

- Keep continuous gesture and scroll updates off React renders. Use the installed animation runtime's shared values/worklets where appropriate, and cross back to application logic at commits or meaningful thresholds rather than every frame.
- Grab an animation from its current visible position. Pass gesture velocity into settling motion; let a fast flick and deliberate travel both contribute to dismissal. Define gesture axes and cancellation so a row does not steal its list's scroll.
- Reuse motion tokens. Prefer transforms/opacity when they preserve the intended geometry; profile costly layout, blur or shadow updates on the supported hardware.
- Use native navigation behavior where possible, including the back gesture. Check option support on each platform instead of copying settings from another SDK.
- Respect reduced motion, screen readers, touch targets and text scaling. Haptics should reinforce visible feedback and fire at meaningful interaction points, not every frame.
- Confirm runtime setup from the installed versions before changing Babel, architecture or dependencies. Use Expo's version-aware installer for packages that are actually needed.

## References and verification

- [RECIPES.md](RECIPES.md): version-specific examples for press, sheets, lists, keyboard and navigation. Adapt the matching example; do not install every package listed there.
- [Gesture details](../animate/references/INTERACTION.md): shared physical interaction principles; apply the native gesture equivalents.
- [Review and opportunities](../animate/references/REVIEW.md): audit criteria, with device-specific evidence.

For reviews and opportunity requests, report findings without modifying code. For implementation, exercise fast/slow gestures, interruption, cancellation and reduced motion. Use a release build on representative supported hardware for performance claims; report simulator-only checks and unavailable device verification explicitly.
