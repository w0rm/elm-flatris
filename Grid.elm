module Grid (Grid, decode, encode, fromList, map, empty, rotate, stamp, collide, mapToList, clearLines, centerOfMass) where
import Json.Decode as Decode exposing ((:=))
import Json.Encode as Encode


type alias Cell a = {
  val: a,
  pos: (Int, Int)
}


type alias Grid a = List (Cell a)


fromList : a -> List (Int, Int) -> Grid a
fromList value = List.map (Cell value)


map : (a -> b) -> Grid a -> Grid b
map fun = List.map (\cell -> {cell | val = fun cell.val})


empty : Grid a
empty = []


-- rotates grid around center of mass
rotate : Bool -> Grid a -> Grid a
rotate clockwise grid =
  let
    (x, y) = centerOfMass grid
    fn cell =
      if clockwise then
        { cell | pos = (1 + y - snd cell.pos, -x + y + fst cell.pos) }
      else
        { cell | pos = (-y + x + snd cell.pos, 1 + x - fst cell.pos) }
  in
    List.map fn grid


-- stamps a grid into another grid with predefined offset
stamp : Int -> Int -> Grid a -> Grid a -> Grid a
stamp x y sample grid =
  case sample of
    [] -> grid
    cell :: rest ->
      let
        newPos = (fst cell.pos + x, snd cell.pos + y)
        newCell = {cell | pos = newPos}
      in
        stamp x y rest ({cell | pos = newPos} :: List.filter (\{pos} -> pos /= newPos) grid)


-- collides a positioned sample with a grid and its bounds
collide : Int -> Int -> Int -> Int -> Grid a -> Grid a -> Bool
collide wid hei x y sample grid =
  case sample of
    [] -> False
    cell :: rest ->
      let
        (x', y') = (fst cell.pos + x, snd cell.pos + y)
      in
        if (x' >= wid) || (x' < 0) || (y' >= hei) then
          True
        else
          if List.member (x', y') (List.map .pos grid) then
            True
          else
            collide wid hei x y rest grid


mapToList : (Int -> Int -> a -> b) -> Grid a -> List b
mapToList fun = List.map (\{val, pos} -> fun (fst pos) (snd pos) val)


fullLine : Int -> Grid a -> Maybe Int
fullLine wid grid =
  case grid of
    [] -> Nothing
    cell :: _ ->
      let
        lineY = snd cell.pos
        (inline, remaining) = List.partition (\{pos} -> snd pos == lineY) grid
      in
        if List.length inline == wid then
          Just lineY
        else
          fullLine wid remaining


clearLines : Int -> Grid a -> (Grid a, Int)
clearLines wid grid =
  case fullLine wid grid of
    Nothing -> (grid, 0)
    Just lineY ->
      let
        clearedGrid = List.filter (\{pos} -> snd pos /= lineY) grid
        (above, below) = List.partition (\{pos} -> snd pos < lineY) clearedGrid
        droppedAbove = List.map (\c -> { c | pos = (fst c.pos, snd c.pos + 1)}) above
        (newGrid, lines) = clearLines wid (droppedAbove ++ below)
      in
        (newGrid, lines + 1)


centerOfMass : Grid a -> (Int, Int)
centerOfMass grid =
  let
    len = toFloat (List.length grid)
    (x, y) = List.unzip (List.map .pos grid)
  in
    ( round (toFloat (List.sum x) / len)
    , round (toFloat (List.sum y) / len)
    )


decode : Decode.Decoder a -> Decode.Decoder (Grid a)
decode cell =
  Decode.list
  ( Decode.object2
    Cell
    ("val" := cell)
    ("pos" := Decode.tuple2 (,) Decode.int Decode.int)
  )


encode : (a -> Encode.Value) -> (Grid a) -> Encode.Value
encode cell grid =
  let
    encodeCell {val, pos} =
      Encode.object
      [ ("pos", Encode.list [Encode.int (fst pos), Encode.int (snd pos)])
      , ("val", cell val)
      ]
  in
    Encode.list (List.map encodeCell grid)
