//import Maybe, Native.Scheduler //

var _w0rm$elm_flatris$Native_LocalStorage = function() {

  function get (key) {
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
      var value = localStorage.getItem(key);
      return callback(_elm_lang$core$Native_Scheduler.succeed(
        (value === null) ? _elm_lang$core$Maybe$Nothing : _elm_lang$core$Maybe$Just(value)
      ));
    });
  }

  function set (key, value) {
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
      localStorage.setItem(key, value);
      return callback(_elm_lang$core$Native_Scheduler.succeed(value));
    });
  }

  function remove (key) {
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
      localStorage.removeItem(key);
      return callback(_elm_lang$core$Native_Scheduler.succeed(key));
    });
  }

  function storageFail () {
    return _elm_lang$core$Native_Scheduler.nativeBinding(function(callback) {
      return callback(_elm_lang$core$Native_Scheduler.fail({ctor: 'NoStorage'}));
    });
  }

  if ('object' !== typeof localStorage) {
    return {
      get: storageFail,
      set: storageFail,
      remove: storageFail
    };
  }

  return {
    get: get,
    set: F2(set),
    remove: remove
  };


}();
