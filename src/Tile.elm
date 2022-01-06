module Tile exposing (Tile(..), Instance(..), view, reposition, Delta, Action)


import Html exposing (Html, button, div, h1, h2, h3, h5, img, input, p, text, form, small)
import Html.Attributes exposing (style, placeholder, src, value, id, disabled, type_)
import Html.Events exposing (onClick, onInput, onSubmit)




type Tile 
    = Tile Instance Position

type Instance
    = Square

type Action
    = MergeDelta Delta

type alias Position = {x : Int, y:Int, scalePercentage:Int}
type alias Delta = Position

reposition : Delta -> Tile -> Tile
reposition delta (Tile instance position) =
    Tile instance { position | x = position.x+delta.x, y=position.y+delta.y, scalePercentage=(position.scalePercentage*delta.scalePercentage)//100}

view : Tile -> Html msg
view (Tile instance position) =
    let
        diameter = px (position.scalePercentage * 1)
        radius = position.scalePercentage * 1 // 2
    in div 
        [ px (position.x-radius) |> style "left"
        , px (position.y-radius) |> style "top"
        , style "background-color" "red"
        , style "position" "relative"
        , style "width" diameter
        , style "height" diameter
        , id "box"
        ]
        [text ""]


---- Helpers

px : Int -> String
px = String.fromInt >> (\n -> n++"px")