module Tetriminos (fromChar) where
import Array
import Grid exposing (Grid)


fromChar : Char -> Grid String
fromChar name =
  case name of
    'I' ->
      Array.fromList
      [ Array.fromList [Nothing, Nothing, Nothing, Nothing]
      , Array.fromList [Just "#3cc7d6", Just "#3cc7d6", Just "#3cc7d6", Just "#3cc7d6"]
      , Array.fromList [Nothing, Nothing, Nothing, Nothing]
      , Array.fromList [Nothing, Nothing, Nothing, Nothing]
      ]

    'O' ->
      Array.fromList
      [ Array.fromList [Just "#fbb414", Just "#fbb414"]
      , Array.fromList [Just "#fbb414", Just "#fbb414"]
      ]

    'T' ->
      Array.fromList
      [ Array.fromList [Nothing, Just "#b04497", Nothing]
      , Array.fromList [Just "#b04497", Just "#b04497", Just "#b04497"]
      , Array.fromList [Nothing, Nothing, Nothing]
      ]

    'J' ->
      Array.fromList
      [ Array.fromList [Just "#3993d0", Nothing, Nothing]
      , Array.fromList [Just "#3993d0", Just "#3993d0", Just "#3993d0"]
      , Array.fromList [Nothing, Nothing, Nothing]
      ]

    'L' ->
      Array.fromList
      [ Array.fromList [Nothing, Nothing, Just "#ed652f"]
      , Array.fromList [Just "#ed652f", Just "#ed652f", Just "#ed652f"]
      , Array.fromList [Nothing, Nothing, Nothing]
      ]

    'S' ->
      Array.fromList
      [ Array.fromList [Nothing, Just "#95c43d", Just "#95c43d"]
      , Array.fromList [Just "#95c43d", Just "#95c43d", Nothing]
      , Array.fromList [Nothing, Nothing, Nothing]
      ]

    'Z' ->
      Array.fromList
      [ Array.fromList [Just "#e84138", Just "#e84138", Nothing]
      , Array.fromList [Nothing, Just "#e84138", Just "#e84138"]
      , Array.fromList [Nothing, Nothing, Nothing]
      ]

    _ ->
      Array.fromList []
