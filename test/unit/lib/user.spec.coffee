describe 'syn-auth.User', ->

  auth = require( 'src/index.bundle' )

  beforeEach ->
    @sinon = sinon.sandbox.create()
    @instance = new auth.User()

  afterEach ->
    @sinon.restore()

  describe '#password', ->

    beforeEach ->
      @instance.password 'fake-password'

    it 'should save the password encrypted', ->
      @instance._password.should.equal window.btoa( 'fake-password' )

    describe 'when no value is provided', ->

      it 'should return the password', ->
        @instance.password().should.equal 'fake-password'

  describe '#locale', ->

    beforeEach ->
      @instance.locale 'es', 'mx'

    it 'should set Local instance', ->
      @instance.locale().should.be.instanceOf auth.Locale
      @instance.locale().language().should.equal 'es'
      @instance.locale().country().should.equal 'MX'
