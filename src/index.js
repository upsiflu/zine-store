import { Elm } from "./Main.elm";
import registerServiceWorker from "./registerServiceWorker";
import { } from './remote-user'

const app = Elm.Main.init({
  node: document.getElementById("root")
});





/** GESTURE port! */
/* https://jsbin.com/cebiwiwesu/edit?js,output */

var tx = 0;
var ty = 0;
var scale = 1;

var timeout = null;

var consolidateDelta = e => {
  timeout = null;
  var myDelta = {
    x: tx,
    y: ty,
    scalePercentage: Math.round(scale * 100)
  }

  console.log("consolidate delta", myDelta);

  tx = 0;
  ty = 0;
  scale = 1;


  box.style.transform = `translate(${tx}px, ${ty}px) scale(${scale})`;
  app.ports.receiveDelta.send(myDelta);
}
document.addEventListener('wheel', event => {
  event.preventDefault();

  if (timeout) clearTimeout(timeout);
  timeout = setTimeout(consolidateDelta, 50);

  if (event.ctrlKey) {
    var s = Math.exp(-event.deltaY / 100);
    scale *= s;
  } else {
    var direction = natural.checked ? -1 : 1;
    tx += event.deltaX * direction;
    ty += event.deltaY * direction;
  }

  box.style.transform = `translate(${tx}px, ${ty}px) scale(${scale})`;
}, { passive: false });


var lastGestureX = 0;
var lastGestureY = 0;
var lastGestureScale = 1.0;
function onGesture(event) {
  event.preventDefault();

  if (event.type === 'gesturestart') {
    lastGestureX = event.screenX;
    lastGestureY = event.screenY;
    lastGestureScale = event.scale;
  }

  if (event.type === 'gesturechange') {
    tx += event.screenX - lastGestureX;
    ty += event.screenY - lastGestureY;
  }

  scale *= 1.0 + (event.scale - lastGestureScale);

  lastGestureX = event.screenX;
  lastGestureY = event.screenY;
  lastGestureScale = event.scale;

  console.log(event);

  box.style.transform = `translate(${tx}px, ${ty}px) scale(${scale})`;
}

document.addEventListener('gesturestart', onGesture);
document.addEventListener('gesturechange', onGesture);
document.addEventListener('gestureend', onGesture);


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
