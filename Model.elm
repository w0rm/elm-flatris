module Model (Model, State(Paused, Playing, Stopped), AnimationState) where
import Grid exposing (Grid)
import Random
import Time exposing (Time)

type State = Paused | Playing | Stopped

type alias AnimationState =
    Maybe { prevClockTime : Time, elapsedFrames : Int }

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
  }
