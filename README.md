# Zine-Store

Implementing a firestore backend for the [zine, an app for creating and infinite collages of editable hypertext blocks](https://github.com/upsiflu/zine). In the long run, _this will be replaced by a p2p backend_ with a minimal discovery server.

What this sandbox is made for:

* Try out different CRDTs, and multi-avatar, multi-user cases in general
* Evaluate and test Ui ideas in Elm
* Showcase some of the ideas behing Zine


### Database and Auth

Administer the `zine-store` project through the [Firebase console](https://console.firebase.google.com/?pli=1):

- Change Auth providers
- Change Rules. As of now, actions are stored individually, per-user:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
		match /users/{userId}/messages/{messageId} {
      allow create, read, update, delete: if request.auth.uid == userId;
    }
  }
}
```

### Running a frontend test server

- Clone this repo, then install the external deps: `npm install`.
- Check the `.env` file in your root folder, which encodes the [Firebase config object](https://firebase.google.com/docs/web/setup#config-object).
- Run the local test server: `npm start`.

The local server will act upon the same database as the public one, but will use the locally supplied frontend files in `src/`.

### Deploying the frontend

* to the Google hosting service: `firebase deploy`.
* to any other hosting server: run `npm run build`, then upload the `dist/` folder.

## Authors

* [flupsi](https://flupsi.com) / [upsiflu on Github](https://github.com/upsiflu)
* [Julien Lengrand-Lambert](https://twitter.com/jlengrand)

This is a fork from Julien's beautiful firestore+[Elm 0.19](https://elm-lang.org)+parcel [template](https://github.com/jlengrand/elm-firebase), as announced [here](https://lengrand.fr/using-firebase-in-elm/).
