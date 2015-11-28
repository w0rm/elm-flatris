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
    Move dx ->
      if dx /= 0 then
        ( {model | direction = Just {active = True, direction = dx, elapsedFrames = 0}}
        , Effects.none
        )
      else
        ( {model | direction = Nothing}
        , Effects.none
        )
    Rotate bool ->
      if bool then
        ( {model | rotation = Just {active = True, elapsedFrames = 0}}
        , Effects.none
        )
      else
        ({model | rotation = Nothing}, Effects.none)
    Accelerate on ->
      ({model | acceleration = on }, Effects.none)
    Tick time ->
      if model.state == Playing then
        (animate time model, Effects.tick Tick)
      else
        ({model | animationState = Nothing}, Effects.none)


animate : Time -> Model -> Model
animate time =
  animateModel time
  >> moveTetrimino
  >> rotateTetrimino
  >> dropTetrimino
  >> checkEndGame


animateModel : Time -> Model -> Model
animateModel time model =
  let
    animationState =
      case model.animationState of
        Nothing ->
          Just { prevClockTime = time
               , elapsedFrames = 0
               }
        Just {prevClockTime} ->
          Just { prevClockTime = time
               , elapsedFrames = framesSince prevClockTime time
               }
  in
    {model | animationState = animationState}


moveTetrimino : Model -> Model
moveTetrimino model =
  let
    updateFrames elapsedFrames direction =
      let
        elapsedFrames' = case model.animationState of
          Just state -> elapsedFrames + state.elapsedFrames
          Nothing -> elapsedFrames
      in
        if elapsedFrames' > 10 then
          {model | direction = Just {active = True, direction = direction, elapsedFrames = 0}}
        else
          {model | direction = Just {active = False, direction = direction, elapsedFrames = elapsedFrames'}}
  in
    case model.direction of
      Just {active, direction, elapsedFrames} ->
        if active then
          updateFrames elapsedFrames direction |> moveTetrimino' direction
        else
          updateFrames elapsedFrames direction
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


rotateTetrimino : Model -> Model
rotateTetrimino model =
  let
    updateFrames elapsedFrames =
      let
        elapsedFrames' = case model.animationState of
          Just state -> elapsedFrames + state.elapsedFrames
          Nothing -> elapsedFrames
      in
        if elapsedFrames' > 30 then
          {model | rotation = Just {active = True, elapsedFrames = 0}}
        else
          {model | rotation = Just {active = False, elapsedFrames = elapsedFrames'}}
  in
    case model.rotation of
      Just {active, elapsedFrames} ->
        if active then
          updateFrames elapsedFrames |> rotateTetrimino'
        else
          updateFrames elapsedFrames
      Nothing -> model


rotateTetrimino' : Model -> Model
rotateTetrimino' model =
  let
    (x, y) = model.activePosition
    rotated = Grid.rotate True model.active
  in
    if Grid.collide x (floor y) rotated model.grid then
      model
    else
      {model | active = rotated}


checkEndGame : Model -> Model
checkEndGame model =
  let
    check _ y _ = y == 0
  in
    if Grid.mapToList check model.grid |> List.any identity then
      {model | state = Stopped}
    else
      model


dropTetrimino : Model -> Model
dropTetrimino model =
  let
    (x, y) = model.activePosition
    elapsedFrames =
      case model.animationState of
        Just {elapsedFrames} -> elapsedFrames
        Nothing -> 0
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
