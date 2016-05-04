angular = require( 'angular-bsfy' )
synUi = require( 'syn-ui' ).angular.getModule().name

synAuth =
  angular:
    getModule: ->
      ngModule = angular.module( 'syn-auth-demo', [ synUi ] )
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
  i18n: require('syn-core').i18n.getInstance( 'syn-auth' )

synAuth.i18n.translations( 'en', require( './config/i18n-en-us' ).translations )
synAuth.i18n.translations( 'es', require( './config/i18n-es-es' ).translations )

window.syn ?= {}
window.syn.core ?= require( 'syn-core' )
window.syn.auth ?= synAuth

module.exports = synAuth
