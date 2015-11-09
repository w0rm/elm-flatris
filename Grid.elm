module Grid (Grid, fromList, map, make, rotate, stamp, collide, mapToList, substract) where
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
  let row = Maybe.withDefault Array.empty (Array.get y grid)
  in Maybe.withDefault Nothing (Array.get x row)


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
        [ get (x' - y) (y' - y) sample
        , get x' y' grid
        ]
  in
    make (width grid) (height grid) fn


collide : Int -> Int -> Grid a -> Grid a -> Bool
collide x y sample grid =
  let
    collideCell x' y' _ =
      case get (x' - x) (y' - y) sample of
        Just value -> True
        _ -> False
  in
    mapToList collideCell grid |> List.any identity


mapToList : (Int -> Int -> a -> b) -> Grid a -> List b
mapToList fun grid =
  let
    processCell x (y, cell) =
      Maybe.map (fun x y) cell
    processRow x row =
      Array.toIndexedList row
      |> List.filterMap (processCell x)
  in
    Array.indexedMap processRow grid
    |> Array.toList
    |> List.concat


substract : Grid a -> Grid a
substract grid =
  let
    hei = height grid
    wid = width grid
    keep row = List.any ((==) Nothing) (Array.toList row)
    grid' = Array.filter keep grid
    add = make wid (hei - height grid') (\_ _ -> Nothing)
  in
    Array.append add grid
