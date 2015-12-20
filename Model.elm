module Model (Model, State(..)) where

import Grid exposing (Grid)
import Random
import Time exposing (Time)

type State = Paused | Playing | Stopped

type alias Animation =
  Maybe { prevClockTime : Time, elapsed : Time }

type alias Rotation =
  Maybe { active : Bool, elapsed : Time }

type alias Direction =
  Maybe { active : Bool, direction : Int, elapsed : Time }

type alias Model =
  { active : Grid String
  , activePosition : (Int, Float)
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
  }
