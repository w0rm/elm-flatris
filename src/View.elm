module View exposing (view)

import Color exposing (Color)
import Grid exposing (Grid)
import Html exposing (Html, button, div, text)
import Html.Attributes exposing (style)
import Html.Events exposing (on, onClick, onMouseDown, onMouseUp)
import Json.Decode as Json
import Markdown
import Messages exposing (Msg(..))
import Model exposing (Model)
import Svg
import Svg.Attributes as SvgAttrs


onTouchStart : Msg -> Html.Attribute Msg
onTouchStart msg =
    on "touchstart" (Json.succeed msg)


onTouchEnd : Msg -> Html.Attribute Msg
onTouchEnd msg =
    on "touchend" (Json.succeed msg)


renderBox : (Color -> Color) -> Color -> ( Int, Int ) -> Html Msg
renderBox fun c ( x, y ) =
    Svg.rect
        [ SvgAttrs.width (String.fromInt 30)
        , SvgAttrs.height (String.fromInt 30)
        , SvgAttrs.fill (Color.toString (fun c))
        , SvgAttrs.stroke (Color.toString (fun c))
        , SvgAttrs.strokeWidth "0.5"
        , SvgAttrs.x (String.fromInt (x * 30))
        , SvgAttrs.y (String.fromInt (y * 30))
        ]
        []


renderNext : Grid Color -> Html Msg
renderNext grid =
    let
        ( width, height ) =
            Grid.size grid
    in
    grid
        |> Grid.mapToList
            (renderBox (always (Color.rgb 236 240 241)))
        |> Svg.svg
            [ SvgAttrs.width (String.fromInt (width * 30))
            , SvgAttrs.height (String.fromInt (height * 30))
            ]


renderWell : Model -> Html Msg
renderWell { width, height, active, grid, position } =
    grid
        |> Grid.stamp (Tuple.first position) (floor (Tuple.second position)) active
        |> Grid.mapToList (renderBox identity)
        |> (::)
            (Svg.rect
                [ SvgAttrs.width (String.fromInt (width * 30))
                , SvgAttrs.height (String.fromInt (height * 30))
                , SvgAttrs.fill "rgb(236, 240, 241)"
                ]
                []
            )
        |> Svg.svg
            [ SvgAttrs.width (String.fromInt (width * 30))
            , SvgAttrs.height (String.fromInt (height * 30))
            ]


renderTitle : String -> Html Msg
renderTitle txt =
    div
        [ style "color" "#34495f"
        , style "font-size" "40px"
        , style "line-height" "60px"
        , style "margin" "30px 0 0"
        ]
        [ text txt ]


renderLabel : String -> Html Msg
renderLabel txt =
    div
        [ style "color" "#bdc3c7"
        , style "font-weight" "300"
        , style "line-height" "1"
        , style "margin" "30px 0 0"
        ]
        [ text txt ]


renderCount : Int -> Html Msg
renderCount n =
    div
        [ style "color" "#3993d0"
        , style "font-size" "30px"
        , style "line-height" "1"
        , style "margin" "5px 0 0"
        ]
        [ text (String.fromInt n) ]


renderGameButton : Model.State -> Html Msg
renderGameButton state =
    let
        ( txt, msg ) =
            case state of
                Model.Stopped ->
                    ( "New game", Start )

                Model.Playing ->
                    ( "Pause", Pause )

                Model.Paused ->
                    ( "Resume", Resume )
    in
    button
        [ style "background" "#34495f"
        , style "border" "0"
        , style "bottom" "30px"
        , style "color" "#fff"
        , style "cursor" "pointer"
        , style "display" "block"
        , style "font-family" "Helvetica, Arial, sans-serif"
        , style "font-size" "18px"
        , style "font-weight" "300"
        , style "height" "60px"
        , style "left" "30px"
        , style "line-height" "60px"
        , style "outline" "none"
        , style "padding" "0"
        , style "position" "absolute"
        , style "width" "120px"
        , onClick msg
        ]
        [ text txt ]


renderPanel : Model -> Html Msg
renderPanel { score, lines, next, state } =
    div
        [ style "bottom" "80px"
        , style "color" "#34495f"
        , style "font-family" "Helvetica, Arial, sans-serif"
        , style "font-size" "14px"
        , style "left" "300px"
        , style "padding" "0 30px"
        , style "position" "absolute"
        , style "right" "0"
        , style "top" "0"
        ]
        [ renderTitle "Flatris"
        , renderLabel "Score"
        , renderCount score
        , renderLabel "Lines Cleared"
        , renderCount lines
        , renderLabel "Next Shape"
        , div
            [ style "margin-top" "10px"
            , style "position" "relative"
            ]
            [ renderNext next ]
        , renderGameButton state
        ]


renderControlButton : String -> List (Html.Attribute Msg) -> Html Msg
renderControlButton txt attrs =
    div
        ([ style "background" "#ecf0f1"
         , style "border" "0"
         , style "color" "#34495f"
         , style "cursor" "pointer"
         , style "text-align" "center"
         , style "-webkit-user-select" "none"
         , style "display" "block"
         , style "float" "left"
         , style "font-family" "Helvetica, Arial, sans-serif"
         , style "font-size" "24px"
         , style "font-weight" "300"
         , style "height" "60px"
         , style "line-height" "60px"
         , style "margin" "20px 20px 0 0"
         , style "outline" "none"
         , style "padding" "0"
         , style "width" "60px"
         ]
            ++ attrs
        )
        [ text txt ]


renderControls : Html Msg
renderControls =
    div
        [ style "height" "80px"
        , style "left" "0"
        , style "position" "absolute"
        , style "top" "600px"
        ]
        [ renderControlButton "↻"
            [ onMouseDown (Rotate True)
            , onMouseUp (Rotate False)
            , onTouchStart (Rotate True)
            , onTouchEnd (Rotate False)
            ]
        , renderControlButton "←"
            [ onMouseDown (MoveLeft True)
            , onMouseUp (MoveLeft False)
            , onTouchStart (MoveLeft True)
            , onTouchEnd (MoveLeft False)
            ]
        , renderControlButton "→"
            [ onMouseDown (MoveRight True)
            , onMouseUp (MoveRight False)
            , onTouchStart (MoveRight True)
            , onTouchEnd (MoveRight False)
            ]
        , renderControlButton "↓"
            [ onMouseDown (Accelerate True)
            , onMouseUp (Accelerate False)
            , onTouchStart (Accelerate True)
            , onTouchEnd (Accelerate False)
            ]
        ]


renderInfo : Model.State -> Html Msg
renderInfo state =
    div
        [ style "background" "rgba(236, 240, 241, 0.85)"
        , style "color" "#34495f"
        , style "font-family" "Helvetica, Arial, sans-serif"
        , style "font-size" "18px"
        , style "height" "600px"
        , style "left" "0"
        , style "line-height" "1.5"
        , style "padding" "0 15px"
        , style "position" "absolute"
        , style "top" "0"
        , style "width" "270px"
        , style "display"
            (if state == Model.Playing then
                "none"

             else
                "block"
            )
        ]
        [ Markdown.toHtml [] """
elm-flatris is a [**Flatris**](https://github.com/skidding/flatris)
clone coded in [**Elm**](http://elm-lang.org/) language.

Inspired by the classic [**Tetris**](http://en.wikipedia.org/wiki/Tetris)
game, the game can be played with a keyboard using the arrow keys,
and on mobile devices using the buttons below.

elm-flatris is open source on
[**GitHub**](https://github.com/w0rm/elm-flatris).
"""
        ]


pixelWidth : Float
pixelWidth =
    480


pixelHeight : Float
pixelHeight =
    680


view : Model -> Html Msg
view model =
    let
        ( w, h ) =
            model.size

        r =
            if w / h > pixelWidth / pixelHeight then
                min 1 (h / pixelHeight)

            else
                min 1 (w / pixelWidth)
    in
    div
        [ onTouchEnd UnlockButtons
        , onMouseUp UnlockButtons
        , style "width" "100%"
        , style "height" "100%"
        , style "position" "absolute"
        , style "left" "0"
        , style "top" "0"
        ]
        [ div
            [ style "width" (String.fromFloat pixelWidth ++ "px")
            , style "height" (String.fromFloat pixelHeight ++ "px")
            , style "position" "absolute"
            , style "left" (String.fromFloat ((w - pixelWidth * r) / 2) ++ "px")
            , style "top" (String.fromFloat ((h - pixelHeight * r) / 2) ++ "px")
            , style "transform-origin" "0 0"
            , style "transform" ("scale(" ++ String.fromFloat r ++ ")")
            ]
            [ renderWell model
            , renderControls
            , renderPanel model
            , renderInfo model.state
            ]
        ]
