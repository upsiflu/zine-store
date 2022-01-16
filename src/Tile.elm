module Tile exposing
    ( Tile(..), Instance(..), Msg
    , Action
    , reposition, Delta
    , update
    , view
    )

{-|

@docs Tile, Instance, Msg
@docs Action
@docs reposition, Delta
@docs update
@docs view

-}

import Gui exposing (Gui)
import Html exposing (Html, button, div, form, h1, h2, h3, h5, img, input, p, small, text)
import Html.Attributes exposing (disabled, id, placeholder, src, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Extra as Html


{-| -}
type Msg
    = Noop


{-| Movable, transformable item in a collage.
-}
type Tile
    = Tile Instance Position


{-| Shape or Content of a specific Tile
-}
type Instance
    = Square


{-| Shape or Content of a specific Tile
-}
type Action
    = MergeDelta Delta


{-| Relation of a Tile to the flobal coordinate system
-}
type alias Position =
    { x : Int, y : Int, scalePercentage : Int }


{-| Cumulative change of `Position`
-}
type alias Delta =
    Position


{-| -}
update : Msg -> Tile -> Tile
update msg tile =
    tile


{-| -}
reposition : Delta -> Tile -> Tile
reposition delta (Tile instance position) =
    Tile
        instance
        { position
            | x = position.x + delta.x
            , y = position.y + delta.y
            , scalePercentage = (position.scalePercentage * delta.scalePercentage) // 100
        }


{-| -}
view : Tile -> Gui msg
view (Tile instance position) =
    let
        diameter =
            px (position.scalePercentage * 1)

        radius =
            position.scalePercentage * 1 // 2
    in
    div
        [ px (position.x - radius) |> style "left"
        , px (position.y - radius) |> style "top"
        , style "background-color" "red"
        , style "position" "relative"
        , style "width" diameter
        , style "height" diameter
        , id "box"
        ]
        [ text "" ]
        |> (\box ->
                Gui.singleton { handle = Html.nothing, scene = box, info = Html.nothing, control = Html.nothing }
           )



---- Helpers


px : Int -> String
px =
    String.fromInt >> (\n -> n ++ "px")
