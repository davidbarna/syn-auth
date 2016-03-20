describe 'syn-auth.Session', ->

  auth = require( 'src/' )

  beforeEach ->
    @sinon = sinon.sandbox.create()
    @instance = new auth.Session()

  afterEach ->
    @sinon.restore()

  describe '#expiresIn', ->

    beforeEach ->
      @expiration = Date.now() + ( 60 * 20 * 1000 )
      @instance.expiresIn ( 60 * 20 )

    it 'should set expiration date according to given time lapse', ->
      @instance.expiration().toString().should.equal new Date( @expiration ).toString()
