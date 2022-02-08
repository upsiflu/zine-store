# Domain Model

From Jon came [On Domain/Documentation Driven Design (_DDD_)](http://ddd.fed.wiki.org/view/welcome-visitors/view/domain-driven-design)

- This Domain Model is the ["Backbone of a _Ubiquitous Language_"](http://ddd.fed.wiki.org/view/welcome-visitors/view/domain-driven-design/view/ubiquitous-language)
- It is tied to its own implementation in a back-and-forth, so this document will only expose the API.
- A Shell has two sides. One is calcic, sending and receiving constantly, and floating in the "Sea of information". The other side is soft and slimy, allowing for weird and wondrous scriptures, user programming, emotional singularities. The _Domain Model_ spans the space between the two.

# Back-End

_This is where intention becomes memory and vice versa, where possibilities become facts and vice versa, where writings cross each other to produce hermetic hieroglyphs, or vice versa._

## Layer One: Hypermedia Blocks

Users can create and edit "Scraps", positioned blocks of hypermedia, on an infinite 2D surface (plus a time dimension which doesn't need to converge among all users and where histories can be forgotten accidentally).

**Shape**: 

1. A sane subset of Html is valid Hypermedia.
2. A single block of Hypermedia can be edited concurrently.
3. Conflict resolution should be fully automatic, even if that means sometimes decisions are weird or arbitrary.
4. A block is usually short, so just storing the history of edits is sufficient, we don't need the backend to store snapshots of rendered hypermedia.
5. If a block is too long, the frontend can cut it into pieces.
6. Old blocks may deteriorate and lose memory. They become ruins, ghastly ghosts of their former selves. Only a proper restauration can save them from obliviation.

**ID**: Blocks can be uniquely addressed via a hash of their content, or through an immutable random id plus an index that stores a mutable content-hash.

**Mutations**: The most common interaction pattern will be copy, cut, paste. Many blocks will only consist of a single image or a single video. But there is also the case of collaborative WYSIWYG document editing (deletion, insertion, cursor movement, selection, replacement, shifting passages), which should be supported to a bearable extent. And since we are working with Hypermedia, typical operations such as link reference editing, image scaling, or adding and removal of track elements within a video/audio element should be handled gracefully and concurrently. Deterioration should happen randomly, like a virus, on the backend, re-compressing JPEGs, ASCII-encoding Unicode text, Trident-rendering Html5, and the like.


## Layer Two: Scraps on a Canvas

**Shape**: 

1. The Canvas is a 2D euklidean coordinate system with a set of positioned `Scrap`s.
2. A Scrap can hold:
    a. A block of Hypermedia (potentially more blocks)
    b. A lasso selection (Polygon)
    c. A reference to such a Polygon for Transclusion
3. Furthermore, a Scrap may have a transformation,
   which may include light, goo, blendmode, alpha-mask data.

**ID**: Scraps could be addressed through their position, for example stored in a quadrant-tree, which would make it very quick to "retrieve all scraps that overlap with Polygon P". This means that references to scraps need to chase their position, or that there needs to be an intermediary index and scraps have immutable ids.

**Mutations**: The position can only be changed by one avatar at a time, so there's no need for conflict resolution here. The type of a Scrap (Hypermedia/Lasso/Transclusion) is immutable. In case of a Hypermedia block, the reference chases the content hash but cannot be changed to point to a different block. In case of a Lasso reference, it can be immutable.

## Layer Three: Avatars

**Shape**: 

1. An Avatar is not tied to a user although probably most avatars will have a 1:1 relation to a user. More on embodiment under [Layer Four: Users]
2. Any avatar can walk in four directions but has a fixed (very low!) speed. In addition, an avatar can go on a time travel to observe a previous state of the canvas. Since the world is forgetful, distant pasts are piles of ruins.
3. Only Avatars can cause mutations, only when they are standing on top of the element they affect. This means that any mutation recorded in any CRDT will have one avatar as its author.
4. Avatars are chimeras, so each of their limbs (head, back, belly, ass, front-legs, hind-legs, tail, wings) is from one of the followind constructors: `Dog | Dragon | Mouse | Frog | Catboy | Witch | Ogre | Salamander | Conductor | Squirrel | Albatross | Whale | Sukkulent | Butterfly | Fungus`. This is immutable, and could be a JSON or a binary image file or so.
5. In future versions, an Avatar may have a voice effect and a video filter and a signature and an age, all of which would be mutable, in a schemed (protobuf or so) but not necessarily in a concurrent (CRDT) manner. One possible feature would be private notes and bookmarks: a small number or scraps that are private to the avatar and invisible to anyone else.

**ID**: Can be a random string. Or a hash of its body-parts.

**Mutations**: An avatar will react to the set of users that currently embody it. In addition, see Point 5.

## Layer four: Users

**Shape**: 

1. A user can "embody" one or zero avatars at a time. But this avatar can simultaneously be embodied by a different user.
2. A single user can have many clients, windows and tabs open, and operate multiple pointing devices at once, and be an octopus btw, so multiple sessions of a single users can happen simultaneously, and come into conflict with each other.
3. If a user is not logged in, they identify through their client ID (if that is technically possible).
4. If such an anonymous user logs in, they can choose to integrate their anonymous data into the proper user's history (this is a pettern you see in shopping sites where you can fill your basket and then log in, and then the basket is migrated into the proper user).
3. A user may provide such things as e-mail address, username, etc. An interesting feature of scuttlebutt is that people can apply funny names to each other, which the receiver of the name cannot see (like in the game where you get a little scrap of paper on your forehead and need to guess who you are).
4. Accessibility, discoverability/visibility and security preferences should be stored per-user.

**ID**: Could be some identity provider, or the browser (browsers can do auth, and I trust my firefox), or unique username plus password plus email. I don't know. You have better ideas about that.

**Mutation**: Avatar changes through time and needs to be synced across sessions. When a user goes offline, the avatar gets dormant and sleeps. In addition, preferences will occasionally change. CRDT would be cool (in the case of a time-traveling multi-personality octopus user it's necessary).

## Layer five: The Gossip-Bots!

**Shape**: 

1. These are gossip bots that roam the canvas like viruses.
2. A Gossip-Bot has a little carrier bag (666k or so) in which they can accumulate data. Their speed should be somewhat antiproportional to their CPU hunger. And they should have a programmed death date I think.
3. This is not a mature concept yet.

**ID**: They are super wicked, so they could pretend to be users or avatars or even scraps?

**Mutation** Severely limited. Although... I'd love to see a Gossip-Bot named Puppetmaster to merge their DNA with an Avatar called Motoko Kusanagi on a Canvas named Shell...

# Front-End

_Hello Community! Hello Fun and Frustration and Fiction and Friction!_