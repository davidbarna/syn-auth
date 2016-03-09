describe 'syn-auth.Locale', ->

  auth = require( 'src/' )

  beforeEach ->
    @sinon = sinon.sandbox.create()
    @instance = new auth.Locale()

  afterEach ->
    @sinon.restore()

  describe '#language', ->

    beforeEach ->
      @instance.language 'ES'

    it 'should set language to lowercase', ->
      @instance.language().should.equal 'es'

  describe '#country', ->

    beforeEach ->
      @instance.country 'mx'

    it 'should set country to uppercase', ->
      @instance.country().should.equal 'MX'
