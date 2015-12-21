# elm-localstorage

LocalStorage task adapter for Elm

Read/write/remove items from the browser's localStorage via Elm Tasks.
Limited to string keys and values, but includes a helper for retrieving decoded
JSON values.

## Example

```elm
import Graphics.Element exposing (..)
import LocalStorage


hello : Signal.Mailbox String
hello =
  Signal.mailbox "loading"


main : Signal Element
main =
  Signal.map show hello.signal


port runHello : Task LocalStorage.Error ()
port runHello =
  (LocalStorage.get "some-key") `andThen` Signal.send hello.address
```
