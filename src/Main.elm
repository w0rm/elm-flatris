module Flatris exposing (main)

import Model exposing (Model)
import Update
import View
import Keyboard exposing (KeyCode)
import Window exposing (Size)
import Html
import Messages exposing (Msg(..))
import AnimationFrame
import Json.Encode exposing (Value)
import Task


main : Program Value Model Msg
main =
    Html.programWithFlags
        { init = \value -> ( Model.decode value, Task.perform Resize Window.size )
        , update = Update.update
        , view = View.view
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ if model.state == Model.Playing then
            AnimationFrame.diffs Tick
          else
            Sub.none
        , Keyboard.ups (key False model)
        , Keyboard.downs (key True model)
        , Window.resizes Resize
        ]


key : Bool -> Model -> KeyCode -> Msg
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
