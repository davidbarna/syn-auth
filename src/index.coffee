
angular = require( 'angular-bsfy' )

synAuth =
  angular:
    getModule: ->
      ngModule = angular.module( 'syn-auth-demo', [] )
      ngModule
        .directive( 'synAuthLoginForm', require( './login-form/ng-directive' ) )
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


window.syn ?= {}
window.syn.auth ?= synAuth


module.exports = synAuth
