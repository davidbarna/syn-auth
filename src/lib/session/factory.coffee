User = require( '../user' )
Session = require( '../session' )
Locale = require( '../locale' )

sessionFactory =

  ###
   * Creates a session object according to following data format:
   * token:
   *   expires_in: {number}
   *   refresh_token: {string}
   *   access_token: {string}
   * settings:
   *   country: {string}
   *   language: {string}
   *   fullName: {string}
   *
   * @param  {Object} data
   * @return {Session}
  ###
  createFromAuthResponse: ( response ) ->
    data = response.settings

    return new Session()
      .user new User( null, data.fullName )
      .locale new Locale( data.language, data.country )
      .token response.token.access_token
      .expiresIn response.token.expires_in
      .refreshToken response.token.refresh_token

  ###
   * Converts stringified session object to a
   * Session instance.
   * @param  {Object} data Session passed by JSON.stringify and JSON.parse
   * @return {Session}
  ###
  createFromSerializedData: ( data ) ->
    { _user, _locale } = data

    return new Session()
      .user new User( _user._username, _user._name )
      .locale new Locale( _locale._language, _locale._country )
      .token data._token
      .refreshToken data._refreshToken
      .expiration new Date( data._expiration )

module.exports = sessionFactory
