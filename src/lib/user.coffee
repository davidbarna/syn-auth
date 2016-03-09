###
 * User
 *
 * Object to handle user related data
###
class User

  Locale = require( './locale' )
  getOrSet = require( './get-or-set' )

  ###*
   * @constructor
   * @param {string} username
   * @param {string} name
  ###
  constructor: ( username, name ) ->
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
