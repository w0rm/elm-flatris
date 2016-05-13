import Model exposing (Model)
import Update
import View
import Keyboard exposing (KeyCode)
import Html.App as Html
import Actions exposing (Action(..))
import AnimationFrame
import Task exposing (Task)


subscriptions : Model -> Sub Action
subscriptions model =
  Sub.batch
    [ if model.state == Model.Playing then
        AnimationFrame.diffs Actions.Tick
      else
        Sub.none
    , Keyboard.ups (keyup model)
    , Keyboard.downs (keydown model)
    ]


keyup : Model -> KeyCode -> Action
keyup {rotation, direction, acceleration} keycode =
  case keycode of
    37 -> Move 0
    39 -> Move 0
    40 -> Accelerate False
    38 -> Rotate False
    _ -> Noop


keydown : Model -> KeyCode -> Action
keydown {rotation, direction, acceleration} keycode =
  case keycode of
    37 -> Move -1
    39 -> Move 1
    40 -> Accelerate True
    38 -> Rotate True
    _ -> Noop


main : Program Never
main =
  Html.program
    { init = (Model.initial, Task.perform (always Init) (always Init) (Task.succeed 0))
    , update = Update.update
    , view = View.view
    , subscriptions = subscriptions
    }
