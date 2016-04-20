describe 'syn-auth.session.global', ->

  storage = window.localStorage
  auth = require( 'src/index.bundle' )
  instance = auth.session.global

  NAMESPACE = instance.NAMESPACE
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
    @sinon.stub( instance, 'emit' )
    @sinon.spy( window, 'btoa' )

  afterEach ->
    @sinon.restore()
    instance.clear()

  describe '#set', ->

    beforeEach ->
      instance.set( session )

    it 'should persist session on localStorage', ->
      window.btoa.should.have.been.calledOnce
      window.btoa.args[0][0].should.contain '"_name":"Fake User"'
      storage.getItem( NAMESPACE ).should.be.defined
      storage.getItem( NAMESPACE ).should.be.a 'string'
      storage.getItem( NAMESPACE ).length.should.be.at.least 100

    it 'should cache session', ->
      instance._session.should.deep.equal session

    it 'should launch an event with new session value', ->
      instance.emit.should.have.been.calledOnce
      instance.emit.should.have.been.calledWith( instance.CHANGE, session )

  describe '#get', ->

    beforeEach ->
      instance.set( session )

    it 'should return expected session object', ->
      instance.get().should.deep.equal session

    describe 'when session was cached', ->

      beforeEach ->
        storage.removeItem( NAMESPACE )

      it 'should not try to get session from storage', ->
        instance.get().should.deep.equal session

  describe '#clear', ->

    beforeEach ->
      instance.set( session )
      instance.clear()

    it 'should clear storage and session', ->
      storage.length.should.equal 0

    it 'should launch an event with new session value', ->
      instance.emit.should.have.been.calledTwice
      instance.emit.should.have.been.calledWith( instance.CHANGE, null )
