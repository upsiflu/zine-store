module Main exposing
    ( Model, init
    , Msg(..), update
    , view
    , main
    )

{-| Collaborative collage editor (exploration)

@docs Model, init
@docs Msg, update
@docs view
@docs main

-}

import Browser
import Gui
import Html exposing (Html, button, details, div, fieldset, form, h1, h2, h3, h5, img, input, label, legend, p, small, span, summary, text)
import Html.Attributes exposing (checked, class, disabled, for, id, placeholder, src, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Json.Decode
import Json.Decode.Pipeline
import Json.Encode
import RemoteData exposing (RemoteData(..))
import Tile exposing (Tile(..))
import User exposing (User)



{-
   ---- Outgoing
   port signIn : () -> Cmd msg
   port signOut : () -> Cmd msg
   port saveNote : Json.Encode.Value -> Cmd msg


   ---- Incoming
   port receiveNote : (Json.Encode.Value -> msg) -> Sub msg
   port noteError : (Json.Encode.Value -> msg) -> Sub msg

   port signInSuccess : (Json.Encode.Value -> msg) -> Sub msg
   port signInError : (Json.Encode.Value -> msg) -> Sub msg
   port receiveNull : (Json.Encode.Value -> msg) -> Sub msg
   port receiveDelta : (Json.Encode.Value -> msg) -> Sub msg
-}
---- MODEL ----


{-| relative transformation of a tile
-}
type alias Delta =
    { x : Int, y : Int, scalePercentage : Int }


{-| -}
type alias Model =
    { user : User
    , tile : Tile
    }


{-| -}
init : ( Model, Cmd Msg )
init =
    let
        initialTile =
            Tile Tile.Square >> Tile.reposition { x = 200, y = 500, scalePercentage = 200 }

        initialPosition =
            { x = 100, y = 100, scalePercentage = 100 }
    in
    ( { user = User.init
      , tile = initialTile initialPosition
      }
    , Cmd.none
    )


{-| -}
deltaDecoder : Json.Decode.Decoder Delta
deltaDecoder =
    Json.Decode.succeed Delta
        |> Json.Decode.Pipeline.required "x" Json.Decode.int
        |> Json.Decode.Pipeline.required "y" Json.Decode.int
        |> Json.Decode.Pipeline.required "scalePercentage" Json.Decode.int



{-
   messageEncoder : Model -> Json.Encode.Value
   messageEncoder model =
       Json.Encode.object
           [ ( "content", Json.Encode.string model.inputContent )
           , ( "uid"
             , case model.userData of
                   Authenticated {user} ->
                       Json.Encode.string user.uid

                   _ ->
                       Json.Encode.null
             )
           ]
-}
---- UPDATE ----


{-| -}
type Msg
    = UserMessage User.Msg
    | TileMessage Tile.Msg
    | DeltaReceived (Result Json.Decode.Error Delta)


{-| -}
update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UserMessage message ->
            ( { model | user = User.update message model.user }, Cmd.none )

        TileMessage message ->
            ( { model | tile = Tile.update message model.tile }, Cmd.none )

        DeltaReceived result ->
            case result of
                Ok delta ->
                    ( { model | tile = Tile.reposition delta model.tile }, Cmd.none )

                Err decodeError ->
                    ( model, Cmd.none )



---- View ----


{-| -}
view : Model -> Html Msg
view model =
    let
        userGui =
            User.view model.user |> Gui.map UserMessage

        tileGui =
            Tile.view model.tile |> Gui.map TileMessage
    in
    userGui
        |> Gui.with tileGui
        |> Gui.view



---- PROGRAM ----


{-| [ signInSuccess (Json.Decode.decodeValue userDataDecoder >> User.LoggedInData >> UserMessage)
, signInError (Json.Decode.decodeValue logInErrorDecoder >> User.LoggedInError >> UserMessage)
, receiveMessages (Json.Decode.decodeValue notesDecoder >> User.NotesReceived >> UserMessage)
, receiveMessagesError (Json.Decode.decodeValue notesErrorDecoder >> User.NotesErrorReceived >> UserMessage)
, receiveNull (Json.Decode.decodeValue (Json.Decode.succeed {}) >> always NullReceived)
, receiveDelta (Json.Decode.decodeValue deltaDecoder >> DeltaReceived)
]
-}
subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        []


{-| -}
main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = subscriptions
        }
