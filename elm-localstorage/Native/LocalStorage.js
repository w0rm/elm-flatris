Elm.Native.LocalStorage = {};
Elm.Native.LocalStorage.make = function(localRuntime) {

  localRuntime.Native = localRuntime.Native || {};
  localRuntime.Native.LocalStorage = localRuntime.Native.LocalStorage || {};
  if (localRuntime.Native.LocalStorage.values)
  {
    return localRuntime.Native.LocalStorage.values;
  }

  var Maybe = Elm.Maybe.make(localRuntime);
  var Task = Elm.Native.Task.make(localRuntime);

  function get(key)
  {
    var value = localStorage.getItem(key);
    return Task.succeed((value === null) ? Maybe.Nothing : Maybe.Just(value));
  }

  function set(key, value)
  {
    localStorage.setItem(key, value);
    return Task.succeed(value);
  }

  function remove(key)
  {
    localStorage.removeItem(key);
    return Task.succeed(key);
  }

  function storageFail() {
    return Task.fail({ ctor: 'NoStorage' });
  }

  if ('object' !== typeof localStorage) {
    return localRuntime.Native.LocalStorage.values = {
      get: storageFail,
      set: storageFail,
      remove: storageFail
    };
  }

  return localRuntime.Native.LocalStorage.values = {
    get: get,
    set: F2(set),
    remove: remove
  };
};