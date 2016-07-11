###
 * Directive config for angular implementation
 * @type {Object}
###
LoginFormDirective =
  scope:
    url: '='
    channel: '@'
  transclude: true
  template: require( './tpl' )
  controller: [ '$scope', '$element', '$transclude', ( scope, element, trans ) ->

    # The original content of the directive is appended
    trans( (clone, scope) -> element.find('logo').append( clone ) )
    angularify = require( 'syn-core' ).angularify
    LoginForm = require( './ctrl' )

    ctrl = new LoginForm( element )
    angularify( scope, ctrl )
    scope.$watch( 'url' , ( value ) -> ctrl.setUrl( value) )

    ctrl.init()
      .setUrl( scope.url )
      .setChannel( scope.channel )
  ]

module.exports = -> LoginFormDirective
