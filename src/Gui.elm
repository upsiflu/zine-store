module Gui exposing (Gui, createInfo, createScene, createStatus, createControl, disclose, withStatus, map, view)

{-|-}


import Html exposing (Html, span, button, label, fieldset, legend, input, div, h1, h2, h3, h5, img, p, text, form, small, summary, details)
import Html.Attributes exposing (placeholder, src, class, value, id, disabled, type_, checked, for)
import Html.Events exposing (onClick, onInput, onSubmit)




{-| represents an object with meta info, which can be **composed** with other `Gui`s.

This module uses phantom types. Per Jeroen,

Possible operations with phantom extensible builders

-    Add a new field
-    Remove a field
-    Change the type of a field
-    Remove the previously existing phantom type and change it to an empty record (not extensible, just a hardcoded return type) i.e. Replace

What you can do with phantom builder

-    Require something to be always called
-    Forbid something being called more than once
-    Cause other constraints dynamically after calling something
-    Make function calls mutually exclusive
-    Enable a function only if another one has been called

Why would we ever want that?

- A Gui can be created by choosing one of the four roles `info`, `status`, `scene`, `control`.
- Guis can be freely `combine`d. Internally, the distinction between roles is kept.
- A Gui can only be `view`ed if at least one status element exists.


`info` is a list of dismissible or disclosable messages (for example toasts),
`status` comprises the permanent handles to the object (for example, an avatar plus a login/logout button)
`scene` represents data that can be manipulated in-place.
`control` is the set of tools related to the object.

-}
type Gui constraints msg = 
    Gui 
        (List (Info msg)) 
        (List (Status msg)) 
        (List (Scene msg)) 
        (List (Control msg))

empty : Gui {} msg
empty = Gui [] [] [] []


{-|-}
createInfo : Html msg -> Info msg
createinfo c = Gui [c] [] [] []

type alias Info msg = Gui {role=InfoR} msg

{-|-}
createStatus : Html msg -> Status msg
createStatus c = Gui [] [c] [] []

type alias Status msg = Gui {role=StatusR, viewable = ()} msg

{-|-}
createScene : Html msg -> Scene msg
createScene c = Gui [] [] [c] []

type alias Scene msg = Gui {role=SceneR} msg

{-|-}
createControl : Html msg -> Control msg
createControl c = Gui [] [] [] [c]

type alias Control msg = Gui {role=ControlR} msg

type Role
    = InfoR | StatusR | SceneR | ControlR





---- MODIFY ----


{-| add some Gui to a `viewable` Gui -}
withStatus : Gui { ca | viewable } msg -> Gui cb msg -> Gui ca msg
withStatus (Gui a0 a1 a2 a3) (Gui b0 b1 b2 b3) =
    Gui (a0++b0) (a1++b1) (a2++b3) (a4++b4)


{-|-}
map : (a -> b) -> Gui c a  -> Gui c b
map fu (Gui elements) =
    Gui (List.map (Html.map fu) elements)
    

---- VIEW ----

{-|-}

disclose : List (Html msg) -> List (Html msg) -> Status msg
disclose a b =
    details [] [ summary [] a, div [class "popup"] b ]
        |> Status

{-|-}
view : Gui { constraints | viewable } msg -> Html msg
view (Gui info status scene control) =
    let

        optionsDisclosure =
                [ fieldset [class "chrome"]
                    [ input [type_ "checkbox", id "natural", checked True] []
                    , label [class "chrome", for "natural"] [text "My trackpad is configured for natural scrolling"]
                    ]
                ] |> disclose [span [class "chrome"] [text "Input device"]]

        defaultStatus =
            [ optionsDisclosure
            , Status (h1 [] [ text "zine-store -- 2-fingure gestures. If you have a touchpad, try pinching and scrolling!" ])
            ]

        chrome =
            div [ class "chrome-bar" ]
                [ status
                    |> (++) defaultStatus
                    |> List.map (\(Status s) -> s)
                    |> div [class "top chrome"]
                , control
                    |> List.map (\(Control c) -> c)
                    |> div [class "bottom chrome"]
                ]

        viewport =
            scene
                |> List.map (\(Scene s) -> s)
                |> div [class "mosaic"]

    in div [] [viewport, chrome]
