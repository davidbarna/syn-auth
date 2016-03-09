###
 * AuthResource
 *
 * Resource able to request tokens with basic auth.
 * For now it only handles a single response format and should
 * implement a strategy in a future.
 *
 * Example of use:
 *
 * ```coffeescript
 * auth = new AuthResource( 'http://mydomain.com/login' )
 * auth.login( 'username', 'password' )
 * 	.then ( session ) ->
 * 		console.log( 'Welcome ' + session.user().name() + '!' )
 * 	.catch ( error ) ->
 * 		console.log( 'login error', error.message, error.status )
 * ```
###
class AuthResource

  Promise = require( 'bluebird' )
  ResourceClient = require( './client' )

  ###
   * @constructor
   * @param  {string} url Url of server's service (must be absolute url)
  ###
  constructor: ( url ) ->
    @_resource = new ResourceClient( url )

  ###
   * Sets url of server's service
   * @param {string} url Must be absolute url
   * @return {this}
  ###
  setUrl: ( url ) -> @_resource.setUrl( url )

  ###
   * Posts basic auth to server and returns parsed session object
   * @param  {string} username
   * @param  {string} password
   * @return {Session}
  ###
  login: ( username, password ) ->
    new Promise ( resolve, reject ) =>
      hash = window.btoa( "#{username}:#{password}" )
      opts = headers: 'Authorization': "Basic #{hash}"

      resolve(
        @_resource.post( opts )
          .then ( response ) ->
            factory = require( '../../lib/session/factory' )
            session = factory.createFromAuthResponse( response )
            session.user()
              .username( username )
              .password( password )
            return session
      )

module.exports = AuthResource
