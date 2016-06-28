angular = require( 'angular-bsfy' )

window.syn ?= {}
window.syn.core ?= require( 'syn-core' )

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
    InterceptorManager: require( './lib/resource/interceptor/manager' ).InterceptorManager
    XHRCache: require( './lib/resource/interceptor/modules/xhr-cache' ).XHRCache
  session:
    factory: require( './lib/session/factory' )
    global: require( './lib/session/global' )
  Session: require( './lib/session' )
  User: require( './lib/user' )
  Locale: require( './lib/locale' )
  i18n: require('syn-core').i18n.getInstance( 'syn-auth' )

synAuth.i18n.translations( 'en', require( './config/i18n-en-us' ).translations )
synAuth.i18n.translations( 'es', require( './config/i18n-es-es' ).translations )

window.syn.auth ?= synAuth

module.exports = synAuth
