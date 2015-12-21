
module LocalStorage
  (get, set, remove, getJson, Error(..)) where

{-|

This library offers rudimentary access to the browser's localStorage, which is
limited to string keys and values. It uses Elm Tasks for storage IO.

# Retrieving
@docs get, getJson

# Storing
@docs set

# Removing
@docs remove

-}

import Native.LocalStorage
import String
import Task exposing (Task, andThen, succeed, fail)
import Json.Decode as Json
import Maybe exposing (Maybe(..))

type Error
  = NoStorage
  | UnexpectedPayload String

{-|

Retrieve the string value for a given key. Yields Maybe.Nothing if the key
does not exist in storage. Task will fail with NoStorage if localStorage is
not available in the browser:

    result : Signal.Mailbox String
    result = Signal.mailbox "loading..."

    main : Signal Element
    main = Signal.map show result.signal

    port getStorage : Task LocalStorage.Error ()
    port getStorage =
      let handle str =
        case str of
          Just s -> Signal.send result.address s
          Nothing -> Signal.send result.address "not found in storage =("
      in
        (LocalStorage.get "some-key")
          `onError` (\_ -> succeed (Just "no localStorage in browser =((("))
          `andThen` handle

-}
get : String -> Task Error (Maybe String)
get =
  Native.LocalStorage.get

{-|

Retrieves the value for a given key and parses it using the provided JSON
decoder. Yields Maybe.Nothing if the key does not exist in storage. Task will
fail with NoStorage if localStorage is not available in the browser, or
UnexpectedPayload if there was a parsing error:

    result : Signal.Mailbox String
    result = Signal.mailbox "loading..."

    main : Signal Element
    main = Signal.map show result.signal

    port getStorage : Task LocalStorage.Error ()
    port getStorage =
      let handleError err =
            case err of
              LocalStorage.NoStorage ->
                succeed (Just "no localStorage in browser =(((")
              LocalStorage.UnexpectedPayload _ ->
                succeed (Just "JSON parse err! wha happehn?")
          handle str =
            case str of
              Just s -> Signal.send result.address s
              Nothing -> Signal.send result.address "not found in storage =("
      in
        (LocalStorage.getJson Json.string "some-json-key")
          `onError` handleError
          `andThen` handle

-}
getJson : Json.Decoder value -> String -> Task Error (Maybe value)
getJson decoder key =
  let decode maybe =
    case maybe of
      Just str -> fromJson decoder str
      Nothing -> succeed Nothing
  in
    (get key) `andThen` decode

-- Decodes json and handles parse errors
fromJson : Json.Decoder value -> String -> Task Error (Maybe value)
fromJson decoder str =
  case Json.decodeString decoder str of
    Ok v -> succeed (Just v)
    Err msg -> fail (UnexpectedPayload msg)

{-|

Sets the string value for a given key and passes through the string value as
the task result for chaining. Task will fail with NoStorage if localStorage is
not available in the browser:

    port setStorage : Signal (Task LocalStorage.Error String)
    port setStorage =
      Signal.map (LocalStorage.set storageKey) someStringSignal

-}
set : String -> String -> Task Error String
set =
  Native.LocalStorage.set 

{-|

Removes the value for a given key and passes through the string key as the
task result for chaining. Task will fail with NoStorage if localStorage is
not available in the browser:

    port removeStorage : Signal (Task LocalStorage.Error String)
    port removeStorage =
      Signal.map (LocalStorage.remove storageKey) someStringSignal

-}
remove : String -> Task Error String
remove key =
  Native.LocalStorage.remove
