module Model exposing
    ( Model
    , State(..)
    , decode
    , encode
    , initial
    , spawnTetrimino
    )

import Color exposing (Color)
import Grid exposing (Grid)
import Json.Decode as Decode
import Json.Encode as Encode
import Random
import Tetriminos


type State
    = Paused
    | Playing
    | Stopped


decodeState : String -> State
decodeState string =
    case string of
        "paused" ->
            Paused

        "playing" ->
            Playing

        _ ->
            Stopped


encodeState : State -> String
encodeState state =
    case state of
        Paused ->
            "paused"

        Playing ->
            "playing"

        Stopped ->
            "stopped"


type alias AnimationState =
    Maybe { active : Bool, elapsed : Float }


type alias Model =
    { size : ( Float, Float )
    , active : Grid Color
    , position : ( Int, Float )
    , grid : Grid Color
    , lines : Int
    , next : Grid Color
    , score : Int
    , seed : Random.Seed
    , state : State
    , acceleration : Bool
    , moveLeft : Bool
    , moveRight : Bool
    , direction : AnimationState
    , rotation : AnimationState
    , width : Int
    , height : Int
    }


initial : Model
initial =
    let
        ( next, seed ) =
            Tetriminos.random (Random.initialSeed 0)
    in
    spawnTetrimino
        { size = ( 0, 0 )
        , active = Grid.empty
        , position = ( 0, 0 )
        , grid = Grid.empty
        , lines = 0
        , next = next
        , score = 0
        , seed = Random.initialSeed 0
        , state = Stopped
        , acceleration = False
        , moveLeft = False
        , moveRight = False
        , rotation = Nothing
        , direction = Nothing
        , width = 10
        , height = 20
        }


spawnTetrimino : Model -> Model
spawnTetrimino model =
    let
        ( next, seed ) =
            Tetriminos.random model.seed

        ( x, y ) =
            Grid.initPosition model.width model.next
    in
    { model
        | next = next
        , seed = seed
        , active = model.next
        , position = ( x, toFloat y )
    }


decode : Decode.Decoder Model
decode =
    Decode.map8
        (\active positionX positionY grid lines next score state ->
            { initial
                | active = active
                , position = ( positionX, positionY )
                , grid = grid
                , lines = lines
                , next = next
                , score = score
                , state = state
            }
        )
        (Decode.field "active" (Grid.decode Color.decode))
        (Decode.field "positionX" Decode.int)
        (Decode.field "positionY" Decode.float)
        (Decode.field "grid" (Grid.decode Color.decode))
        (Decode.field "lines" Decode.int)
        (Decode.field "next" (Grid.decode Color.decode))
        (Decode.field "score" Decode.int)
        (Decode.field "state" (Decode.map decodeState Decode.string))


encode : Int -> Model -> String
encode indent model =
    Encode.encode
        indent
        (Encode.object
            [ ( "active", Grid.encode Color.encode model.active )
            , ( "positionX", Encode.int (Tuple.first model.position) )
            , ( "positionY", Encode.float (Tuple.second model.position) )
            , ( "grid", Grid.encode Color.encode model.grid )
            , ( "lines", Encode.int model.lines )
            , ( "next", Grid.encode Color.encode model.next )
            , ( "score", Encode.int model.score )
            , ( "state", Encode.string (encodeState model.state) )
            ]
        )
