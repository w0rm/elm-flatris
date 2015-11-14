module View (view) where
import Html exposing (div, Html, text, button)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Markdown
import Model exposing (Model)
import Actions exposing (Action)
import Grid exposing (Grid)


(=>) : a -> b -> (a, b)
(=>) = (,)


renderBox : Int -> Int -> String -> Html
renderBox x y c =
  div
  [ style
    [ "background" => c
    , "height" => "30px"
    , "left" => (toString (x * 30) ++ "px")
    , "position" => "absolute"
    , "top" => (toString (y * 30) ++ "px")
    , "width" => "30px"
    ]
  ] []


renderBoxes : Grid String -> List Html
renderBoxes grid =
  Grid.mapToList renderBox grid


renderTetrimino : (Int, Float) -> Grid String -> Html
renderTetrimino coords grid =
  div
  [ style
    [ "left" => (toString (fst coords * 30) ++ "px")
    , "position" => "absolute"
    , "top" => (toString (floor (snd coords) * 30) ++ "px")
    ]
  ]
  (renderBoxes grid)


renderWell : Signal.Address Action -> Model -> Html
renderWell address model =
  div
  [ style
    [ "background" => "#ecf0f1"
    , "height" => "600px"
    , "left" => "0"
    , "overflow" => "hidden"
    , "position" => "absolute"
    , "top" => "0"
    , "width" => "300px"
    ]
  ]
  (renderTetrimino model.activePosition model.active :: renderBoxes model.grid)


renderTitle : String -> Html
renderTitle txt =
  div
  [ style
    [ "color" => "#34495f"
    , "font-size" => "40px"
    , "line-height" => "60px"
    , "margin" => "30px 0 0"
    ]
  ]
  [ text txt ]


renderLabel : String -> Html
renderLabel txt =
  div
  [ style
    [ "color" => "#bdc3c7"
    , "font-weight" => "300"
    , "line-height" => "1"
    , "margin" => "30px 0 0"
    ]
  ]
  [ text txt ]


renderCount : Int -> Html
renderCount n =
  div
  [ style
    [ "color" => "#3993d0"
    , "font-size" => "30px"
    , "line-height" => "1"
    , "margin" => "5px 0 0"
    ]
  ]
  [ toString n |> text ]


renderGameButton : Signal.Address Action -> Model.State -> Html
renderGameButton address state =
  let
    (txt, action) = case state of
      Model.Stopped -> ("New game", Actions.Start)
      Model.Playing -> ("Pause", Actions.Pause)
      Model.Paused -> ("Resume", Actions.Resume)
  in
    button
    [ style
      [ "background" => "#34495f"
      , "border" => "0"
      , "bottom" => "30px"
      , "color" => "#fff"
      , "cursor" => "pointer"
      , "display" => "block"
      , "font-family" => "Helvetica, Arial, sans-serif"
      , "font-size" => "18px"
      , "font-weight" => "300"
      , "height" => "60px"
      , "left" => "30px"
      , "line-height" => "60px"
      , "outline" => "none"
      , "padding" => "0"
      , "position" => "absolute"
      , "width" => "120px"
      ]
    , onClick address action
    ]
    [ text txt ]


renderPanel : Signal.Address Action -> Model -> Html
renderPanel address model =
  div
  [ style
    [ "bottom" => "80px"
    , "color" => "#34495f"
    , "font-family" => "Helvetica, Arial, sans-serif"
    , "font-size" => "14px"
    , "left" => "300px"
    , "padding" => "0 30px"
    , "position" => "absolute"
    , "right" => "0"
    , "top" => "0"
    ]
  ]
  [ renderTitle "Flatris"
  , renderLabel "Score"
  , renderCount model.score
  , renderLabel "Lines Cleared"
  , renderCount model.lines
  , renderLabel "Next Shape"
  , div
    [ style
      [ "margin-top" => "10px"
      , "position" => "relative"
      ]
    ]
    (Grid.map (\_ -> "#ecf0f1") model.next |> renderBoxes)
  , renderGameButton address model.state
  ]


renderControlButton : String -> Html
renderControlButton txt =
  button
  [ style
    [ "background" => "#ecf0f1"
    , "border" => "0"
    , "color" => "#34495f"
    , "cursor" => "pointer"
    , "display" => "block"
    , "float" => "left"
    , "font-family" => "Helvetica, Arial, sans-serif"
    , "font-size" => "24px"
    , "font-weight" => "300"
    , "height" => "60px"
    , "line-height" => "60px"
    , "margin" => "20px 20px 0 0"
    , "outline" => "none"
    , "padding" => "0"
    , "width" => "60px"
    ]
  ]
  [ text txt ]


renderControls : Html
renderControls =
  div
  [ style
    [ "height" => "80px"
    , "left" => "0"
    , "position" => "absolute"
    , "top" => "600px"
    ]
  ]
  [ renderControlButton "↻"
  , renderControlButton "←"
  , renderControlButton "→"
  , renderControlButton "↓"
  ]


renderInfo : Model.State -> Html
renderInfo state =
  div
  [ style
    [ "background" => "rgba(236, 240, 241, 0.85)"
    , "color" => "#34495f"
    , "font-family" => "Helvetica, Arial, sans-serif"
    , "font-size" => "18px"
    , "height" => "600px"
    , "left" => "0"
    , "line-height" => "1.5"
    , "padding" => "0 15px"
    , "position" => "absolute"
    , "top" => "0"
    , "width" => "270px"
    , "display" => (if state == Model.Playing then "none" else "block")
    ]
  ] [
    Markdown.toHtml """
elm-flatris is a [**Flatris**](https://github.com/skidding/flatris)
clone coded in [**elm**](http://elm-lang.org/) language.

Inspired by the classic [**Tetris**](http://en.wikipedia.org/wiki/Tetris)
game, the game can be played with a keyboard using the arrow keys.

elm-flatris is open source on
[**GitHub**](https://github.com/w0rm/elm-flatris).
"""
  ]


view : Signal.Address Action -> Model -> Html
view address model =
  div
  [ style ["padding" => "30px 0"] ]
  [ div
    [ style
      [ "height" => "680px"
      , "margin" => "auto"
      , "position" => "relative"
      , "width" => "480px"
      ]
    ]
    [ renderWell address model
    , renderPanel address model
    , renderInfo model.state
    ]
  ]
