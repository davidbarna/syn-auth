synAuth = require('../index')

###
 * # LoginFormCtrl
 * Manages a basic login form.
 * Errors and success are emitted by a pubsub channel.
 *
 * ## Pubsub events
 *
 * **success**
 * Published when login has been sucessfull. User instance passed as param.
 *
 * **error**
 * Published on any error. Error instance passed as param.
 *
 * ## Example of use
 *
 * ```html
 * <syn-auth-login-form url="http://fake.com/login" channel="my-channel" />
 * <script type="text/javascript">
 *   angular.bootstrap( document.body, [ syn.auth.angular.getModule().name ] )
 *   sub = syn.auth.pubsub.channel.factory.create( 'my-channel', [ 'success', 'error' ] );
 *   sub.success.subscribe( function( session ){ console.log( session ); } )
 *   sub.error.subscribe( function( msg ){ console.warn( 'Error: ' + msg ); } )
 * </script>
 * ```
###
class LoginFormCtrl

  # CONSTANTS
  ERRORS_CLASS: 'syn-auth-login-form--error'
  LOADING_CLASS: 'syn-auth-login-form--loading'
  SUCCESS_CLASS: 'syn-auth-login-form--success'

  ###
   * @param  {Event} evt
   * @return {undefined}
  ###
  _submitHandler: ( evt ) =>
    form = evt.target
    @login( form.username.value, form.password.value )
    return

  ###
   * @param  {Event} evt
   * @return {undefined}
  ###
  _closeHandler: ( evt ) =>
    @toggleErrors( '' )
    return

  ###
   * @constructor
   * @param  {DOM Element} @_elem Element attached
  ###
  constructor: ( @_elem ) ->
    @_elem.addClass( 'syn-auth-login-form' )
    @_form = @_elem.find( 'form' )
    @_close = @_elem.find( 'close' )

    @_form.on( 'submit', @_submitHandler )
    @_close.on( 'click', @_closeHandler )

  ###
   * @return {this}
  ###
  init: ->
    @_auth = new synAuth.resource.Auth()
    return this

  ###
   * Set url of login service
   * @param {string} url [description]
   * @return {this}
  ###
  setUrl: ( url ) ->
    @_auth.setUrl( url )
    return this

  ###
   * Creates a channel to receive of emit events
   * @param {string} channelName [description]
   * @return {this}
  ###
  setChannel: ( channelName ) ->
    @_pubsub?.destroy?()
    @_pubsub = synAuth.pubsub.channel.factory.create( channelName, ['success', 'error'] )
    return this

  ###
   * Trys to login and manages errors
   * @param  {string} username
   * @param  {string} password
   * @return {Promise}
  ###
  login: ( username, password ) ->
    # Reset form
    document.activeElement.blur()
    @toggleErrors( '' )
    @_elem.addClass( @LOADING_CLASS )

    @_auth.login( username, password )
      .then ( session ) =>
        @_pubsub?.success.publish( session.user() )
        @showUserCard( session.user() )
      .catch ( e ) =>
        @handleErrors( e )
      .finally =>
        @_elem.removeClass( @LOADING_CLASS )

  ###
   * Error is processed and notified to user
   * @param  {Error} e Error instance
   * @return {undefined}
  ###
  handleErrors: ( e ) ->
    if e.status is 0 or e.status is 404
      msg = 'Service unavailable. Try again later.'
    else if e.status is 401
      msg = 'Authentication failed: wrong user or password.'
    else if e.status is 429
      msg = 'Too many attempts in a given amount of time. Try again soon.'
    else
      msg = 'Unknown error connecting to the server.'

    @toggleErrors( msg )
    return

  ###
   * Shows message as error to user
   * @param  {string} msg
   * @return {undefined}
  ###
  toggleErrors: ( msg ) ->
    @_pubsub?.error.publish( msg ) if !!msg
    @_elem.toggleClass( @ERRORS_CLASS, !!msg )
    @render( errors: msg )
    return

  ###
   * Hides form and show a user info card instead
   * @param  {User} user
   * @return {undefined}
  ###
  showUserCard: ( user ) ->
    @_elem.addClass( @SUCCESS_CLASS )
    @render( user: user )
    return

  ###
   * Unregisters all events
   * @return {undefined}
  ###
  destroy: ->
    @_pubsub?.destroy?()
    @_form.off( 'submit', @_submitHandler )
    @_close.off( 'click', @_closeHandler )
    return



module.exports = LoginFormCtrl
