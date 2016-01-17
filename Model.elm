module Model (Model, State(..), initial, encode, decode) where

import Json.Decode as Decode exposing ((:=))
import Json.Encode as Encode
import Grid exposing (Grid)
import Random
import Time exposing (Time)

type State = Paused | Playing | Stopped


decodeState : String -> State
decodeState string =
  case string of
    "paused" -> Paused
    "playing" -> Playing
    _ -> Stopped


encodeState : State -> String
encodeState state =
  case state of
    Paused -> "paused"
    Playing -> "playing"
    Stopped -> "stopped"


type alias Animation =
  Maybe { prevClockTime : Time, elapsed : Time }


type alias Rotation =
  Maybe { active : Bool, elapsed : Time }


type alias Direction =
  Maybe { active : Bool, direction : Int, elapsed : Time }


type alias Model =
  { active : Grid String
  , position : (Int, Float)
  , grid : Grid String
  , lines : Int
  , next : Grid String
  , score : Int
  , seed : Random.Seed
  , state : State
  , acceleration : Bool
  , animation : Animation
  , direction : Direction
  , rotation : Rotation
  , width : Int
  , height : Int
  }


initial : Model
initial =
  { active = Grid.empty
  , position = (0, 0)
  , grid = Grid.empty
  , lines = 0
  , next = Grid.empty
  , score = 0
  , seed = Random.initialSeed 0
  , state = Stopped
  , acceleration = False
  , animation = Nothing
  , rotation = Nothing
  , direction = Nothing
  , width = 10
  , height = 20
  }


decode : String -> Model -> Model
decode string model =
  { model
  | active = Result.withDefault model.active (Decode.decodeString ("active" := (Grid.decode Decode.string)) string)
  , position =
    ( Result.withDefault (fst model.position) (Decode.decodeString ("positionX" := Decode.int) string)
    , Result.withDefault (snd model.position) (Decode.decodeString ("positionY" := Decode.float) string)
    )
  , grid = Result.withDefault model.grid (Decode.decodeString ("grid" := (Grid.decode Decode.string)) string)
  , lines = Result.withDefault model.lines (Decode.decodeString ("lines" := (Decode.int)) string)
  , next = Result.withDefault model.next (Decode.decodeString ("next" := (Grid.decode Decode.string)) string)
  , score = Result.withDefault model.score (Decode.decodeString ("score" := (Decode.int)) string)
  , state = Result.withDefault model.state (Decode.decodeString ("state" := Decode.map decodeState Decode.string) string)
  }


(=>) : a -> b -> (a, b)
(=>) = (,)


encode : Int -> Model -> String
encode indent model =
  Encode.encode
    indent
    ( Encode.object
      [ "active" => Grid.encode Encode.string model.active
      , "positionX" => Encode.int (fst model.position)
      , "positionY" => Encode.float (snd model.position)
      , "grid" => Grid.encode Encode.string model.grid
      , "lines" => Encode.int model.lines
      , "next" => Grid.encode Encode.string model.next
      , "score" => Encode.int model.score
      , "state" => Encode.string (encodeState model.state)
      ]
    )
