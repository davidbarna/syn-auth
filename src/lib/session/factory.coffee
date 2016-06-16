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
    data = response.settings || {}

    return new Session()
      .user new User( null, data.fullName )
      .locale new Locale( data.language, data.country )
      .token response.token.access_token || ''
      .expiresIn response.token.expires_in
      .refreshToken response.token.refresh_token || ''
      .ticket response.ticket or ''

  ###
   * Converts stringified session object to a
   * Session instance.
   * @param  {Object} data Session passed by JSON.stringify and JSON.parse
   * @return {Session}
  ###
  createFromSerializedData: ( data ) ->
    { _user, _locale } = data
    
    session = new Session()
    session.user new User( _user._username, _user._name ) if !!_user
    session.locale new Locale( _locale._language, _locale._country ) if !!_locale
    session.token data._token if !!data._token
    session.refreshToken data._refreshToken if !!data._refreshToken
    session.expiration new Date( data._expiration ) if !!data._expiration
    session.ticket data._ticket if !!data._ticket

    return session

module.exports = sessionFactory
