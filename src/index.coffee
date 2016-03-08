synAuth =
  pubsub:
    channel:
      factory: require( './lib/pubsub/channel-factory' )
    Channel: require( './lib/pubsub/channel' )

module.exports = synAuth
