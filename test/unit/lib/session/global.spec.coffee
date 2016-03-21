describe 'syn-auth.session.global', ->

  storage = window.localStorage
  auth = require( 'src/' )
  NAMESPACE = auth.session.global.NAMESPACE
  session = auth.session.factory.createFromAuthResponse(
    settings:
      country: 'mx'
      language: 'ES'
      fullName: 'Fake User'
    token:
      expires_in: 60 * 60
      refresh_token: 'fake-refresh-token'
      access_token: 'fake-access-token'
  )

  beforeEach ->
    @sinon = sinon.sandbox.create()

  afterEach ->
    @sinon.restore()
    auth.session.global.clear()

  describe '#set', ->

    beforeEach ->
      auth.session.global.set( session )

    it 'should persist session on localStorage', ->

      storage.getItem( NAMESPACE ).should.be.defined
      storage.getItem( NAMESPACE ).should.contain '"_name":"Fake User"'

    it 'should cache session', ->
      auth.session.global._session.should.deep.equal session

  describe '#get', ->

    beforeEach ->
      auth.session.global.set( session )

    it 'should return expected session object', ->
      auth.session.global.get().should.deep.equal session

    describe 'when session was cached', ->

      beforeEach ->
        storage.removeItem( NAMESPACE )

      it 'should not try to get session from storage', ->
        auth.session.global.get().should.deep.equal session

  describe '#clear', ->

    beforeEach ->
      auth.session.global.set( session )
      auth.session.global.clear()

    it 'should clear storage and session', ->
      storage.length.should.equal 0
