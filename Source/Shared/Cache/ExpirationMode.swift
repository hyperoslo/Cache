/// Sets the expiration mode for the `CacheManager`. The default value is `.auto` which means that `Cache`
/// will handle expiration internally. It will trigger cache clean up tasks depending on the events its receives
/// from the application. If expiration mode is set to manual, it means that you manually have to invoke the clear
/// cache methods yourself.
///
/// - auto: Automatic cleanup of expired objects (default).
/// - manual: Manual means that you opt out from any automatic expiration handling.
public enum ExpirationMode {
  case auto, manual
}
