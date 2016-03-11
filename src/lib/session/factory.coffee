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
    session = new Session()

    return session
      .user new User( null, data.fullName )
      .locale new Locale( data.language, data.country )
      .token response.token.access_token
      .expiresIn response.token.expires_in
      .refreshToken response.token.refresh_token

module.exports = sessionFactory
