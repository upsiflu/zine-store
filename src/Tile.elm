module Tile exposing
    ( Tile(..), Instance(..), Msg
    , Action
    , reposition
    , update
    , view
    )

{-|

@docs Tile, Instance, Msg
@docs Action
@docs reposition
@docs update
@docs view

-}

import Gui exposing (Gui)
import Html exposing (Html, button, div, form, h1, h2, h3, h5, img, input, p, small, text)
import Html.Attributes exposing (disabled, id, placeholder, src, style, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Extra as Html
import Gesture exposing (Delta)


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
        |> Debug.log "Repositioning Tile"


{-| -}
view : Tile -> Gui msg
view (Tile instance position) =
    let
        px = 
            String.fromInt >> (\n -> n ++ "px")
            
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
        , id "tile"
        ]
        [ text "" ]
        |> (\tile ->
                Gui.singleton { handle = Html.nothing, scene = tile, info = Html.nothing, control = Html.nothing }
           )



