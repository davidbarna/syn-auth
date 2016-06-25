describe 'syn-auth.resource.Auth', ->

  USERNAME = 'fake-username'
  PASSWORD = 'fake-pass'

  FAKE_RESPONSE =
    settings:
      fullName: 'Fake User'
      language: 'en'
      country: 'us'
    token:
      access_token: null
      refresh_token: null
      expires_in: 0

  Promise = require( 'bluebird' )
  auth = require( 'src/index.bundle' )
  Client = auth.resource.Client.prototype

  beforeEach ->
    @sinon = sinon.sandbox.create()
    @sinon.useFakeServer()
    @instance = new auth.resource.Auth( 'https://test.domain.com:8080/login' )

  afterEach ->
    @sinon.restore()

  describe '#login', ->

    beforeEach ->
      @sinon.stub( Client, 'post' ).returns Promise.resolve( FAKE_RESPONSE )
      @sinon.spy( auth.User.prototype, 'password' )
      @sinon.spy( auth.User.prototype, 'username' )
      @result = @instance.login( USERNAME, PASSWORD )
      @sinon.server.respond()

    it 'should call post on service with correct header', ->
      Client.post.should.have.been.calledOnce
      headers = Client.post.getCall(0).args[0].headers
      headers.should.exist
      headers.Authorization.should.exist
      headers.Authorization
        .should.equal 'Basic ' + window.btoa( "#{USERNAME}:#{PASSWORD}" )

    it 'should resolve promise with response object', ( done ) ->
      @result.then ( session ) ->
        session.should.be.instanceOf auth.Session
        session.user().username().should.equal USERNAME
        done()
        return session

    it 'should set username and password of session', ( done ) ->
      @result.then ( session ) ->
        auth.User::password.should.have.been.calledWith PASSWORD
        auth.User::username.should.have.been.calledWith USERNAME
        done()
        return session
