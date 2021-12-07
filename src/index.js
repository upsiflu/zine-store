import { initializeApp } from 'firebase/app';
import { getAuth, signInWithPopup, signOut, GoogleAuthProvider, onAuthStateChanged } from "firebase/auth";
import { query, getFirestore, collection, addDoc, onSnapshot } from "firebase/firestore"; 

import { Elm } from "./Main.elm";
import registerServiceWorker from "./registerServiceWorker";

// Just checking envs are defined - Debug statement
console.log(process.env.ELM_APP_API_KEY !== undefined ? "Environment initialized" : "Environment variables missing -- Host .env file");

const firebaseConfig = {
  apiKey: process.env.ELM_APP_API_KEY,
  authDomain: process.env.ELM_APP_AUTH_DOMAIN,
  databaseURL: process.env.ELM_APP_DATABASE_URL,
  projectId: process.env.ELM_APP_PROJECT_ID,
  storageBucket: process.env.ELM_APP_STORAGE_BUCKET,
  messagingSenderId: process.env.ELM_APP_MESSAGING_SENDER_ID,
  appId: process.env.ELM_APP_APP_ID
};

const firebaseApp = initializeApp(firebaseConfig);

const provider = new GoogleAuthProvider();
const auth = getAuth();
const db = getFirestore();

const app = Elm.Main.init({
  node: document.getElementById("root")
});

app.ports.signIn.subscribe(() => {
  console.log("Logging In");
  signInWithPopup(auth, provider)
    .then(result => {
      result.user.getIdToken().then(idToken => {
        app.ports.signInInfo.send({
          token: idToken,
          email: result.user.email,
          uid: result.user.uid
        });
      });
    })
    .catch(error => {
      app.ports.signInError.send({
        code: error.code,
        message: error.message
      });
    });
});

app.ports.signOut.subscribe(() => {
  console.log("Logging Out");
  signOut(auth);
});

//  Observer on user info
onAuthStateChanged(auth, user => {
  console.log("User received:", user);
  if (user) {
    user
      .getIdToken()
      .then(idToken => {
        app.ports.signInInfo.send({
          token: idToken,
          email: user.email,
          uid: user.uid
        });
      })
      .catch(error => {
        console.log("Error when retrieving cached user");
        console.log(error);
      });

    // Set up listened on new messages
    const q = query(collection(db, `users/${user.uid}/messages`));
    onSnapshot(q, querySnapshot => {
      console.log("Received new snapshot");
      const messages = [];

      querySnapshot.forEach(doc => {
        if (doc.data().content) {
          messages.push(doc.data().content);
        }
      });

      app.ports.receiveMessages.send({
        messages: messages
      });
    });
  } else {
    app.ports.receiveNull.send({
    });
  }
});

app.ports.saveMessage.subscribe(data => {
  console.log(`saving message to database : ${data.content}`);

  addDoc(collection(db, `users/${data.uid}/messages`), {
    content: data.content
  }).catch(error => {
      app.ports.signInError.send({
        code: error.code,
        message: error.message
      });
    });
});


/** GESTURE port! */
/* https://jsbin.com/cebiwiwesu/edit?js,output */

var tx = 0;
var ty = 0;
var scale = 1;

document.addEventListener('wheel', event => {
	event.preventDefault();
  
	if (event.ctrlKey)
	{
    var s = Math.exp(-event.deltaY/100);
    scale *= s;
  }
	
	else
	{
    var direction = natural.checked ? -1 : 1;
    tx += event.deltaX * direction;
    ty += event.deltaY * direction;
  }
	
  box.style.transform = `translate(${tx}px, ${ty}px) scale(${scale})`;
}, {
	passive: false
});


var lastGestureX = 0;
var lastGestureY = 0;
var lastGestureScale = 1.0;
function onGesture(event) {
	event.preventDefault();
	
	if(event.type === 'gesturestart')
	{
		lastGestureX = event.screenX;
		lastGestureY = event.screenY;
		lastGestureScale = event.scale;
	}
	
	if(event.type === 'gesturechange')
	{
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
