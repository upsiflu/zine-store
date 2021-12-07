# Zine-Store

_Check [the most recently deployed demo here](https://zine-store.web.app/)! If it's out of date, [deploy yourself](#deploying-the-frontend)_

**Scope: Implementing a provisory firestore backend to prototype the [zine, an app for creating and infinite collages of editable hypertext blocks](https://github.com/upsiflu/zine).** In the long run, _the firestore will be replaced by a p2p backend_. Check [nextgraph](http://nextgraph.org/) and [P2PKB](https://drive.allmende.io/code/#/3/code/view/0082f96ab016f40545f0ed9dd31169e6/) for an emerging solution from TG, Nico and Jon.

What this sandbox is made for:

* Try out different CRDTs, and multi-avatar, multi-user cases in general
* Evaluate and test Ui ideas in Elm
* Showcase some of the ideas behing Zine

## Features

- [x] [Authenticate and persist](#database-and-auth) 
- [x] [Moving and Scaling Tiles](#moving-and-scaling-tiles) with 2-finger gestures
- [ ] Editable Hypertext Tile
- [ ] Lasso Tile
- [ ] Scrolling and Zooming


### Database and Auth

Administer the `zine-store` project through the [Firebase console](https://console.firebase.google.com/?pli=1):

- Change Auth providers
- Change Rules


### Moving and Scaling Tiles

- [x] Implement a basic tile (square)
- [ ] Pointer layer to sense device-specific gestures
- - [x] Pinch on a touchpad
- [ ] Wrap gestures in a custom element to limit the hitTarget 


## Running a frontend test server

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



-------

Have a lot of fun 💖