###
 * User
 *
 * Object to handle user related data
###
class User

  Locale = require( './locale' )
  getOrSet = require( './get-or-set' )

  # Image to return in cae no avatar is defined
  AVATAR = 'data:image/gif;base64,R0lGODlhAQABAAAAACH5BAEKAAEALAAAAAABAAEAAAICTAEAOw=='

  ###*
   * @constructor
   * @param {string} username
   * @param {string} name
  ###
  constructor: ( username, name ) ->
    @avatar( AVATAR )
    @username( username )
    @name( name )

  ###
   * Username getter/setter
   * @param {string} username
  ###
  username: ( username ) ->
    return getOrSet( this, '_username', username )

  ###
   * Password getter/setter
   * @param {string|this} password
  ###
  password: ( password ) ->
    return window.atob( @_password ) if typeof password is 'undefined'
    @_password = window.btoa( password )
    return this

  ###
   * Name getter/setter
   * @param {string} name
  ###
  name: ( name ) ->
    return getOrSet( this, '_name', name )

  ###
   * Avatar getter/setter
   * @param {string} avatar Image url of base64 encode data
  ###
  avatar: ( avatar ) ->
    return getOrSet( this, '_avatar', avatar )

  ###
   * Locale getter/setter based on country and lang
   * @param  {string} lang
   * @param  {string} country
   * @return {Locale|this}
  ###
  locale: ( lang, country ) ->
    return getOrSet( this, '_locale', lang, ->
      return new Locale( lang, country )
    )



module.exports = User
