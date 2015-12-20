module Update (update) where
import Model exposing (..)
import Actions exposing (..)
import Effects exposing (Effects)
import Tetriminos
import Time exposing (Time)
import Grid
import Random


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    Init time ->
      let
        initialSeed = Random.initialSeed (floor time)
        (active, seed') = Tetriminos.random initialSeed
        (next, seed) = Tetriminos.random seed'
        (dx, _) = Grid.centerOfMass active
      in
        ( { model
          | seed = seed
          , active = active
          , activePosition = (Grid.width model.grid // 2 - dx, 0)
          , next = next
          }
        , Effects.none
        )
    Start ->
      ( { model
        | state = Playing
        , lines = 0
        , score = 0
        , grid = Grid.empty 10 20
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
      ( { model
        | direction = Just { active = True
                           , direction = direction
                           , elapsed = 0
                           }
        }
      , Effects.none
      )
    Rotate False ->
      ( {model | rotation = Nothing}
      , Effects.none
      )
    Rotate True ->
      ( {model | rotation = Just {active = True, elapsed = 0}}
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
        ({model | animation = Nothing}, Effects.none)


animate : Time -> Model -> Model
animate time model =
  let
    elapsed = case model.animation of
      Nothing -> 0
      Just {prevClockTime} -> min (time - prevClockTime) 25
    animation = Just {prevClockTime = time, elapsed = elapsed}
  in
    {model | animation = animation}
    |> moveTetrimino elapsed
    |> rotateTetrimino elapsed
    |> dropTetrimino elapsed
    |> checkEndGame


moveTetrimino : Float -> Model -> Model
moveTetrimino elapsed model =
  case model.direction of
    Just state ->
      {model | direction = Just (updateFrames 150 elapsed state)}
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


updateFrames : Float -> Float -> {a | active: Bool, elapsed: Float} -> {a | active: Bool, elapsed: Float}
updateFrames limit elapsed state =
  let
    elapsed' = state.elapsed + elapsed
  in
    if elapsed' > limit then
      {state | active = True, elapsed = elapsed' - limit}
    else
      {state | active = False, elapsed = elapsed'}


animateObject : Time -> Time -> ({a | elapsed: Time} -> {a | elapsed: Time}) -> {a | elapsed: Time} -> {a | elapsed: Time}
animateObject limit elapsed animationFunc state =
  let
    elapsed' = state.elapsed + elapsed
  in
    if elapsed' > limit then
      animationFunc {state | elapsed = elapsed' - limit}
    else
      {state | elapsed = elapsed'}



rotateTetrimino : Float -> Model -> Model
rotateTetrimino elapsed model =
  case model.rotation of
    Just rotation ->
      {model | rotation = Just (updateFrames 300 elapsed rotation)}
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
dropTetrimino elapsed model =
  let
    (x, y) = model.activePosition
    y' = y + elapsed / (if model.acceleration then 25 else 800)
  in
    if Grid.collide x (floor y') model.active model.grid then
      let
        score = List.length (Grid.mapToList (\_ _ _ -> True) model.active)
        (next, seed') = Tetriminos.random model.seed
        (dx, _) = Grid.centerOfMass model.next
      in
        {model | grid = Grid.stamp x (floor y) model.active model.grid
               , activePosition = (Grid.width model.grid // 2 - dx, 0)
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
