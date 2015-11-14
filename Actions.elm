module Actions (Action(..)) where
import Time exposing (Time)

type Action
  = Start
  | Pause
  | Resume
  | Tick Time
  | Move Int
  | Rotate
  | Accelerate Bool
