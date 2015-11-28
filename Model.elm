module Model (Model, State(Paused, Playing, Stopped)) where
import Grid exposing (Grid)
import Random
import Time exposing (Time)

type State = Paused | Playing | Stopped

type alias AnimationState =
  Maybe { prevClockTime : Time, elapsedFrames : Float }

type alias RotationState =
  Maybe { active : Bool, elapsedFrames : Float }

type alias DirectionState =
  Maybe { active : Bool, direction : Int, elapsedFrames : Float }

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
  , animationState : AnimationState
  , direction : DirectionState
  , rotation : RotationState
  }
