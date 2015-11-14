module Grid (Grid, fromList, map, make, rotate, stamp, collide, mapToList, clearLines) where
import Array exposing (Array)


type alias Grid a = Array (Array (Maybe a))


fromList : List (List (Maybe a)) -> Grid a
fromList listOfLists =
  List.map Array.fromList listOfLists |> Array.fromList


map : (a -> b) -> Grid a -> Grid b
map fun grid =
  Array.map (\row -> Array.map (Maybe.map fun) row) grid


make : Int -> Int -> (Int -> Int -> Maybe a) -> Grid a
make w h f =
  Array.initialize h (\y -> Array.initialize w (\x -> f x y))


get : Int -> Int -> Grid a -> Maybe a
get x y grid =
  let
    row = Maybe.withDefault Array.empty (Array.get y grid)
  in
    Maybe.withDefault Nothing (Array.get x row)


height : Grid a -> Int
height =
  Array.length


width : Grid a -> Int
width grid =
  Maybe.map Array.length (Array.get 0 grid)
  |> Maybe.withDefault 0


rotate : Bool -> Grid a -> Grid a
rotate clockwise grid =
  let
    wid = width grid
    hei = height grid
    fn x y =
      if clockwise
        then get y (wid - x - 1) grid
        else get (hei - y - 1) x grid
  in
    make hei wid fn


stamp : Int -> Int -> Grid a -> Grid a -> Grid a
stamp x y sample grid =
  let
    fn x' y' =
      Maybe.oneOf
        [ get (x' - x) (y' - y) sample
        , get x' y' grid
        ]
  in
    make (width grid) (height grid) fn


-- collides a positioned sample with a grid and its bounds
collide : Int -> Int -> Grid a -> Grid a -> Bool
collide x y sample grid =
  let
    wid = width grid
    hei = height grid
    collideCell x' y' _ =
      if (x' + x >= wid) || (x' + x < 0) || (y + y' >= hei) then
        True
      else
        case get (x' + x) (y' + y) grid of
          Just value -> True
          Nothing -> False
  in
    mapToList collideCell sample |> List.any identity


mapToList : (Int -> Int -> a -> b) -> Grid a -> List b
mapToList fun grid =
  let
    processCell y (x, cell) =
      Maybe.map (fun x y) cell
    processRow y row =
      Array.toIndexedList row
      |> List.filterMap (processCell y)
  in
    Array.indexedMap processRow grid
    |> Array.toList
    |> List.concat


clearLines : Grid a -> (Grid a, Int)
clearLines grid =
  let
    hei = height grid
    wid = width grid
    keep row = List.any ((==) Nothing) (Array.toList row)
    grid' = Array.filter keep grid
    lines = hei - height grid'
    add = make wid lines (\_ _ -> Nothing)
  in
    (Array.append add grid', lines)
