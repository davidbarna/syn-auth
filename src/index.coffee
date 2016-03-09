synAuth =
  getOrSet: require( './lib/get-or-set' )
  pubsub:
    channel:
      factory: require( './lib/pubsub/channel-factory' )
    Channel: require( './lib/pubsub/channel' )
  resource:
    Client: require( './lib/resource/client' )
    Auth: require( './lib/resource/auth' )
    Url: require( './lib/resource/url' )
  session:
    factory: require( './lib/session/factory' )
  Session: require( './lib/session' )
  User: require( './lib/user' )
  Locale: require( './lib/locale' )

module.exports = synAuth
