###
 * Locale
 * Handles locale config
###
class Locale

  getOrSet = require( './get-or-set' )

  ###
   * @constructor
   * @param  {string} lang    Language ('es', 'en', 'fr', etc)
   * @param  {string} country Country or zone ( 'MX', 'US', 'CA', etc )
  ###
  constructor: ( lang, country ) ->
    @language( lang ) if !!lang
    @country( country ) if !!country

  ###
   * Language getter/setter
   * @param  {string} language Language ('es', 'en', 'fr', etc)
   * @return {this}
  ###
  language: ( language ) ->
    return getOrSet( this, '_language', language, ->
      return language.toLowerCase()
    )

  ###
   * Country getter/setter
   * @param  {string} country Country or zone ( 'MX', 'US', 'CA', etc )
   * @return {this}
  ###
  country: ( country ) ->
    return getOrSet( this, '_country', country, ->
      return country.toUpperCase()
    )



module.exports = Locale
