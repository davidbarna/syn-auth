describe 'syn-auth.getOrSet', ->

  auth = require( 'src/index.bundle' )
  obj = {}

  describe 'when a value is provided', ->

    beforeEach ->
      @result = auth.getOrSet( obj, '_name', 'fake!!' )

    it 'should set the value', ->
      obj._name.should.equal 'fake!!'

    it 'should return object', ->
      @result.should.equal obj

    describe 'when a func is provided', ->

      beforeEach ->
        @result = auth.getOrSet( obj, '_name', 'fake!!', ( value ) ->
          return value.toUpperCase()
        )

      it 'should set the value', ->
        obj._name.should.equal 'FAKE!!'

  describe 'when no value is provided', ->

    beforeEach ->
      @result = auth.getOrSet( obj, '_name' )

    it 'should return the value', ->
      obj._name.should.equal 'FAKE!!'
