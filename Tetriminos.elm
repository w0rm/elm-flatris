module Tetriminos (random) where
import Grid exposing (Grid)
import Array exposing (Array)
import Random


random : Random.Seed -> (Grid String, Random.Seed)
random seed =
  let
    (i, seed') = Random.generate (Random.int 0 (List.length tetriminos - 1)) seed
    tetrimino = Maybe.withDefault (Grid.empty 0 0) (Array.get i (Array.fromList tetriminos))
  in
    (tetrimino, seed')


tetriminos : List (Grid String)
tetriminos =
  List.map
    Grid.fromList
    [ [ [Just "#3cc7d6", Just "#3cc7d6", Just "#3cc7d6", Just "#3cc7d6"] ]
    , [ [Just "#fbb414", Just "#fbb414"]
      , [Just "#fbb414", Just "#fbb414"]
      ]
    , [ [Nothing, Just "#b04497", Nothing]
      , [Just "#b04497", Just "#b04497", Just "#b04497"]
      ]
    , [ [Just "#3993d0", Nothing, Nothing]
      , [Just "#3993d0", Just "#3993d0", Just "#3993d0"]
      ]
    , [ [Nothing, Nothing, Just "#ed652f"]
      , [Just "#ed652f", Just "#ed652f", Just "#ed652f"]
      ]
    , [ [Nothing, Just "#95c43d", Just "#95c43d"]
      , [Just "#95c43d", Just "#95c43d", Nothing]
      ]
    , [ [Just "#e84138", Just "#e84138", Nothing]
      , [Nothing, Just "#e84138", Just "#e84138"]
      ]
    ]
