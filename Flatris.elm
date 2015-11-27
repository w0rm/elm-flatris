import Effects exposing (Never)
import Grid
import Html exposing (Html)
import Model exposing (Model)
import Random
import StartApp
import Task
import Tetriminos
import Update
import View
import Actions
import Keyboard


initialModel : Model
initialModel =
  { active = Tetriminos.fromChar 'I'
  , activePosition = (0, 0)
  , grid = Grid.make 10 20 (\_ _ -> Nothing)
  , lines = 0
  , next = Tetriminos.fromChar 'O'
  , score = 0
  , seed = Random.initialSeed 31415
  , state = Model.Stopped
  , acceleration = False
  , animationState = Nothing
  }


app : { html : Signal Html
      , model : Signal Model
      , tasks : Signal (Task.Task Never ())
      }
app =
  StartApp.start
    { init = (initialModel, Effects.none)
    , update = Update.update
    , view = View.view
    , inputs = [
        Signal.map .x Keyboard.arrows
        |> Signal.filter (\x -> x /= 0) 0
        |> Signal.map Actions.Move
      , Signal.map (always Actions.Rotate) (Keyboard.isDown 38 |> Signal.filter identity False)
      , Signal.map Actions.Accelerate (Keyboard.isDown 40)
      ]
    }


main : Signal Html
main =
  app.html


port tasks : Signal (Task.Task Never ())
port tasks =
  app.tasks
