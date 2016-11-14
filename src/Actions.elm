module Actions exposing (Action(..))

import Time exposing (Time)


type Action
    = Init
    | Load String
    | Start
    | Pause
    | Resume
    | Tick Time
    | UnlockButtons
    | MoveLeft Bool
    | MoveRight Bool
    | Rotate Bool
    | Accelerate Bool
    | Noop
