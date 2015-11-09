module Tetriminos (fromChar) where
import Array
import Grid exposing (Grid)


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
