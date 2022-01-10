module User exposing (User, Error, view)

{-| @docs User, Action, Error
-}
import RemoteData exposing (RemoteData(..))
import Html exposing (Html, span, button, label, fieldset, legend, input, div, h1, h2, h3, h5, img, p, text, form, small, summary, details)
import Html.Attributes exposing (placeholder, src, class, value, id, disabled, type_, checked, for)
import Html.Events exposing (onClick, onInput, onSubmit)
import Json.Decode
import Json.Decode.Pipeline 
import Json.Encode
import Gui exposing (Gui)

---- CREATE ----

{-| may sync with a remote database -}
type User 
   = User LocalUserData (RemoteData Error RemoteUserData)

type Error
    = DecodingError String
    | DatabaseError DatabaseErrorData

type alias RemoteUserData = { token : String, email : String, uid : String }
type alias LocalUserData = { notes : Maybe (List String), input : String }
type alias DatabaseErrorData = { code : Maybe String, message : Maybe String, credential : Maybe String }

type Command
    = LogIn
    | LogOut
    | AddNote
    
---- UPDATE ----

type Msg
    = Send Command
    | LoggedInData (Result Json.Decode.Error UserData)
    | LoggedInError (Result Json.Decode.Error DatabaseErrorData)
    | NotesReceived (Result Json.Decode.Error (List String))
    | NotesErrorReceived (Result Json.Decode.Error String)
    | InputChanged String

{-|-}
update : Msg -> User -> User
update msg user =
    case ( msg, user ) of
        ( Send LogIn, User local _ ) ->
            User local Loading

        ( Send LogOut, User local _ ) ->
            User local NotAsked

        ( Send AddNote, User local remote ) ->
            User 
                { local 
                    | notes = 
                        local.notes 
                            |> Maybe.map ((::) local.input) 
                            |> Maybe.withDefault (Just [local.input])
                    , input = ""
                } 
                remote
            
        ( LoggedInData decodingResult, User local _ ) ->
            case decodingResult of
                Ok remote -> 
                    User local remote
                Err decodingError -> 
                    ( DecodingError >> RemoteData.Failure >> User local ) ( Json.Decode.errorToString decodingError )
        
        ( NotesReceived decodingResult, User local remote ) ->
            case decodingResult of
                Ok notes -> 
                    User { local | notes = Just notes } remote
                Err decodingError -> 
                    ( DecodingError >> RemoteData.Failure >> User local ) (Json.Decode.errorToString decodingError)

        ( LoggedInError decodingResult, User local _ ) ->
            case decodingResult of
                Ok error -> 
                    ( DatabaseError >> RemoteData.Failure >> User local ) error
                Err decodingError -> 
                    ( DecodingError >> RemoteData.Failure >> User local ) (Json.Decode.errorToString decodingError)
        
        ( NotesErrorReceived decodingResult, User local _ ) ->
            case decodingResult of
                Ok error -> 
                    ( DatabaseError >> RemoteData.Failure >> User local ) error
                Err decodingError -> 
                    ( DecodingError >> RemoteData.Failure >> User local ) (Json.Decode.errorToString decodingError)

        ( InputChanged input, User local remote ) -> 
            User { local | input = input } remote

        _ -> user




---- VIEW ----

        

{-|-}
view : User -> Gui Msg
view user =
    let 
        viewNotes localUserData =
            ( div >> Gui.createControl )
                []
                [ form [onSubmit howToSaveNote]
                    [ fieldset [class "chrome"]
                        [ legend [] [text "Notes"]
                        , input 
                            [ placeholder "Write a note to yourself"
                            , class "chrome", value localUserData.input
                            , onInput InputChanged
                            , id "send-message" ] []
                        , button [ type_ "submit", class "chrome" ] [ text "Persist on the Server" ]
                        ]
                        , fieldset [class "chrome"]
                            [ div [] <| case localUserData.notes of
                                Nothing -> 
                                    [span [class "load-placeholder"] [text "Downloading notes..."]]
                                Just [] ->
                                    [ p [] [text "¶"]]
                                Just nn ->
                                    List.map (\n -> p [] [ text n ]) nn
                            ]
                    ]
                ]

        viewLoginHandle =
            ( button >> Gui.createStatus ) 
                [ onClick howToLogIn ] 
                [ text "Log In..." ]
    in 
    case user of
        Local localUserData ->
            viewNotes localUserData
                |> Gui.withStatus viewLoginHandle

        Remote localUserData remoteUser ->
            case remoteUser of
                NotAsked -> 
                    (viewNotes >> Gui.withStatus viewLoginHandle) localUserData
                Loading -> 
                    Html.element "remote-user" []
                    |> withStatus 
                        ( ( span [] >> Gui.createStatus )
                          [ button [ disabled True ] [ text "Contacting the Server..." ]
                          , button [] [text "Cancel"]
                          ] 
                        )
                    

                Failure databaseError -> 
                    let errorText =
                            Maybe.withDefault "(no error code)" databaseError.code ++ " " 
                                ++ Maybe.withDefault "(no credentials)" databaseError.credential ++ " " 
                                ++ Maybe.withDefault "(no message)" databaseError.message
                    in
                    [ button [ onClick howToLogIn ] [ text "Log In" ]
                    , small [] [ text errorText ]
                    ]
                    |> Gui.disclose 
                        [ text errorText ]

                Success remoteUserData ->
                    let 
                        viewHandle =
                            [ fieldset [class "chrome"] [ legend [] [text "Uid"], small [] [ text remoteUserData.uid ]]
                            , fieldset [class "chrome"] [ legend [] [text "Token"], small [] [ text remoteUserData.token ]]
                            ]
                            |> Gui.disclose 
                                [ span [class "chrome"] [text remoteUserData.email]
                                , button [ onClick howToLogOut ] [ text "Log Out" ] 
                                ]
                    in
                    ( viewNotes >> Gui.withStatus viewHandle ) localUserData



--- DECODE ----

{-|
-}
userDataDecoder : Json.Decode.Decoder User
userDataDecoder =
    Json.Decode.succeed UserData
        |> Json.Decode.Pipeline.required "token" Json.Decode.string
        |> Json.Decode.Pipeline.required "email" Json.Decode.string
        |> Json.Decode.Pipeline.required "uid" Json.Decode.string
        |> Json.Decode.Pipeline.hardcoded Nothing
        |> Json.Decode.Pipeline.hardcoded ""
        |> Json.Decode.map RemoteData.Success

{-|
-}
logInErrorDecoder : Json.Decode.Decoder Error
logInErrorDecoder =
    Json.Decode.succeed DatabaseError
        |> Json.Decode.Pipeline.required "code" (Json.Decode.nullable Json.Decode.string)
        |> Json.Decode.Pipeline.required "message" (Json.Decode.nullable Json.Decode.string)
        |> Json.Decode.Pipeline.required "credential" (Json.Decode.nullable Json.Decode.string)

{-|
-}
notesListDecoder : Json.Decode.Decoder (List String)
notesListDecoder =
    Json.Decode.succeed identity
        |> Json.Decode.Pipeline.required "notes" (Json.Decode.list Json.Decode.string)

