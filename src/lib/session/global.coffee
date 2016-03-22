###
 * ### SessionGlobal
 * A service set and retrieve a unique session object.
 * It contains set/get functions and clear to delete the session
 * It extends EventEmitter so it can be used to listen to Session.CHANGE
 * event and behaviour according to session data.
 *
 * **Example of use:**
 *
 * ```coffee-script
 * gSession = syn.auth.session.global
 *
 * if !gSession.get()
 *   document.href.location = '/login-page'
 * gSession.on session.CHANGE, ( session ) ->
 *   # Stuff to do whenever session changes
 *
 * ```
###
storage = window.localStorage
EventEmitter = require( 'events' ).EventEmitter

###
 * Serializes session to a storable string
 * @param  {Session} session
 * @return {string} Stringified session
###
serializeSession = ( session ) ->
  JSON.stringify( session )

###
 * Converts stringified session string to
 * an actual Session instance
 * @param  {string} data
 * @return {Session}
###
unserializeSession = ( data ) ->
  return data unless !!data
  factory = require( './factory' )
  data = JSON.parse( data )
  return factory.createFromSerializedData( data )


class PersistentSession extends EventEmitter

  ###
   * Session namespace in storage
   * @type {String}
  ###
  NAMESPACE: 'auth.session.global'

  CHANGE: 'auth.session.global.change'

  ###
   * Cached session to avoid parse from storage everytime
   * @type {Session}
  ###
  _session: null

  ###
   * Gets session from storage
   * @return {Session}
  ###
  get: ->
    return @_session if !!@_session
    data = storage.getItem( @NAMESPACE )
    return unserializeSession( data )

  ###
   * Stores session in storage
   * @param {Session} session
  ###
  set: ( session ) ->
    return @clear() if !session

    serializedSession = serializeSession( session )
    storage.setItem( @NAMESPACE , serializedSession )
    @_session = session
    @emit( @CHANGE, @_session )
    return this

  ###
   * Removes session from storage
  ###
  clear: ->
    storage.removeItem( @NAMESPACE )
    @_session = null
    @emit( @CHANGE, @_session )
    return this



module.exports = new PersistentSession()
