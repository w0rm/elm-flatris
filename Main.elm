import Effects exposing (Never)
import Html exposing (Html)
import Model exposing (Model)
import StartApp
import Task exposing (Task)
import Update
import View
import Actions
import Keyboard


app : { html : Signal Html
      , model : Signal Model
      , tasks : Signal (Task Never ())
      }
app =
  StartApp.start
    { init = (Model.initial, Effects.tick Actions.Init)
    , update = Update.update
    , view = View.view
    , inputs =
      [ Signal.map Actions.Rotate (Keyboard.isDown 38)
      , Signal.map Actions.Accelerate (Keyboard.isDown 40)
      , Signal.map .x Keyboard.arrows |> Signal.map Actions.Move
      ]
    }


main : Signal Html
main =
  app.html


port tasks : Signal (Task Never ())
port tasks =
  app.tasks
