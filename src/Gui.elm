module Gui exposing (Gui, Item, disclose, map, singleton, view, with)

{-| -}

import Html exposing (Html, button, details, div, fieldset, form, h1, h2, h3, h5, img, input, label, legend, p, small, span, summary, text)
import Html.Attributes exposing (checked, class, disabled, for, id, placeholder, src, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Extra as Html exposing (nothing)


{-| consists of several `Item`s that are somewhat orthogonal to each other.
-}
type Gui msg
    = Gui (List (Item msg))


{-| -}
type alias Item msg =
    { handle : Html msg, scene : Html msg, info : Html msg, control : Html msg }


{-| `info` is a list of dismissible or disclosable messages (for example toasts),
`handle` comprises the permanent handles to the object (for example, an avatar plus a login/logout button)
and that potentially includes custom-elements for syncing with a backend.
`scene` represents data that can be manipulated in-place.
`control` is the set of tools related to the object.
-}
singleton : Item msg -> Gui msg
singleton =
    List.singleton >> Gui



---- MODIFY ----


{-| -}
map : (a -> b) -> Gui a -> Gui b
map fu (Gui items) =
    let
        mapFacet =
            Html.map fu

        mapItem i =
            { handle = mapFacet i.handle
            , scene = mapFacet i.scene
            , info = mapFacet i.info
            , control = mapFacet i.control
            }
    in
    Gui (List.map mapItem items)



---- COMPOSE ----


{-| compose two `Gui`s into one
-}
with : Gui msg -> Gui msg -> Gui msg
with (Gui l0) (Gui l1) =
    Gui (l0 ++ l1)



---- VIEW ----


{-| -}
disclose : List (Html msg) -> List (Html msg) -> Html msg
disclose more handle =
    details [] [ summary [] handle, div [ class "popup" ] more ]


{-| -}
view : Gui msg -> Html msg
view (Gui items) =
    let
        defaultOptionItem =
            disclose
                [ fieldset [ class "chrome" ]
                    [ input [ type_ "checkbox", id "natural", checked True ] []
                    , label [ class "chrome", for "natural" ] [ text "My trackpad is configured for natural scrolling" ]
                    ]
                ]
                [ span [ class "chrome" ] [ text "Input device" ]
                , h1 [] [ text "zine-store -- 2-fingure gestures. If you have a touchpad, try pinching and scrolling!" ]
                ]
                |> (\handle -> Item handle nothing nothing nothing)

        viewItem i =
            div []
                [ div
                    [ class "mosaic" ]
                    i.scenes
                , div
                    [ class "chrome-bar" ]
                    [ div
                        [ class "top chrome" ]
                        i.handles
                    , div
                        [ class "bottom chrome" ]
                        (i.infos ++ i.controls)
                    ]
                ]
    in
    defaultOptionItem
        :: items
        |> List.foldl
            (\item acc ->
                { acc
                    | handles = item.handle :: acc.handles
                    , scenes = item.scene :: acc.scenes
                    , infos = item.info :: acc.infos
                    , controls = item.control :: acc.controls
                }
            )
            { handles = []
            , scenes = []
            , infos = []
            , controls = []
            }
        |> viewItem
