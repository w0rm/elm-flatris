module Main exposing (..)

import Model exposing (Model)
import Update
import View
import Keyboard exposing (KeyCode)
import Html
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
        , Keyboard.ups (key False model)
        , Keyboard.downs (key True model)
        ]


key : Bool -> Model -> KeyCode -> Action
key on { rotation, direction, acceleration } keycode =
    case keycode of
        37 ->
            MoveLeft on

        39 ->
            MoveRight on

        40 ->
            Accelerate on

        38 ->
            Rotate on

        _ ->
            Noop


main : Program Never Model Action
main =
    Html.program
        { init = ( Model.initial, Task.perform (always Init) (Task.succeed 0) )
        , update = Update.update
        , view = View.view
        , subscriptions = subscriptions
        }
