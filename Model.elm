module Model (Model, State(Paused, Playing, Stopped)) where
import Grid exposing (Grid)
import Random


type State = Paused | Playing | Stopped


type alias Model =
  { active : Grid String
  , activePosition : (Float, Float)
  , grid : Grid String
  , lines : Int
  , next : Grid String
  , score : Int
  , seed : Random.Seed
  , state : State
  }
