port module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import RemoteData exposing (RemoteData(..))
import Html exposing (Html, span, button, label, fieldset, legend, input, div, h1, h2, h3, h5, img, p, text, form, small, summary, details)
import Html.Attributes exposing (placeholder, src, class, value, id, disabled, type_, checked, for)
import Html.Events exposing (onClick, onInput, onSubmit)
import Json.Decode
import Json.Decode.Pipeline
import Json.Encode

import User exposing (User)
import Tile exposing (Tile(..))


port signIn : () -> Cmd msg
port signOut : () -> Cmd msg
port saveMessage : Json.Encode.Value -> Cmd msg

port receiveMessages : (Json.Encode.Value -> msg) -> Sub msg
port signInInfo : (Json.Encode.Value -> msg) -> Sub msg
port signInError : (Json.Encode.Value -> msg) -> Sub msg
port receiveNull : (Json.Encode.Value -> msg) -> Sub msg
port receiveDelta : (Json.Encode.Value -> msg) -> Sub msg



---- MODEL ----


type alias MessageContent =
    { uid : String, content : String }


type alias Delta =
    {x : Int, y:Int, scalePercentage:Int}


type alias Model =
    { user : RemoteData User User.Error
    , inputContent : String
    , mosaic : List Tile
    }


init : ( Model, Cmd Msg )
init =
    let
        initialTile = Tile Tile.Square >> Tile.reposition {x = 200, y=500, scalePercentage=200}
        initialPosition = {x = 100, y = 100, scalePercentage =100}
    in 
    ( { userData = Loading
      , inputContent = ""
      , mosaic = [initialTile initialPosition]
      }
      , Cmd.none 
    )



---- UPDATE ----


type Msg
    = LogIn
    | LogOut
    | LoggedInData (Result Json.Decode.Error User)
    | LoggedInError (Result Json.Decode.Error User.Error)
    | SaveMessage
    | InputChanged String
    | ActionsReceived (Result Json.Decode.Error (List String))
    | NullReceived
    | DeltaReceived (Result Json.Decode.Error Delta)



syncAction : Action -> Model -> Model
syncAction action model =
    case model.userData of
        Authenticated data ->
            case action of
                ChatMessage message ->
                    if (data.messages == Nothing) data.messages = [message]
                    else 

            model { userData = Authenticated {data | messages }}


type Action
    = Action ActionId User.Action



update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LogIn ->
            ( model, signIn () )

        LogOut ->
            ( { model | user = NotAsked }, signOut () )

        LoggedInData result ->
            case result of
                Ok user ->
                    ( { model | user = Success user }, Cmd.none )

                Err error ->
                    ( { model | user = Failure <| messageToError <| Json.Decode.errorToString error }, Cmd.none )

        LoggedInError result ->
            case result of
                Ok usererror ->
                    ( { model | user = Failure <| value }, Cmd.none )

                Err error ->
                    ( { model | user = Failure <| messageToError <| Json.Decode.errorToString error }, Cmd.none )

        SaveMessage ->
            ( model, messageEncoder model |> saveMessage )

        InputChanged value ->
            ( { model | inputContent = value }, Cmd.none )

        MessagesReceived result ->
            case result of
                Ok value ->
                    { model | messages =  }, Cmd.none )

                (_, Err error) ->
                    ( { model | userData = Failed <| messageToError <| Json.Decode.errorToString error }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        NullReceived ->
            ( { model | userData = Null }, Cmd.none )

        DeltaReceived result ->
            case (result, model.mosaic) of
                (Ok delta, [tile]) -> 
                    ( { model | mosaic = [Tile.reposition delta tile] }, Cmd.none )
                (Err error, _) ->
                    ( { model | userData = Failed <| messageToError <| Json.Decode.errorToString error }, Cmd.none )
                _ -> 
                    (model, Cmd.none )


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


messageToError : String -> ErrorData
messageToError message =
    { code = Maybe.Nothing, credential = Maybe.Nothing, message = Just message }


errorPrinter : ErrorData -> String
errorPrinter errorData =
    Maybe.withDefault "(no error code)" errorData.code ++ " " ++ Maybe.withDefault "(no credentials)" errorData.credential ++ " " ++ Maybe.withDefault "(no message)" errorData.message


userDataDecoder : Json.Decode.Decoder UserData
userDataDecoder =
    Json.Decode.succeed UserData
        |> Json.Decode.Pipeline.required "token" Json.Decode.string
        |> Json.Decode.Pipeline.required "email" Json.Decode.string
        |> Json.Decode.Pipeline.required "uid" Json.Decode.string


logInErrorDecoder : Json.Decode.Decoder ErrorData
logInErrorDecoder =
    Json.Decode.succeed ErrorData
        |> Json.Decode.Pipeline.required "code" (Json.Decode.nullable Json.Decode.string)
        |> Json.Decode.Pipeline.required "message" (Json.Decode.nullable Json.Decode.string)
        |> Json.Decode.Pipeline.required "credential" (Json.Decode.nullable Json.Decode.string)

deltaDecoder : Json.Decode.Decoder Delta
deltaDecoder =
    Json.Decode.succeed Delta
        |> Json.Decode.Pipeline.required "x" Json.Decode.int
        |> Json.Decode.Pipeline.required "y" Json.Decode.int
        |> Json.Decode.Pipeline.required "scalePercentage" Json.Decode.int

messagesDecoder =
    Json.Decode.decodeString (Json.Decode.list Json.Decode.string)


messageListDecoder : Json.Decode.Decoder (List String)
messageListDecoder =
    Json.Decode.succeed identity
        |> Json.Decode.Pipeline.required "messages" (Json.Decode.list Json.Decode.string)



---- VIEW ----

disclose : List (Html Msg) -> List (Html Msg) -> Html Msg
disclose a b =
    details [] [ summary [] a, div [class "popup"] b ]
        


view : Model -> Html Msg
view model =
    let
        optionsDisclosure =
            disclose 
                [span [class "chrome"] [text "Input device"]]
                [fieldset [class "chrome"]
                    [ input [type_ "checkbox", id "natural", checked True] []
                    , label [class "chrome", for "natural"] [text "My trackpad is configured for natural scrolling"]
                    ]
                ]
        userDisclosure =
            case model.userData of
                Null ->
                    button [ onClick LogIn ] [ text "Log In..." ]

                Authenticated {user} ->
                    disclose
                        [ span [class "chrome"] [text user.email], button [ onClick LogOut ] [ text "Log Out" ] ]
                        [ fieldset [class "chrome"] [ legend [] [text "Uid"], small [] [ text user.uid ]]
                        , fieldset [class "chrome"] [ legend [] [text "Token"], small [] [ text user.token ]]
                        ]

                Failed error ->
                    disclose
                        [ text <| errorPrinter error ]
                        [ button [ onClick LogIn ] [ text "Log In" ]
                        , small [] [ text <| errorPrinter error ]
                        ]


                Pending ->
                    button [ disabled True ] [ text "Contacting the Server..." ]

        chrome =
            div [ class "chrome-bar" ]
                [ div [class "top chrome"]
                    [ h1 [] [ text "zine-store -- 2-fingure gestures. If you have a touchpad, try pinching and scrolling!" ] 
                    , optionsDisclosure
                    , userDisclosure
                    ]
                , div [class "bottom chrome"]
                    [ case model.userData of
                        Authenticated {messages} ->
                            div []
                                [ form [onSubmit SaveMessage]
                                    [ fieldset [class "chrome"]
                                        [ legend [] [text "Messages"]
                                        , input [ placeholder "Write a Message", class "chrome", value model.inputContent, onInput InputChanged, id "send-message" ] []
                                        , button [ type_ "submit", class "chrome" ] [ text "Persist on the Server" ]
                                    ]
                                    , fieldset [class "chrome"]
                                    [
                                        div []
                                            <| case messages of
                                                Nothing -> 
                                                    [span [class "load-placeholder"] [text "Loading Messages..."]]
                                                Just mm ->
                                                    List.map (\m -> p [] [ text m ]) mm
                                        ]
                                    ]
                                    
                                ]

                        _ ->
                            div [] []
                    ]
                ]
        mosaic =
            model.mosaic
            |> List.map Tile.view
            |> div [class "mosaic"]
    in div [] [mosaic, chrome]



---- PROGRAM ----


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ signInInfo (Json.Decode.decodeValue userDataDecoder >> LoggedInData)
        , signInError (Json.Decode.decodeValue logInErrorDecoder >> LoggedInError)
        , receiveMessages (Json.Decode.decodeValue messageListDecoder >> MessagesReceived)
        , receiveNull (Json.Decode.decodeValue (Json.Decode.succeed {}) >> always NullReceived)
        , receiveDelta (Json.Decode.decodeValue deltaDecoder >> DeltaReceived)
        ]


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = subscriptions
        }
