module Update (update) where
import Model exposing (Model)
import Actions exposing (Action)
import Effects exposing (Effects)


update : Action -> Model -> (Model, Effects Action)
update action model =
  case action of
    _ -> (model, Effects.none)
