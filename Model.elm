module Model (Model, State(..), initial) where

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

initial : Model
initial =
  { active = Grid.empty 0 0
  , activePosition = (0, 0)
  , grid = Grid.empty 10 20
  , lines = 0
  , next = Grid.empty 0 0
  , score = 0
  , seed = Random.initialSeed 0
  , state = Stopped
  , acceleration = False
  , animation = Nothing
  , rotation = Nothing
  , direction = Nothing
  }
