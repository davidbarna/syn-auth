angular = require( 'angular-bsfy' )

synAuth =
  angular:
    getModule: ->
      ngModule = angular.module( 'syn-auth-demo', [] )
      ngModule
        .directive( 'synAuthLoginForm', require( './login-form/ng-directive' ) )
  getOrSet: require( './lib/get-or-set' )
  resource:
    Client: require( './lib/resource/client' )
    Auth: require( './lib/resource/auth' )
    Url: require( './lib/resource/url' )
  session:
    factory: require( './lib/session/factory' )
    global: require( './lib/session/global' )
  Session: require( './lib/session' )
  User: require( './lib/user' )
  Locale: require( './lib/locale' )


window.syn ?= {}
window.syn.auth ?= synAuth
window.syn.core ?= require( 'syn-core' )

module.exports = synAuth
