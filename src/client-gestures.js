

/**
 * relays gestures within its boundaries that would be untenable to trace in pure Elm.
 * Code forks from https://jsbin.com/cebiwiwesu/edit?js,output 
 * 
 * Why a custom element for that? In the medium term, the client-gestures instance can be limited in these dimensions:
 *  - `sentinel` (bounds for receptivity, otherwise whole document)
 *  - `input-device` (touchpad, toucscreen, keyboard...)
 *  - `live-feedback` (a querySelectorAll string selects the DOMelements to affect)
 *  - `consolidation-interval` (how many milliseconds to wait until syncing a gesture)
 **/
export class ClientGestures extends HTMLElement {

  // Model
  tx;
  ty;
  scale;

  lastGestureX = 0;
  lastGestureY = 0;
  lastGestureScale = 1.0;

  // View elements
  viewport;
  box;

  // Mutating variables
  timeout;

  // Attributes come from Elm
  static get observedAttributes() {
    return ["sentinel", "input-device", "live-feedback", "consolidation-interval"];
  }

  constructor() {
    super();

    console.log("gesture constructed");

    this.tx = 0;
    this.ty = 0;
    this.scale = 1;

    this.viewport = document.createElement('div');
    this.box = document.createElement('div');
    this.box.id = "box";

    //The following three lines are dedicated to the iPhone with Safari//
    document.addEventListener('gesturestart', this.onGesture);
    document.addEventListener('gesturechange', this.onGesture);
    document.addEventListener('gestureend', this.onGesture);

    //And this is weird but well-supported: pinch zoom is registered as ctrl+wheel!
    document.addEventListener('wheel', this.onWheel, { passive: false });
  }

  onWheel(event) {
    event.preventDefault();

    console.log("wheel", event);

    if (this.timeout) clearTimeout(this.timeout);
    this.timeout = setTimeout(this.consolidateDelta, 50);

    if (event.ctrlKey) {
      var s = Math.exp(-event.deltaY / 100);
      this.scale *= s;
    } else {
      var direction = 1; //natural.checked ? -1 : 1;
      this.tx += event.deltaX * direction;
      this.ty += event.deltaY * direction;
    }

    this.box.style.transform = `translate(${this.tx}px, ${this.ty}px) scale(${this.scale})`;
  }

  onGesture(event) {
    event.preventDefault();

    console.log("onGesture", event);

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

  // Send accumulated gesture to Elm and reset this
  consolidateDelta() {
    this.timeout = null;
    var myDelta = {
      x: this.tx,
      y: this.ty,
      scalePercentage: Math.round(this.scale * 100)
    }

    console.log("consolidate delta", myDelta);

    this.tx = 0;
    this.ty = 0;
    this.scale = 1;

    this.box.style.transform = `translate(${tx}px, ${ty}px) scale(${scale})`;

    this.dispatchEvent(new CustomEvent("delta", { detail: myDelta }))
  }

  connectedCallback() {
    console.log("connectedCallback");
    this.append(this.viewport, this.box);
  }

  disconnectedCallback() {
    console.log("disconnectedCallback");
    // here goes the actions you should do when it's time to destroy/remove your custom element
  }


  // ATTRIBUTES
  attributeChangedCallback(name, oldValue, newValue) {
    console.log(name, ":=", oldValue, "->", newValue);
  }

}
customElements.define('client-gestures', ClientGestures);

