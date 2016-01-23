module Tetriminos (random) where
import Grid exposing (Grid)
import Array exposing (Array)
import Random
import Color exposing (Color)

random : Random.Seed -> (Grid Color, Random.Seed)
random seed =
  let
    (i, seed') = Random.generate (Random.int 0 (List.length tetriminos - 1)) seed
    tetrimino = Maybe.withDefault Grid.empty (Array.get i (Array.fromList tetriminos))
  in
    (tetrimino, seed')


tetriminos : List (Grid Color)
tetriminos =
  List.map
    (uncurry Grid.fromList)
    [ ((Color.rgb 60 199 214), [(0, 0), (1, 0), (2, 0), (3, 0)])
    , ((Color.rgb 251 180 20), [(0, 0), (1, 0), (0, 1), (1, 1)])
    , ((Color.rgb 176 68 151), [(1, 0), (0, 1), (1, 1), (2, 1)])
    , ((Color.rgb 57 147 208), [(0, 0), (0, 1), (1, 1), (2, 1)])
    , ((Color.rgb 237 101 47), [(2, 0), (0, 1), (1, 1), (2, 1)])
    , ((Color.rgb 149 196 61), [(1, 0), (2, 0), (0, 1), (1, 1)])
    , ((Color.rgb 232 65 56), [(0, 0), (1, 0), (1, 1), (2, 1)])
    ]
