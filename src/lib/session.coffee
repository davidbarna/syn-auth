###
 * Session
 *
 * Object to handle session related data
###
class Session

  getOrSet = require( './get-or-set' )

  ###
   * @param  {User} user
   * @return {User}
  ###
  user: ( user ) ->
    return getOrSet( this, '_user', user )

  ###
   * @param  {Locale} locale
   * @return {Locale}
  ###
  locale: ( locale ) ->
    return getOrSet( this, '_locale', locale )

  ###
   * @param  {Date} expiration
   * @return {Date}
  ###
  expiration: ( expiration ) ->
    return getOrSet( this, '_expiration', expiration )

  ###
   * @param  {number} expiresIn Expiration time remaining in seconds
   * @return {number}
  ###
  expiresIn: ( expiresIn = 0 ) ->
    date = new Date()
    date.setSeconds( date.getSeconds() + expiresIn )
    @expiration( date )
    return this

  ###
   * @param  {string} token
   * @return {string}
  ###
  token: ( token ) ->
    return getOrSet( this, '_token', token )

  ###
   * @param  {string} refreshToken
   * @return {string}
  ###
  refreshToken: ( refreshToken ) ->
    return getOrSet( this, '_refreshToken', refreshToken )

  ###
   * @param  {string} ticket
   * @return {string}
  ###
  ticket: ( ticket ) ->
    return getOrSet( this, '_ticket', ticket )



module.exports = Session
