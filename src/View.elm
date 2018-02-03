module View exposing (view)

import Html exposing (div, Html, text, button)
import Collage
import Element
import Color exposing (Color)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick, onMouseDown, onMouseUp, on)
import Markdown
import Model exposing (Model)
import Messages exposing (Msg(..))
import Grid exposing (Grid)
import Json.Decode as Json


onTouchStart : Msg -> Html.Attribute Msg
onTouchStart msg =
    on "touchstart" (Json.succeed msg)


onTouchEnd : Msg -> Html.Attribute Msg
onTouchEnd msg =
    on "touchend" (Json.succeed msg)


renderBox : ( Float, Float ) -> (Color -> Color) -> Color -> ( Int, Int ) -> Collage.Form
renderBox ( xOff, yOff ) fun c ( x, y ) =
    Collage.rect 30 30
        |> Collage.filled (fun c)
        |> Collage.move ( (toFloat x + xOff) * 30, (toFloat y + yOff) * -30 )


renderNext : Grid Color -> Html Msg
renderNext grid =
    let
        ( width, height ) =
            Grid.size grid
    in
        grid
            |> Grid.mapToList (renderBox ( (1 - toFloat width) / 2, (1 - toFloat height) / 2 ) (always (Color.rgb 236 240 241)))
            |> Collage.collage (width * 30) (height * 30)
            |> Element.toHtml


renderWell : Model -> Html Msg
renderWell { width, height, active, grid, position } =
    (Collage.filled (Color.rgb 236 240 241) (Collage.rect (toFloat (width * 30)) (toFloat (height * 30)))
        :: (grid
                |> Grid.stamp (Tuple.first position) (floor (Tuple.second position)) active
                |> Grid.mapToList (renderBox ( (1 - toFloat width) / 2, (1 - toFloat height) / 2 ) identity)
           )
    )
        |> Collage.collage (width * 30) (height * 30)
        |> Element.toHtml


renderTitle : String -> Html Msg
renderTitle txt =
    div
        [ style
            [ ( "color", "#34495f" )
            , ( "font-size", "40px" )
            , ( "line-height", "60px" )
            , ( "margin", "30px 0 0" )
            ]
        ]
        [ text txt ]


renderLabel : String -> Html Msg
renderLabel txt =
    div
        [ style
            [ ( "color", "#bdc3c7" )
            , ( "font-weight", "300" )
            , ( "line-height", "1" )
            , ( "margin", "30px 0 0" )
            ]
        ]
        [ text txt ]


renderCount : Int -> Html Msg
renderCount n =
    div
        [ style
            [ ( "color", "#3993d0" )
            , ( "font-size", "30px" )
            , ( "line-height", "1" )
            , ( "margin", "5px 0 0" )
            ]
        ]
        [ text (toString n) ]


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
            [ style
                [ ( "background", "#34495f" )
                , ( "border", "0" )
                , ( "bottom", "30px" )
                , ( "color", "#fff" )
                , ( "cursor", "pointer" )
                , ( "display", "block" )
                , ( "font-family", "Helvetica, Arial, sans-serif" )
                , ( "font-size", "18px" )
                , ( "font-weight", "300" )
                , ( "height", "60px" )
                , ( "left", "30px" )
                , ( "line-height", "60px" )
                , ( "outline", "none" )
                , ( "padding", "0" )
                , ( "position", "absolute" )
                , ( "width", "120px" )
                ]
            , onClick msg
            ]
            [ text txt ]


renderPanel : Model -> Html Msg
renderPanel { score, lines, next, state } =
    div
        [ style
            [ ( "bottom", "80px" )
            , ( "color", "#34495f" )
            , ( "font-family", "Helvetica, Arial, sans-serif" )
            , ( "font-size", "14px" )
            , ( "left", "300px" )
            , ( "padding", "0 30px" )
            , ( "position", "absolute" )
            , ( "right", "0" )
            , ( "top", "0" )
            ]
        ]
        [ renderTitle "Flatris"
        , renderLabel "Score"
        , renderCount score
        , renderLabel "Lines Cleared"
        , renderCount lines
        , renderLabel "Next Shape"
        , div
            [ style
                [ ( "margin-top", "10px" )
                , ( "position", "relative" )
                ]
            ]
            [ renderNext next ]
        , renderGameButton state
        ]


renderControlButton : String -> List (Html.Attribute Msg) -> Html Msg
renderControlButton txt attrs =
    div
        (style
            [ ( "background", "#ecf0f1" )
            , ( "border", "0" )
            , ( "color", "#34495f" )
            , ( "cursor", "pointer" )
            , ( "text-align", "center" )
            , ( "-webkit-user-select", "none" )
            , ( "display", "block" )
            , ( "float", "left" )
            , ( "font-family", "Helvetica, Arial, sans-serif" )
            , ( "font-size", "24px" )
            , ( "font-weight", "300" )
            , ( "height", "60px" )
            , ( "line-height", "60px" )
            , ( "margin", "20px 20px 0 0" )
            , ( "outline", "none" )
            , ( "padding", "0" )
            , ( "width", "60px" )
            ]
            :: attrs
        )
        [ text txt ]


renderControls : Html Msg
renderControls =
    div
        [ style
            [ ( "height", "80px" )
            , ( "left", "0" )
            , ( "position", "absolute" )
            , ( "top", "600px" )
            ]
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
        [ style
            [ ( "background", "rgba(236, 240, 241, 0.85)" )
            , ( "color", "#34495f" )
            , ( "font-family", "Helvetica, Arial, sans-serif" )
            , ( "font-size", "18px" )
            , ( "height", "600px" )
            , ( "left", "0" )
            , ( "line-height", "1.5" )
            , ( "padding", "0 15px" )
            , ( "position", "absolute" )
            , ( "top", "0" )
            , ( "width", "270px" )
            , ( "display"
              , if state == Model.Playing then
                    "none"
                else
                    "block"
              )
            ]
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
        w =
            toFloat model.size.width

        h =
            toFloat model.size.height

        r =
            if w / h > pixelWidth / pixelHeight then
                min 1 (h / pixelHeight)
            else
                min 1 (w / pixelWidth)
    in
        div
            [ onTouchEnd UnlockButtons
            , onMouseUp UnlockButtons
            , style
                [ ( "width", "100%" )
                , ( "height", "100%" )
                , ( "position", "relative" )
                ]
            ]
            [ div
                [ style
                    [ ( "width", toString pixelWidth ++ "px" )
                    , ( "height", toString pixelHeight ++ "px" )
                    , ( "position", "absolute" )
                    , ( "left", toString ((w - pixelWidth * r) / 2) ++ "px" )
                    , ( "top", toString ((h - pixelHeight * r) / 2) ++ "px" )
                    , ( "transform-origin", "0 0" )
                    , ( "transform", "scale(" ++ toString r ++ ")" )
                    ]
                ]
                [ renderWell model
                , renderControls
                , renderPanel model
                , renderInfo model.state
                ]
            ]
