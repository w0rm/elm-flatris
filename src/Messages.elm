module Messages exposing (Msg(..))

import Time exposing (Time)
import Window exposing (Size)


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
    | Resize Size
    | Noop
