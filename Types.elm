module Types where
import Array exposing (Array)
import Random


type State
  = Paused
  | Playing
  | Stopped


type alias Grid = Array (Array (Maybe String))


type alias Model =
  { active : Grid
  , activePosition : (Float, Float)
  , grid : Grid
  , lines : Int
  , next : Grid
  , score : Int
  , seed : Random.Seed
  , state : State
  }
