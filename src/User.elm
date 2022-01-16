module User exposing
    ( User, init
    , Msg, update
    , view
    )

{-| `User` is local first, i.e. functional without remote connection. It needs the DOM to provide a custom-element:


## Custom Element `remote-user`


### Attributes

  - `command` = `LogIn` | `LogOut` | `DatabaseError` | `DecodingError` | `AddNote`
  - `recent-note` = (String)


### Events

  - (WIP)


### Considerations

  - can appear multiple times in an app, so
  - needs to sync with the database in some way
  - the scheduling of messages follows the traditional "nested Elm architecture".


# Model

@docs User, init


# Update

@docs Msg, update


# View

@docs view

-}

--import Json.Decode
--import Json.Decode.Pipeline

import Gui exposing (Gui)
import Html exposing (Html, button, details, div, fieldset, form, h1, h2, h3, h5, img, input, label, legend, p, small, span, summary, text)
import Html.Attributes as Attributes exposing (checked, class, disabled, for, id, placeholder, src, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Extra as Html exposing (nothing)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Field as Field
import Json.Encode as Encode
import RemoteData exposing (RemoteData(..))



---- CREATE ----


{-| local-first; may sync with a database which adds fields
-}
type User
    = User LocalUserData (RemoteData Error RemoteUserData)


{-| `User` with no notes and an empty string note input field
-}
init : User
init =
    User { notes = Nothing, input = "" } NotAsked


type Error
    = DecodingError String
    | DatabaseError DatabaseErrorData


type alias LocalUserData =
    { notes : Maybe (List String), input : String }


localUserDataDecoder =
    Field.attempt "notes" (Decode.list Decode.string) <|
        \notes ->
            Field.require "input" Decode.string <|
                \input ->
                    Decode.succeed { notes = notes, input = input }


type alias RemoteUserData =
    { token : String, email : String, uid : String }


remoteUserDataDecoder =
    Field.attempt "token" Decode.string <|
        \token ->
            Field.attempt "email" Decode.string <|
                \email ->
                    Field.attempt "uid" Decode.string <|
                        \uid ->
                            Decode.succeed { token = token, email = email, uid = uid }


type alias DatabaseErrorData =
    { code : Maybe String, credential : Maybe String, message : Maybe String }


databaseErrorDataDecoder =
    Field.attempt "code" Decode.string <|
        \code ->
            Field.attempt "message" Decode.string <|
                \message ->
                    Field.attempt "credential" Decode.string <|
                        \credential ->
                            Decode.succeed { code = code, message = message, credential = credential }



---- UPDATE ----
{- Pattern "Nested TEA":
   By making the message explicitely instead of just functions, we isolate this module's own state transitions.
-}


type Command
    = LogIn
    | LogOut
    | AddNote


{-| -}
type Msg
    = Send Command
    | LoggedInData (Result Decode.Error RemoteUserData)
    | LoggedInError (Result Decode.Error DatabaseErrorData)
    | NotesReceived (Result Decode.Error (List String))
    | NotesErrorReceived (Result Decode.Error String)
    | InputChanged String


{-| -}
update : Msg -> User -> User
update msg user =
    case ( msg, user ) of
        ( Send LogIn, User local _ ) ->
            User local Loading

        ( Send LogOut, User local _ ) ->
            User local NotAsked

        ( Send AddNote, User local remote ) ->
            let
                newNotes =
                    case ( local.input, local.notes ) of
                        ( "", notes ) ->
                            notes

                        ( input, Nothing ) ->
                            Just [ input ]

                        ( input, Just notes ) ->
                            Just (input :: notes)
            in
            User
                { local
                    | notes = newNotes
                    , input = ""
                }
                remote

        ( LoggedInData decodingResult, User local _ ) ->
            case decodingResult of
                Ok remote ->
                    User local (Success remote)

                Err decodingError ->
                    (DecodingError >> RemoteData.Failure >> User local) (Decode.errorToString decodingError)

        ( NotesReceived decodingResult, User local remote ) ->
            case decodingResult of
                Ok notes ->
                    User { local | notes = Just notes } remote

                Err decodingError ->
                    (DecodingError >> RemoteData.Failure >> User local) (Decode.errorToString decodingError)

        ( LoggedInError decodingResult, User local _ ) ->
            case decodingResult of
                Ok error ->
                    (DatabaseError >> RemoteData.Failure >> User local) error

                Err decodingError ->
                    (DecodingError >> RemoteData.Failure >> User local) (Decode.errorToString decodingError)

        ( NotesErrorReceived decodingResult, User local _ ) ->
            case decodingResult of
                Ok error ->
                    (Just >> DatabaseErrorData Nothing Nothing >> DatabaseError >> RemoteData.Failure >> User local) error

                Err decodingError ->
                    (DecodingError >> RemoteData.Failure >> User local) (Decode.errorToString decodingError)

        ( InputChanged input, User local remote ) ->
            User { local | input = input } remote



---- VIEW ----


{-| -}
view : User -> Gui Msg
view (User local remote) =
    let
        viewLogInHandle =
            [ button [ onClick (Send LogIn) ] [ text "Log In..." ] ]

        viewStatus : String -> List (Html msg) -> List (Html msg) -> Html msg
        viewStatus command controls more =
            let
                recentNote =
                    (case local.notes of
                        Just (n :: ns) ->
                            n

                        _ ->
                            ""
                    )
                        |> Encode.string
                        |> Attributes.property "recent-note"

                attributes =
                    command
                        |> Encode.string
                        |> Attributes.property "command"
                        |> List.singleton
                        |> (::) recentNote
            in
            Html.node "remote-user" attributes []
                :: controls
                |> Gui.disclose more
    in
    { handle =
        case remote of
            NotAsked ->
                viewStatus
                    "LogOut"
                    viewLogInHandle
                    []

            Loading ->
                viewStatus
                    "LogIn"
                    [ button [ disabled True, onClick (Send LogIn) ] [ text "Log In..." ]
                    , button [ disabled True ] [ text "Cancel" ]
                    ]
                    [ text "Contacting the Server..." ]

            Failure (DatabaseError databaseError) ->
                let
                    errorText =
                        Maybe.withDefault "(no error code)" databaseError.code
                            ++ " "
                            ++ Maybe.withDefault "(no credentials)" databaseError.credential
                            ++ " "
                            ++ Maybe.withDefault "(no message)" databaseError.message
                in
                viewStatus
                    "DatabaseError"
                    viewLogInHandle
                    [ text errorText ]

            Failure (DecodingError decodingError) ->
                viewStatus
                    "DecodingError"
                    viewLogInHandle
                    [ text decodingError ]

            Success remoteUserData ->
                viewStatus
                    "AddNote"
                    [ span [ class "chrome success" ] [ text remoteUserData.email ]
                    , button [ onClick (Send LogOut) ] [ text "Log Out" ]
                    ]
                    [ fieldset [ class "chrome" ] [ legend [] [ text "Uid" ], small [] [ text remoteUserData.uid ] ]
                    , fieldset [ class "chrome" ] [ legend [] [ text "Token" ], small [] [ text remoteUserData.token ] ]
                    ]
    , control =
        div []
            [ form [ onSubmit (Send AddNote) ]
                [ fieldset [ class "chrome" ]
                    [ legend []
                        [ text "Notes" ]
                    , input
                        [ placeholder "Write a note to yourself"
                        , class "chrome"
                        , value local.input
                        , onInput InputChanged
                        , id "send-message"
                        ]
                        []
                    , button [ type_ "submit", class "chrome" ]
                        [ text "Persist on the Server" ]
                    , fieldset [ class "chrome" ]
                        [ div [] <|
                            case local.notes of
                                Nothing ->
                                    [ span [ class "load-placeholder" ] [ text "Downloading notes..." ] ]

                                Just [] ->
                                    [ p [] [ text "¶" ] ]

                                Just nn ->
                                    List.map (\n -> p [] [ text n ]) nn
                        ]
                    ]
                ]
            ]
    , scene = nothing
    , info = nothing
    }
        |> Gui.singleton
