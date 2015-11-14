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
    Start ->
      ( { model | state <- Playing
                , lines <- 0
                , score <- 0
                , grid <- Grid.make 10 20 (\_ _ -> Nothing)
                }
      , Effects.tick Tick)
    Pause ->
      ({model | state <- Paused}, Effects.none)
    Resume ->
      ({model | state <- Playing}, Effects.tick Tick)
    Move dx ->
      (moveTetrimino dx model, Effects.none)
    Rotate ->
      (rotateTetrimino model, Effects.none)
    Accelerate on ->
      ({model | acceleration <- on }, Effects.none)
    Tick time ->
      if model.state == Playing then
        ( animate {model | animationState <- (updateAnimationState time model.animationState)}
        , Effects.tick Tick)
      else
        ({model | animationState <- Nothing}, Effects.none)
    _ -> (model, Effects.none)


updateAnimationState : Time -> AnimationState -> AnimationState
updateAnimationState time animationState =
  case animationState of
    Nothing ->
      Just { prevClockTime = time, elapsedFrames = 0 }
    Just {prevClockTime, elapsedFrames} ->
      Just { prevClockTime = time, elapsedFrames = (time - prevClockTime) / 1000 * 60 }


moveTetrimino : Int -> Model -> Model
moveTetrimino dx model =
  let
    (x, y) = model.activePosition
    x' = x + dx
  in
    if Grid.collide x' (floor y) model.active model.grid then
      model
    else
      {model | activePosition <- (x', y)}


rotateTetrimino : Model -> Model
rotateTetrimino model =
  let
    (x, y) = model.activePosition
    rotated = Grid.rotate True model.active
  in
    if Grid.collide x (floor y) rotated model.grid then
      model
    else
      {model | active <- rotated}


checkEndGame : Model -> Model
checkEndGame model =
  let
    check _ y _ = y == 0
  in
    if Grid.mapToList check model.grid |> List.any identity then
      {model | state <- Stopped}
    else
      model


dropTetrimino : Model -> Model
dropTetrimino model =
  let
    (x, y) = model.activePosition
    {prevClockTime, elapsedFrames} = Maybe.withDefault {prevClockTime=0, elapsedFrames=0} model.animationState
    y' = y + elapsedFrames / (if model.acceleration then 1.5 else 48)
  in
    if Grid.collide x (floor y') model.active model.grid then
      let
        (next, seed') = Tetriminos.random (Random.initialSeed prevClockTime)
      in
        {model | grid <- Grid.stamp x (floor y) model.active model.grid
               , activePosition <- (0, 0)
               , active <- model.next
               , next <- next
               , seed <- seed'
               }
        |> clearLines
    else
      {model | activePosition <- (x, y')}


clearLines : Model -> Model
clearLines model =
  let
    (grid, lines) = Grid.clearLines model.grid
  in
    { model | grid <- grid
            , lines <- model.lines + lines
            , score <- model.score + lines * 10
    }


animate : Model -> Model
animate model =
  model
  |> dropTetrimino
  |> checkEndGame
