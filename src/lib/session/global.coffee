storage = window.localStorage

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
  factory = require( './factory' )
  data = JSON.parse( data )
  return factory.createFromSerializedData( data )


sessionGlobal =

  ###
   * Session namespace in storage
   * @type {String}
  ###
  NAMESPACE: 'auth.session.global'

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
    return this

  ###
   * Removes session from storage
  ###
  clear: ->
    storage.removeItem( @NAMESPACE )
    @_session = null
    return this


module.exports = sessionGlobal
