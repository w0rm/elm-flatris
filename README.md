# elm-flatris
A [Flatris](https://github.com/skidding/flatris) clone in Elm language v0.17.

[![Screenshot](elm-flatris.png)](http://unsoundscapes.com/elm-flatris.html)

Current demo can be seen [here](http://unsoundscapes.com/elm-flatris.html).

## Features

* works on both desktop and mobile
* renders the grid to canvas with `Graphics.Collage`
* preserves the game state in `localStorage`, just try to reload the page while playing!

## Instructions to run

1. Install elm [elm-lang.org/install](http://elm-lang.org/install)
2. Clone this repo and `cd` into it
3. Run `elm reactor`
4. Open [localhost:8000/src/Main.elm](http://localhost:8000/src/Main.elm) in the browser

## Touch support (tested on iOS)

For a touch support compile to html `elm make src/Main.elm --output elm-flatris.html` and add the following meta:

```html
<meta name="viewport" content="width=480,user-scalable=0">
```
