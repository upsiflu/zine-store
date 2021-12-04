port module Main exposing (Model, Msg(..), init, main, update, view)

import Browser
import Html exposing (Html, button, div, h1, h2, h3, h5, img, input, p, text, form, small)
import Html.Attributes exposing (placeholder, src, value, id, disabled, type_)
import Html.Events exposing (onClick, onInput, onSubmit)
import Json.Decode
import Json.Decode.Pipeline
import Json.Encode


port signIn : () -> Cmd msg


port receiveNull : (Json.Encode.Value -> msg) -> Sub msg


port signInInfo : (Json.Encode.Value -> msg) -> Sub msg


port signInError : (Json.Encode.Value -> msg) -> Sub msg


port signOut : () -> Cmd msg


port saveMessage : Json.Encode.Value -> Cmd msg


port receiveMessages : (Json.Encode.Value -> msg) -> Sub msg



---- MODEL ----


type alias MessageContent =
    { uid : String, content : String }


type alias ErrorData =
    { code : Maybe String, message : Maybe String, credential : Maybe String }


type alias UserData =
    { token : String, email : String, uid : String }

type MayFail a e
    = Pending
    | Null
    | Failed e
    | Authenticated a

type alias Model =
    { userData : MayFail {user : UserData, messages : List String } ErrorData, inputContent : String}


init : ( Model, Cmd Msg )
init =
    ( { userData = Pending, inputContent = ""}, Cmd.none )



---- UPDATE ----


type Msg
    = LogIn
    | LogOut
    | LoggedInData (Result Json.Decode.Error UserData)
    | LoggedInError (Result Json.Decode.Error ErrorData)
    | SaveMessage
    | InputChanged String
    | MessagesReceived (Result Json.Decode.Error (List String))
    | NullReceived


emptyError : ErrorData
emptyError =
    { code = Nothing, credential = Nothing, message = Nothing }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        LogIn ->
            ( model, signIn () )

        LogOut ->
            ( { model | userData = Pending}, signOut () )

        LoggedInData result ->
            case result of
                Ok value ->
                    ( { model | userData = Authenticated {user = value, messages = []} }, Cmd.none )

                Err error ->
                    ( { model | userData = Failed <| messageToError <| Json.Decode.errorToString error }, Cmd.none )

        LoggedInError result ->
            case result of
                Ok value ->
                    ( { model | userData = Failed <| value }, Cmd.none )

                Err error ->
                    ( { model | userData = Failed <| messageToError <| Json.Decode.errorToString error }, Cmd.none )

        SaveMessage ->
            ( model, saveMessage <| messageEncoder model )

        InputChanged value ->
            ( { model | inputContent = value }, Cmd.none )

        MessagesReceived result ->
            case (model.userData, result) of
                (Authenticated user, Ok value) ->
                    ( { model | userData = Authenticated {user | messages = value} }, Cmd.none )

                (_, Err error) ->
                    ( { model | userData = Failed <| messageToError <| Json.Decode.errorToString error }, Cmd.none )

                _ ->
                    ( model, Cmd.none )

        NullReceived ->
            ( { model | userData = Null }, Cmd.none )


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


messagesDecoder =
    Json.Decode.decodeString (Json.Decode.list Json.Decode.string)


messageListDecoder : Json.Decode.Decoder (List String)
messageListDecoder =
    Json.Decode.succeed identity
        |> Json.Decode.Pipeline.required "messages" (Json.Decode.list Json.Decode.string)



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ img [ src "/logo.svg" ] []
        , h1 [] [ text "zine-store" ]
        , div [ id "loader"] []
        
        -- User log in/out
        , div [id "user"]
            <| ( case model.userData of
                    Null ->
                        [ button [ onClick LogIn ] [ text "Log In" ] ]

                    Authenticated {user} ->
                        [ button [ onClick LogOut ] [ text "Log Out" ]
                        , h5 [] [ text user.email ]
                        , small [] [ text user.uid ]
                        , small [] [ text user.token ]
                        ]

                    Failed error ->
                        [ button [ onClick LogIn ] [ text "Log In" ]
                        , small [] [ text <| errorPrinter error ]]


                    Pending ->
                        [ button [ disabled True ] [ text "Checking..." ] ]
            )

        , case model.userData of
            Authenticated {messages} ->
                div []
                    [ form [onSubmit SaveMessage]
                        [ input [ placeholder "Message to save", value model.inputContent, onInput InputChanged, id "send-message" ] []
                        , button [ type_ "submit" ] [ text "Save new message" ]
                        ]
                    , div []
                        [ h3 [] [ text "Previous messages" ]
                        , div [] <|
                            List.map
                                (\m -> p [] [ text m ]) messages
                        ]
                    ]

            _ ->
                div [] []
        ]



---- PROGRAM ----


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ signInInfo (Json.Decode.decodeValue userDataDecoder >> LoggedInData)
        , signInError (Json.Decode.decodeValue logInErrorDecoder >> LoggedInError)
        , receiveMessages (Json.Decode.decodeValue messageListDecoder >> MessagesReceived)
        , receiveNull (Json.Decode.decodeValue (Json.Decode.succeed {}) >> always NullReceived)
        ]


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = subscriptions
        }
