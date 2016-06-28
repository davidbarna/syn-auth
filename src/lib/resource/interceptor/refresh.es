/**
 * Client request/response interceptor
**/
import {pubsub} from 'syn-core'

const MAX_ATTEMPTS = 2
const REFRESH_URL = 'http://dev-api.grupoareas.com/stocks/v1.0/refresh'

let tokenRefresherSingletonInstance = null

// window.setTimeout(function () {
//   console.log('error request')
//   // const LOGIN_URL = 'http://dev-api.grupoareas.com/stocks/v1.0/login'
//   // let auth = new window.syn.auth.resource.Auth(LOGIN_URL)

//   // auth.login('dalmeida', 'bla')
//   // .then((req) => {

//   // })
//   const URL = 'http://dev-api.grupoareas.com/stocks/v1.0/logins'
//   let retryReq = new window.syn.auth.resource.Client(URL)
//   return retryReq.request('POST', {
//     headers: {
//       Authorization: 'Basic ' + window.btoa('dalmeida:no')
//     }
//   })
// }, 10000)

/**
 * Adds the necessary interceptor for 419 response codes.
 * Will try to refresh the token and retries the last request
 * if it's successfully refreshed
 * @return {Promise}
**/
export function enable () {
  var tokenRefresher = new TokenRefresher()
  if (tokenRefresher.isEnabled()) {
    return
  }
  tokenRefresher.enable()
  let eventPublisher = pubsub.channel.factory.create('interceptors', ['add'])
  eventPublisher.add.publish({
    'response': function (req, resolve, reject) {
      // Response code is 419: Session expired.
      if (req.target && req.target.status === 419) {
        tokenRefresher.onSessionExpired(req, resolve, reject)
      } else {
        tokenRefresher.resetAttempts()
        return resolve(req)
      }
    }
  })
}

class TokenRefresher {

  /**
   * @return {Promise}
  **/
  constructor () {
    if (tokenRefresherSingletonInstance) {
      return tokenRefresherSingletonInstance
    }

    this.resetAttempts()
    this._addEventsListeners()

    this.xhrCache = new window.syn.auth.resource.XHRCache()
      .enable()
    tokenRefresherSingletonInstance = this
  }

  /**
   * Returns true if the user has checked the login's remember me checkbox
   * @returns {boolean}
  **/
  isRememberActive () {
    return !!this.session && !!this.session.user() && this.session.user().remember()
  }

  /**
   * Listen to session changes
  **/
  _addEventsListeners () {
    // this._pubsub = pubsub.channel.factory.create('dashboard-login', ['success'])
    // this._pubsub.success.subscribe((session) => {
    //   this.session = session
    // })

    let gSession = window.syn.auth.session.global
    debugger
    // if (!gSession.get()) {
    //   document.href.location = '/login-page'
    // }
    gSession.on(gSession.CHANGE, (session) => {
      console.log('session: ')
      this.session = session
    })
    // this._pubsub = pubsub.channel.factory.create(session.CHANGE, ['success'])
    // this._pubsub.success.subscribe((session) => {
    //   debugger
    //   this.session = session
    // })
  }

  /**
   * Deep deleting the session object
  **/
  _clearSession () {
    let gSession = window.syn.auth.session.global
    gSession.clear()
    document.href.location = '/login-page'
    // let keys = Object.keys(this.session)
    // for (let key in keys) {
    //   delete this.session[key]
    // }
    // this.session = null
  }

  resetAttempts () {
    this.attempts = 0
  }

  enable () {
    this._enabled = true
  }

  isEnabled () {
    return this._enabled
  }

  /**
   * @param {Object} opts Options
   * @param {string} opts.token
   * @param {string} opts.refresh_token
   * @param {number} opts.expires_in
   * @TODO Emit change event?
   * @returns {PersistentSession}
  **/
  updateToken (opts = {}) {
    if (!this.session) return
    this.session.token(opts.access_token)
    this.session.expiresIn(opts.expires_in)
    this.session.refreshToken(opts.refresh_token)
  }

  /**
   * Does the API call which will refresh the token
   * @returns {Promise}
  **/
  refreshTokenRequest () {
    let refreshReq = new window.syn.auth.resource.Client(REFRESH_URL)
    let refreshToken = this.session.refreshToken()
    let opts = {
      headers: {
        'token': refreshToken
      },
      noXHRCache: true
    }

    return refreshReq.post(opts)
  }

  /**
   * Does a XMLHttpRequest based on the data passed as param
   * @param {Object} data
   * @return {Promise}
  **/
  retryRequest (data) {
    if (!data) {
      return
    }
    let url = data.url
    let method = data.method
    let options = data.options
    let retryReq = new window.syn.auth.resource.Client(url)
    console.log('retry')
    options = {
      headers: {
        'Authorization': 'Basic ' + window.btoa('dalmeida:areas')
      }
    }
    return retryReq.request(method, options)
  }

  onSessionExpired (req, resolve, reject) {
    this.attempts++
    if (this.attempts === MAX_ATTEMPTS) {
      this._clearSession()
    } else if (this.isRememberActive()) {
      let self = this
      let lastXhrData = this.xhrCache.getData()
      this.refreshTokenRequest()
      .then(function (refreshResponse) {
        self.updateToken(refreshResponse.token)
        return self.retryRequest(lastXhrData)
      })
      .catch(function (error) {
        reject(error)
      })
    }
  }
}
