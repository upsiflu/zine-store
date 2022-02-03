import { Elm } from "./Main.elm";
import registerServiceWorker from "./registerServiceWorker";
import { } from './remote-user'
import { } from './client-gestures'

const app = Elm.Main.init({
  node: document.getElementById("root")
});





// gesturestart
// Sent when two or more fingers touch the surface.

// gesturechange
// Sent when fingers are moved during a gesture.

// gestureend
// Sent when the gesture ends (when there are 1 or 0 fingers touching the surface).

// altKey
// A Boolean value indicating whether the alt key is pressed.

// ctrlKey
// A Boolean value indicating whether the control key is pressed.

// metaKey
// A Boolean value indicating whether the meta key is pressed.

// rotation
// The delta rotation since the start of an event, in degrees, where clockwise is positive and counter-clockwise is negative.

// scale
// The distance between two fingers since the start of an event, as a multiplier of the initial distance.

// shiftKey
// A Boolean value indicating whether the shift key is pressed.

// target
// The target of this gesture.




/** */
registerServiceWorker();
