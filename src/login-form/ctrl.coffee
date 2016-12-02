synAuth = require('../index')
synCore = require('syn-core')

i18n = synAuth.i18n
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
 *   sub = syn.core.pubsub.channel.factory.create( 'my-channel', [ 'success', 'error' ] );
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
  STAY_LOGGED_IN_FIELD_NAME: 'stay-logged-in'

  ###
   * @param  {Event} evt
   * @return {undefined}
  ###
  _submitHandler: ( evt ) =>
    form = evt.target
    @login(
      form.username.value, form.password.value, form[@STAY_LOGGED_IN_FIELD_NAME].checked
    )
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

    @_form.on( 'submit', @_submitHandler )

    @_lab = @_elem.find( 'form' ).find('label')[0]
    @_lab.addEventListener( 'click', @_recoverPasswordHandler )

    @_inputs = @_elem.find( 'input' )
    for input in @_inputs
      input.addEventListener( 'focus', @_closeHandler )

  ###
   * @return {this}
  ###
  init: ( options = {} ) ->
    @_auth = new synAuth.resource.Auth()

    @render(
      USER: i18n.translate( 'USER' )
      PASSWORD: i18n.translate( 'PASSWORD' )
      ACCESS: i18n.translate( 'ACCESS' )
      COPYRIGHT: i18n.translate( 'COPYRIGHT' )
      REMEMBER_ME: i18n.translate( 'REMEMBER_ME' )
      stayLoggedIn: options.stayLoggedIn
      showRememberMe: !options.stayLoggedIn?
      recoverPassword: @recoverPassword
    )

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
    @_pubsub = synCore.pubsub.channel.factory.create( channelName, ['success', 'error'] )
    return this

  ###
   * Trys to login and manages errors
   * @param  {string} username
   * @param  {string} password
   * @param  {boolean} stayLoggedIn
   * @return {Promise}
  ###
  login: ( username, password, stayLoggedIn = false ) ->
    # Reset form
    document.activeElement.blur()
    @toggleErrors( '' )
    @_elem.addClass( @LOADING_CLASS )

    @_auth.login( username, password, stayLoggedIn )
      .then ( session ) =>
        @_pubsub?.success.publish( session )
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
      msg = i18n.translate 'SERVICE_UNAVAILABLE'
    else if e.status is 401
      msg = i18n.translate 'AUTHENTICATION_FAILED'
    else if e.status is 429
      msg = i18n.translate 'TOO_MANY_ATTEMPTS'
    else
      console.error(e.message)
      msg = i18n.translate 'UNKNOWN_ERROR'

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
    for input in @_inputs
      input.removeEventListener( 'focus', @_handleEventInput )
    return

  ###
   * Call to recover-password component
   * @return {undefined}
  ###
  _recoverPasswordHandler: ->
    console.log("RECOVE RPASSWORD")
    return


module.exports = LoginFormCtrl
