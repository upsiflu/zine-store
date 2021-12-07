module Tile exposing (Tile(..), Instance(..), view)
import Html exposing (Html, button, div, h1, h2, h3, h5, img, input, p, text, form, small)
import Html.Attributes exposing (style, placeholder, src, value, id, disabled, type_)
import Html.Events exposing (onClick, onInput, onSubmit)




type Tile 
    = Tile Instance Position

type Instance
    = Square

type alias Position = {x : Int, y:Int, scalePercentage:Int}

view : Tile -> Html msg
view (Tile instance position) =
    let
        diameter = px (position.scalePercentage * 1)
    in div 
        [ px position.x |> style "left"
        , px position.y |> style "top"
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