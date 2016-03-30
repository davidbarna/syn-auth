###
 * Directive config for angular implementation
 * @type {Object}
###
LoginFormDirective =
  scope:
    url: '='
    channel: '@'
  template: require( './tpl' )
  controller: [ '$scope', '$element', '$attrs', ( scope, element, attrs ) ->

    angularify = require( 'dev-tools' ).angularify
    LoginForm = require( './ctrl' )

    ctrl = new LoginForm( element )
    angularify( scope, ctrl )
    scope.$watch( 'url' , ( value ) -> ctrl.setUrl( value) )

    ctrl.init()
      .setUrl( scope.url )
      .setChannel( scope.channel )
  ]

module.exports = -> LoginFormDirective
