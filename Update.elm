module Update (update) where
import Model exposing (..)
import Actions exposing (..)
import Effects exposing (Effects)
import Tetriminos
import Time exposing (Time)
import Grid


framesSince : Time -> Time -> Float
framesSince prevTime time =
  (time - prevTime) * 60 / 1000


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    Start ->
      ( { model | state = Playing
                , lines = 0
                , score = 0
                , grid = Grid.make 10 20 (\_ _ -> Nothing)
                }
      , Effects.tick Tick
      )
    Pause ->
      ( {model | state = Paused}
      , Effects.none
      )
    Resume ->
      ( {model | state = Playing}
      , Effects.tick Tick
      )
    Move 0 ->
      ( {model | direction = Nothing}
      , Effects.none
      )
    Move direction ->
      ( { model | direction = Just { active = True
                                   , direction = direction
                                   , elapsedFrames = 0
                                   }
        }
      , Effects.none
      )
    Rotate False ->
      ( {model | rotation = Nothing}
      , Effects.none
      )
    Rotate True ->
      ( {model | rotation = Just {active = True, elapsedFrames = 0}}
      , Effects.none
      )
    Accelerate on ->
      ( {model | acceleration = on }
      , Effects.none
      )
    Tick time ->
      if model.state == Playing then
        (animate time model, Effects.tick Tick)
      else
        ({model | animationState = Nothing}, Effects.none)


animate : Time -> Model -> Model
animate time model =
  let
    elapsedFrames =
      case model.animationState of
        Nothing ->
          0
        Just {prevClockTime} ->
          framesSince prevClockTime time
    animationState = Just {prevClockTime = time, elapsedFrames = elapsedFrames}
  in
    {model | animationState = animationState}
    |> moveTetrimino elapsedFrames
    |> rotateTetrimino elapsedFrames
    |> dropTetrimino elapsedFrames
    |> checkEndGame


moveTetrimino : Float -> Model -> Model
moveTetrimino elapsedFrames model =
  case model.direction of
    Just state ->
      {model | direction = Just (updateFrames 10 elapsedFrames state)}
      |> (if state.active then moveTetrimino' state.direction else identity)
    Nothing -> model


moveTetrimino' : Int -> Model -> Model
moveTetrimino' dx model =
  let
    (x, y) = model.activePosition
    x' = x + dx
  in
    if Grid.collide x' (floor y) model.active model.grid then
      model
    else
      {model | activePosition = (x', y)}


updateFrames : Float -> Float -> {a | active: Bool, elapsedFrames: Float} -> {a | active: Bool, elapsedFrames: Float}
updateFrames limit elapsedFrames state =
  let
    elapsedFrames' = state.elapsedFrames + elapsedFrames
  in
    if elapsedFrames' > limit then
      {state | active = True, elapsedFrames = elapsedFrames' - limit}
    else
      {state | active = False, elapsedFrames = elapsedFrames'}


rotateTetrimino : Float -> Model -> Model
rotateTetrimino elapsedFrames model =
  case model.rotation of
    Just rotation ->
      {model | rotation = Just (updateFrames 30 elapsedFrames rotation)}
      |> (if rotation.active then rotateTetrimino' else identity)
    Nothing -> model


rotateTetrimino' : Model -> Model
rotateTetrimino' model =
  let
    (x, y) = model.activePosition
    rotated = Grid.rotate True model.active
    (xOld, yOld) = Grid.centerOfMass model.active
    (xNew, yNew) = Grid.centerOfMass rotated
    newX = x + xOld - xNew
    newY = y + toFloat (yOld - yNew)
    shiftPosition deltas =
      case deltas of
        dx :: remainingDeltas ->
          if Grid.collide (newX + dx) (floor newY) rotated model.grid then
            shiftPosition remainingDeltas
          else
            {model | active = rotated, activePosition = (newX + dx, newY)}
        [] ->
          model
  in
    shiftPosition [0, 1, -1, 2, -2]


checkEndGame : Model -> Model
checkEndGame model =
  let
    check _ y _ = y == 0
  in
    if Grid.mapToList check model.grid |> List.any identity then
      {model | state = Stopped}
    else
      model


dropTetrimino : Float -> Model -> Model
dropTetrimino elapsedFrames model =
  let
    (x, y) = model.activePosition
    y' = y + elapsedFrames / (if model.acceleration then 1.5 else 48)
  in
    if Grid.collide x (floor y') model.active model.grid then
      let
        score = List.length (Grid.mapToList (\_ _ _ -> True) model.active)
        (next, seed') = Tetriminos.random model.seed
      in
        {model | grid = Grid.stamp x (floor y) model.active model.grid
               , activePosition = (0, 0)
               , active = model.next
               , next = next
               , seed = seed'
               , score = model.score + score
               }
        |> clearLines
    else
      {model | activePosition = (x, y')}


clearLines : Model -> Model
clearLines model =
  let
    (grid, lines) = Grid.clearLines model.grid
  in
    { model | grid = grid
            , lines = model.lines + lines
    }
