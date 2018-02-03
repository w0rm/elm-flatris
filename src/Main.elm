module Flatris exposing (main)

import Model exposing (Model)
import Update
import View
import Keyboard exposing (KeyCode)
import Html
import Messages exposing (Msg(..))
import AnimationFrame
import Json.Encode exposing (Value)


main : Program Value Model Msg
main =
    Html.programWithFlags
        { init = \value -> ( Model.decode value, Cmd.none )
        , update = Update.update
        , view = View.view
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ if model.state == Model.Playing then
            AnimationFrame.diffs Messages.Tick
          else
            Sub.none
        , Keyboard.ups (key False model)
        , Keyboard.downs (key True model)
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
