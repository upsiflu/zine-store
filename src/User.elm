module User exposing (User, Action, Error, singleton)

type alias User =
    { token : String, email : String, uid : String }


type alias Error =
    { code : Maybe String, message : Maybe String, credential : Maybe String }


type Action
    = Chat String
    | 


emptyError : Error
emptyError =
    { code = Nothing, credential = Nothing, message = Nothing }