module Actions (Action(..)) where
import Time exposing (Time)

type Action
  = Init Time
  | Start
  | Pause
  | Resume
  | Tick Time
  | Move Int
  | Rotate Bool
  | Accelerate Bool
