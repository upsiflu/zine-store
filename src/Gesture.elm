module Gesture exposing ( Gesture, Delta, Error(..), init, errorToString, view)

{-|

## Custom Element `client-gesture`


### Attributes


### Events

  - (WIP)


### Considerations

  - can appear multiple times in an app
  - listens to gestures only inside its bounds
  - can be configured for many hardware variants such as multitouch, touchpad, keyboard, etc.

# Model

@docs Gesture, init


# Update

@docs Msg, update


# View

@docs view

-}

import Gui exposing (Gui)
import Html exposing (Html, button, details, div, fieldset, form, h1, h2, h3, h5, img, input, label, legend, p, small, span, summary, text)
import Html.Attributes as Attributes exposing (checked, class, disabled, for, id, placeholder, src, type_, value)
import Html.Events as Events exposing (onClick, onInput, onSubmit)
import Html.Extra as Html exposing (nothing)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Field as Field
import Json.Encode as Encode
import RemoteData exposing (RemoteData(..))
import Result.Extra as Result


---- CREATE ----


{-|
-}
type Gesture msg
    = Gesture (Config msg)


type Error
    = DecodingError String
    | ClientError String

clientErrorDecoder : Decoder String
clientErrorDecoder =
    Field.require "error" Decode.string Decode.succeed

{-|-}
errorToString : Error -> String
errorToString error =
    case error of
        DecodingError str -> "Decoding error: "++str
        ClientError str -> "Client error:" ++ str



type alias Config msg =
    { onError : Error -> msg, onGesture : Delta -> msg }


{-| `User` with no notes and an empty string note input field
-}
init : Config msg -> Gesture msg
init = Gesture


---- UPDATE ----


{-| -}
type Msg
    = GestureReceived (Result Decode.Error Delta)


{-| relative transformation
-}
type alias Delta =
    { x : Int, y : Int, scalePercentage : Int }

{-| `-> Result DecoderError Delta` -}
deltaDecoder : Decoder Delta
deltaDecoder =
    Field.require "x" Decode.int <|
        \x ->
            Field.require "y" Decode.int <|
                \y ->
                    Field.require "scalePercentage" Decode.int <|
                        \scalePercentage ->
                            Decode.succeed { x = x, y = y, scalePercentage = scalePercentage }


---- VIEW ----


{-| -}
view : Gesture msg -> Gui msg
view (Gesture config) =
    let
        attributes =
            [ Events.on "gesture"
                <| Decode.map 
                    ( Decode.decodeValue deltaDecoder >> Result.unpack 
                        ( Decode.errorToString >> DecodingError >> config.onError ) 
                        config.onGesture
                    ) 
                    Decode.value 
            , Events.on "error"
                <| Decode.map 
                    ( Decode.decodeValue clientErrorDecoder >> Result.unpack 
                        (Decode.errorToString >> DecodingError >> config.onError) 
                        (ClientError >> config.onError)
                    ) 
                    Decode.value
            ]
    in
    { handle = nothing
    , control = nothing
    , scene = Html.node "client-gestures" attributes []
    , info = nothing
    }
        |> Gui.singleton
