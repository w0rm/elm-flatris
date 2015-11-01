module Utils where
import Array
import Types exposing (Grid)


colorGrid : String -> Grid -> Grid
colorGrid col grid =
  let
    setColor cell =
      if cell == Nothing then Nothing else Just col
  in
    Array.map (\row -> Array.map setColor row) grid
