# DESIGN

## Potential Domains (from near to far):
1. **Interactive, borderless zine (where everyone is co-editor)**
0. **Applied `Shell` research! I.e. Zine is an open, malleable, community-centric `Shell`, in contrast to the proprietary, siloed, or convention-encumbered nature of other Shells. So any team can evaluate Shell-related research questions on a real, in-use Shell. Such investigations could pertain to UX patterns, Embodiment, Co-imagination, Shell<-->Community relations, Knowledge<-->Space relations, or Emergent Vernaculars/Memes.**
2. Online art galleries and portfolios, DIY libraries, Multimedia Publishing for activists
3. Organising events and making physical encounters possible
4. Composting "knowledge" in its less refined, more malleable forms, gardens of knowledge and ideation -- an alternative to more structured notetaking and wiki apps
5. Modelling global gift-economy logistics

## Tenets

**Open!**

- Accept anything you can Ctrl+C from any website or document
(minus executable or very exotic stuff)
- Share viewport (x time); share object; export into some open formats
- Travel in time as well as in 2D (or geo?) space
- FOSS Code

**Malleable!**

- Arrange anything freely spatially
- Apply masks, transformations, light-gels, and blend modes
- Low coupling of modules and HMR allow for quick prototyping and evaluation of ideas

**Community-centric!**

- p2p, via Matrix (...)
- Accessible-first; deviant-body-centric design
- Manual Curation facilities (plus simple programmable gossip-bots?)
- Avatars come together in affinity groups: not through belonging but through longing and pragmatic cooperation
- Low barriers for participation: Modular design and exhaustive documentation
- Embedded in a research project and connected with curational projects such as 'Moving across Thresholds' and 'Shell'
- Independent development and funding model: Accountable only to its own principles (?) -> like [Projektwerkstatt auf Gegenseitigkeit ("dissidente Subsistenz)!](https://gegenseitig.de/page/prinzipien.php)

**Example:**

| Tenet | Use Case | Implementation |
| ------ | ----- | ----- |
| Open | interoperable data | An `Html` subset plus CRDT |
| Malleable | image and hypertext collage | A `Graph` CRDT? |
| Community-centric | decentral proliferation | A p2p protocol |

## Use

1. No-installation web-app
2. Local-first (usable without login for local data)
3. Scroll, browse the history, zoom, and share your viewport:
    - infinite 2D space
    - POSIX time travel through the data-history (may diverge slightly due to the CRDT "eventuality")
    - zoom freely
    - Browser history api to 'go back/forward' through the client's viewport-history
    - (Url) Address encodes viewport
4. Add, WYSIWYG-edit and remove hypertext scraps such as rich text, images, videos, audio, hypermedia...
    - Copy/Cut/Paste allows for splitting, combining, exporting and importing arbitrary stuff
4. Add and remove viewport sequences ("Stories")
5. Global undo
6. Allow concurrent edits on
    - the level of individual scrap content
    - the level of scrap positioning, order, and transformations (light, goo, blendmode, mask)
7. Export a viewport to pdf, Html+Svg, etc.
8. Shared, potentially forgetful, always incomplete source of truth.

## Related Projects

- `farm` from ink&switch: `Elm` + `hypercore` + `automerge`; abandoned since 2018; doesn't compile


## Choice of Modules and Protocols

### Infrastructure

- `syncedstore`: `Yjs`; implements several CRDTs; bindings to Svelte, React, Vue, but not Elm (looks possible to derive though)
- `matrix-p2p`: very successful infrastructure; Jon has a running backend (?) (which CRDT?)

### Frontend Modules

`remote-user` as custom element
: syncs to and from a unique namespace (=unique user id or email or so, but can also be anonymous/public or local-only); couples with `User` Elm module
: - has a list of `(id, type)` tuples such as `("hypertext0", Type.RichText)`
: - manages the necessary `syncedstore` setup and events
: - also connects to an auth provider
: - what about alternatives to the user-centric p2p model? Any prior art?
: - Idea: 'collective' users per affinity-group; user avatars can morph into affinity-group members, and back...

`hypertext-editor` as custom element
: WYSIWYG; couples with `Hypertext` Elm module
: - accepts `paste` operations
: - offers hooks into Elm for a toolbar (and floating widgets in the future)
: - accepts a namespace (unique user id) from Elm
: - Throttled Event pushes updates into Elm


## Implementation ideas (just sketches)

### Main

```elm
init =
    { alice = User.singleton
        { id = "alice"
        , howToUpdate = 
            \fu -> Edited 
                <| \model -> { model | model.alice = fu model.alice }
        }
    , bob = User.singleton
        { id = "bob"
        , howToUpdate = 
            \fu -> Edited 
                <| \model -> { model | model.bob = fu model.bob }
        }
    }

type Msg
    = Incremented ( Model -> Model )

update msg model =
    case msg of
        Edited fu ->
            fu model

view model =
    let
        viewAuthoredHypertext id author =
            Hypertext.view
                { content = User.fetch id author
                , howToUpdate = \edit -> User.store edit (author model)
                }
    in
    [ User.view model.alice
    , User.view model.bob
    , viewAuthoredHypertext "my essay" .alice
    , viewAuthoredHypertext "my essay" .bob
    ] 
        |> Gui.concat
        |> Gui.view
```

### User

```elm
type User msg
    = User (Config msg) Int Command

type alias Config msg =
        { id : String --globally unique?
        , howToUpdate : (User msg -> User msg) -> msg
        }

type alias Command = ( String, String )

fetch : String -> User -> String
fetch _ (User { id }) = 
    "User <"++id++"> fetched dummy text."

{-| Intent to change the command.
The actual dispatching of the command happens in the `view` through attributes. -}
store : (String, String) -> User -> msg
store command ( User { howToUpdate } _ _ ) = 
    howToUpdate
        (\(User config_ count_ command_) -> 
            User config_ (count_+1) command
        )

singleton :
    { id : String
    , howToUpdate : mdl -> msg
    } -> 
    User mdl msg
singleton = User

view : User msg -> Gui msg
view (User config count command) =
    remote-user
        

```

### Hypertext

```elm
singleton :
    { id : String --unique per `User`
    , onEdit : mdl -> msg
    }

view :
    { content = User.fetch id author
    , howToUpdate = \edit -> User.store edit (author model)
    }
```