module Grid exposing (Grid, decode, encode, fromList, empty, rotate, stamp, collide, mapToList, clearLines, initPosition, size)

import Json.Decode as Decode
import Json.Encode as Encode


type alias Cell a =
    { val : a
    , pos : ( Int, Int )
    }


type alias Grid a =
    List (Cell a)


fromList : a -> List ( Int, Int ) -> Grid a
fromList value =
    List.map (Cell value)


mapToList : (a -> ( Int, Int ) -> b) -> Grid a -> List b
mapToList fun =
    List.map (\{ val, pos } -> fun val pos)


empty : Grid a
empty =
    []



-- rotates grid around center of mass


rotate : Bool -> Grid a -> Grid a
rotate clockwise grid =
    let
        ( x, y ) =
            centerOfMass grid

        fn cell =
            if clockwise then
                { cell | pos = ( 1 + y - Tuple.second cell.pos, -x + y + Tuple.first cell.pos ) }
            else
                { cell | pos = ( -y + x + Tuple.second cell.pos, 1 + x - Tuple.first cell.pos ) }
    in
        List.map fn grid



-- stamps a grid into another grid with predefined offset


stamp : Int -> Int -> Grid a -> Grid a -> Grid a
stamp x y sample grid =
    case sample of
        [] ->
            grid

        cell :: rest ->
            let
                newPos =
                    ( Tuple.first cell.pos + x, Tuple.second cell.pos + y )

                newCell =
                    { cell | pos = newPos }
            in
                stamp x y rest ({ cell | pos = newPos } :: List.filter (\{ pos } -> pos /= newPos) grid)



-- collides a positioned sample with bounds and a grid


collide : Int -> Int -> Int -> Int -> Grid a -> Grid a -> Bool
collide wid hei x y sample grid =
    case sample of
        [] ->
            False

        cell :: rest ->
            let
                ( x_, y_ ) =
                    ( Tuple.first cell.pos + x, Tuple.second cell.pos + y )
            in
                if (x_ >= wid) || (x_ < 0) || (y_ >= hei) || List.member ( x_, y_ ) (List.map .pos grid) then
                    True
                else
                    collide wid hei x y rest grid



-- finds the first full line to be cleared


fullLine : Int -> Grid a -> Maybe Int
fullLine wid grid =
    case grid of
        [] ->
            Nothing

        cell :: _ ->
            let
                lineY =
                    Tuple.second cell.pos

                ( inline, remaining ) =
                    List.partition (\{ pos } -> Tuple.second pos == lineY) grid
            in
                if List.length inline == wid then
                    Just lineY
                else
                    fullLine wid remaining



-- returns updated grid and number of cleared lines


clearLines : Int -> Grid a -> ( Grid a, Int )
clearLines wid grid =
    case fullLine wid grid of
        Nothing ->
            ( grid, 0 )

        Just lineY ->
            let
                clearedGrid =
                    List.filter (\{ pos } -> Tuple.second pos /= lineY) grid

                ( above, below ) =
                    List.partition (\{ pos } -> Tuple.second pos < lineY) clearedGrid

                droppedAbove =
                    List.map (\c -> { c | pos = ( Tuple.first c.pos, Tuple.second c.pos + 1 ) }) above

                ( newGrid, lines ) =
                    clearLines wid (droppedAbove ++ below)
            in
                ( newGrid, lines + 1 )


size : Grid a -> ( Int, Int )
size grid =
    let
        ( x, y ) =
            List.unzip (List.map .pos grid)

        dimension d =
            Maybe.withDefault 0 (List.maximum (List.map (\a -> a + 1) d))
    in
        ( dimension x, dimension y )


centerOfMass : Grid a -> ( Int, Int )
centerOfMass grid =
    let
        len =
            toFloat (List.length grid)

        ( x, y ) =
            List.unzip (List.map .pos grid)
    in
        ( round (toFloat (List.sum x) / len)
        , round (toFloat (List.sum y) / len)
        )


decode : Decode.Decoder a -> Decode.Decoder (Grid a)
decode cell =
    Decode.list
        (Decode.map2
            Cell
            (Decode.field "val" cell)
            (Decode.field "pos" (Decode.map2 (,) (Decode.index 0 Decode.int) (Decode.index 1 Decode.int)))
        )


encode : (a -> Encode.Value) -> Grid a -> Encode.Value
encode cell grid =
    let
        encodeCell { val, pos } =
            Encode.object
                [ ( "pos", Encode.list [ Encode.int (Tuple.first pos), Encode.int (Tuple.second pos) ] )
                , ( "val", cell val )
                ]
    in
        Encode.list (List.map encodeCell grid)


initPosition : Int -> Grid a -> ( Int, Int )
initPosition wid grid =
    let
        ( x, _ ) =
            centerOfMass grid

        y =
            Maybe.withDefault 0 (List.maximum (List.map (Tuple.second << .pos) grid))
    in
        ( wid // 2 - x, -y - 1 )
