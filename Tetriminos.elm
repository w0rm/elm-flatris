module Tetriminos (fromChar, random) where
import Grid exposing (Grid)
import Array exposing (Array)
import Random


letters : Array Char
letters = Array.fromList ['I', 'O', 'T', 'J', 'L', 'S', 'Z']


random : Random.Seed -> (Grid String, Random.Seed)
random seed =
  let
    (i, seed') = Random.generate (Random.float 0 6) seed
    char = Maybe.withDefault 'I' (Array.get (floor i) letters)
  in
    (fromChar char, seed')


fromChar : Char -> Grid String
fromChar name =
  case name of
    'I' ->
      Grid.fromList
      [ [Nothing, Nothing, Nothing, Nothing]
      , [Just "#3cc7d6", Just "#3cc7d6", Just "#3cc7d6", Just "#3cc7d6"]
      , [Nothing, Nothing, Nothing, Nothing]
      , [Nothing, Nothing, Nothing, Nothing]
      ]

    'O' ->
      Grid.fromList
      [ [Just "#fbb414", Just "#fbb414"]
      , [Just "#fbb414", Just "#fbb414"]
      ]

    'T' ->
      Grid.fromList
      [ [Nothing, Just "#b04497", Nothing]
      , [Just "#b04497", Just "#b04497", Just "#b04497"]
      , [Nothing, Nothing, Nothing]
      ]

    'J' ->
      Grid.fromList
      [ [Just "#3993d0", Nothing, Nothing]
      , [Just "#3993d0", Just "#3993d0", Just "#3993d0"]
      , [Nothing, Nothing, Nothing]
      ]

    'L' ->
      Grid.fromList
      [ [Nothing, Nothing, Just "#ed652f"]
      , [Just "#ed652f", Just "#ed652f", Just "#ed652f"]
      , [Nothing, Nothing, Nothing]
      ]

    'S' ->
      Grid.fromList
      [ [Nothing, Just "#95c43d", Just "#95c43d"]
      , [Just "#95c43d", Just "#95c43d", Nothing]
      , [Nothing, Nothing, Nothing]
      ]

    'Z' ->
      Grid.fromList
      [ [Just "#e84138", Just "#e84138", Nothing]
      , [Nothing, Just "#e84138", Just "#e84138"]
      , [Nothing, Nothing, Nothing]
      ]

    _ ->
      Grid.fromList []
