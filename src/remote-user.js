import { initializeApp } from 'firebase/app';
import { getAuth, signInWithPopup, signOut, GoogleAuthProvider, onAuthStateChanged } from "firebase/auth";
import { query, getFirestore, collection, addDoc, onSnapshot } from "firebase/firestore";




















/**
 * syncs a firebase user
 **/
export class RemoteUser extends HTMLElement {
  firebaseConfig;
  firebaseApp;
  provider;
  auth;
  db;



  // Attributes come from Elm
  static get observedAttributes() {
    return ['command', 'recent-note'];
  }

  constructor() {
    super();
    this.firebaseConfig = {
      apiKey: process.env.ELM_APP_API_KEY,
      authDomain: process.env.ELM_APP_AUTH_DOMAIN,
      databaseURL: process.env.ELM_APP_DATABASE_URL,
      projectId: process.env.ELM_APP_PROJECT_ID,
      storageBucket: process.env.ELM_APP_STORAGE_BUCKET,
      messagingSenderId: process.env.ELM_APP_MESSAGING_SENDER_ID,
      appId: process.env.ELM_APP_APP_ID
    };

    this.firebaseApp = initializeApp(this.firebaseConfig);

    this.provider = new GoogleAuthProvider();
    this.auth = getAuth();
    console.log("set this.auth=", this.auth)
    this.db = getFirestore();


  }

  connectedCallback() {
    console.log("connectedCallback");
    // here goes the code you want to run when your custom element is rendered and initialised

    // Just checking envs are defined - Debug statement
    console.log(process.env.ELM_APP_API_KEY !== undefined ? "Environment initialized" : "Environment variables missing -- Host .env file");

    // EVENTS
    // Observer on user info
    onAuthStateChanged(this.auth, user => {
      if (user) {
        console.log("User received:", user);
        user
          .getIdToken()
          .then(idToken => {
            this.dispatchEvent(new CustomEvent(
              "signInInfo",
              {
                detail: {
                  token: idToken,
                  email: user.email,
                  uid: user.uid
                }
              }
            ))
          })
          .catch(error => {
            console.log("Error when retrieving cached user");
            console.log(error);
          });

        // Set up listener on new notes
        const messageQuery = query(collection(this.db, `users/${user.uid}/messages`));
        onSnapshot(messageQuery, querySnapshot => {
          console.log("Received new snapshot");
          const messages = [];

          querySnapshot.forEach(doc => {
            if (doc.data().content) {
              messages.push(doc.data().content);
            }
          });
          /*
          app.ports.receiveMessages.send({
            messages: messages
          });
          */
        });
      } else {
        console.log("User is nullish:", user);
        //app.ports.receiveNull.send({});
      }
    });

  }

  disconnectedCallback() {
    console.log("disconnectedCallback");
    // here goes the actions you should do when it's time to destroy/remove your custom element
  }


  // ATTRIBUTES
  attributeChangedCallback(name, oldValue, newValue) {
    console.log(name, ":=", oldValue, "->", newValue);
    if (name == 'command') {
      ({
        'LogIn': () => {
          console.log("Logging In");
          signInWithPopup(this.auth, this.provider)
            .then(result => {
              result.user.getIdToken().then(idToken => {
                this.dispatchEvent(new CustomEvent(
                  "signInInfo",
                  {
                    detail: {
                      token: idToken,
                      email: result.user.email,
                      uid: result.user.uid
                    }
                  }
                ))
              });
            })
            .catch(error => {
              //this.app.ports.signInError.send({
              //  code: error.code,
              //  message: error.message
            });
        },
        'LogOut': () => {
          console.log("Logging Out");
          console.log(this.auth)
          signOut(this.auth);
        },
        'AddNote': data => {
          console.log(`saving message to database : ${data.content}`);
          addDoc(collection(this.db, `users/${data.uid}/notes`), {
            content: data.content
          }).catch(error => {
            /*
            app.ports.noteError.send({
              code: error.code,
              message: error.message
            });
            */
          });
        },
        'DecodingError': () => { console.log("Decoding error") }
      })[newValue]();
    }



  }


}
customElements.define('remote-user', RemoteUser);

