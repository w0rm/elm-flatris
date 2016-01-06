# elm-flatris
A [Flatris](https://github.com/skidding/flatris) clone in elm language.

Current demo can be seen [here](http://unsoundscapes.com/elm-flatris.html).

## Instructions to run

1. Install elm [elm-lang.org/install](http://elm-lang.org/install)
2. Clone this repo and `cd` into it
3. Run `elm reactor`
4. Open [localhost:8000/Main.elm](http://localhost:8000/Main.elm) in the browser


## Touch support (tested on iOS)

For a touch support compile to html `elm make Main.elm --output elm-flatris.html` and add the following meta:

```html
<meta name="viewport" content="width=480,user-scalable=0">
```
