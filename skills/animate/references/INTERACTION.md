# Gesture and component details

Selected from the former Apple/Emil design guides. Use these details when the interaction calls for them; they are not a requirement to add gestures or effects.

## Grab, release and interrupt

- On grab, capture the current visible position and the pointer's offset within the object. Restarting from the closed/open endpoint makes a mid-flight grab jump.
- Track the active pointer and handle cancellation. On the web, pointer capture can keep a drag alive outside the element; a second finger should not replace the active drag unexpectedly.
- At release, use the gesture's measured velocity and position to choose a destination. Distance alone can reject a quick flick that clearly expresses dismissal intent. Use the gesture library's velocity units and tune thresholds in those units.
- Pass velocity into the settling spring when supported. A new gesture should be able to interrupt that spring from its current position.
- Past a natural boundary, increasing resistance can communicate the limit. Keep the returned value continuous at the boundary and provide an accessible non-gesture alternative.

## Spatial consistency

- Anchor menus and popovers to the trigger that opened them. Centered modals need not use that origin.
- Dismiss a surface along a path consistent with its arrival or the user's gesture. Preserve platform navigation conventions rather than imposing one transition on every screen.
- Use the same animated value for a dragged surface and its backdrop when they should move together.

## Small details worth preserving

- In a toolbar, an initial tooltip delay avoids accidental activation; subsequent tooltips can appear promptly while the user explores nearby controls.
- For deliberate actions such as hold-to-confirm, a steady progress fill can make the threshold legible. Cancel immediately when the interaction is abandoned. Animation completion alone is not authorization to perform the action.
- A clipped decorative copy can coordinate text and background transitions for an indicator. Hide that copy from assistive technology, remove it from focus order and keep one semantic set of controls.
- Keep a component usable throughout an entrance. A stagger should not make the user wait for an actionable row.
- Crossfades, blur and translucent layers can help continuity, but assess readability and rendering cost in the target browser/device before adding them.

## Check the result

Try a fast flick, slow release, immediate reversal, grab during settling, pointer cancellation, scrolling past the gesture and repeated activation. Check keyboard/screen-reader alternatives and reduced motion. Slow playback can expose discontinuities; normal-speed playback and representative hardware determine perceived responsiveness.
