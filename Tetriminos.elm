module Tetriminos (random) where
import Grid exposing (Grid)
import Array exposing (Array)
import Random


random : Random.Seed -> (Grid String, Random.Seed)
random seed =
  let
    (i, seed') = Random.generate (Random.int 0 (List.length tetriminos - 1)) seed
    tetrimino = Maybe.withDefault Grid.empty (Array.get i (Array.fromList tetriminos))
  in
    (tetrimino, seed')


tetriminos : List (Grid String)
tetriminos =
  List.map
    (uncurry Grid.fromList)
    [ ("#3cc7d6", [(0, 0), (1, 0), (2, 0), (3, 0)])
    , ("#fbb414", [(0, 0), (1, 0), (0, 1), (1, 1)])
    , ("#b04497", [(1, 0), (0, 1), (1, 1), (2, 1)])
    , ("#3993d0", [(0, 0), (0, 1), (1, 1), (2, 1)])
    , ("#ed652f", [(2, 0), (0, 1), (1, 1), (2, 1)])
    , ("#95c43d", [(1, 0), (2, 0), (0, 1), (1, 1)])
    , ("#e84138", [(0, 0), (1, 0), (1, 1), (2, 1)])
    ]
