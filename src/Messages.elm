module Messages exposing (Msg(..))

import Time exposing (Time)


type Msg
    = Start
    | Pause
    | Resume
    | Tick Time
    | UnlockButtons
    | MoveLeft Bool
    | MoveRight Bool
    | Rotate Bool
    | Accelerate Bool
    | Noop
