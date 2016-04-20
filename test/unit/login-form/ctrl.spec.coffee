describe 'syn-auth.<syn-auth-login-form />.ctrl', ->

  $ = require( 'jqlite' )
  Promise = require( 'bluebird' )
  Ctrl = require( 'src/login-form/ctrl' )
  tpl = require( 'src/login-form/tpl' )
  auth = require( 'src/index.bundle' )
  core = require( 'syn-core' )
  Auth = auth.resource.Auth.prototype
  factory = core.pubsub.channel.factory

  beforeAll ->
    @sinon = sinon.sandbox.create()
    @elem = document.createElement( 'DIV' )
    @elem.innerHTML = require( 'src/login-form/tpl' )()
    document.body.appendChild( @elem )

    @instance = new Ctrl( $( @elem ) )
    @instance.init()
    @instance.render = ->

  afterAll ->
    document.body.removeChild( @elem )
    @instance.destroy()
    @elem = @instance = null

  afterEach ->
    @sinon.restore()

  describe '#setChannel', ->

    beforeEach ->
      @sinon.spy factory, 'create'
      @instance.setChannel( 'my-channel' )

    it 'should create pubsub channel', ->
      factory.create.should.have.been.calledOnce
      factory.create.should.have.been.calledWith 'my-channel'

  describe '#setUrl', ->

    beforeEach ->
      @sinon.stub Auth, 'setUrl'
      @instance.setUrl( 'fake-url' )

    it 'should set url on auth service', ->
      Auth.setUrl.should.have.been.calledOnce
      Auth.setUrl.should.have.been.calledWith 'fake-url'

  describe '#login', ->

    beforeEach ->
      @deferred = new Promise( ( resolve , reject ) =>
        @resolve = resolve
        @reject = reject
      )
      @sinon.stub Auth, 'login'
        .returns @deferred

      @result = @instance.login( 'fake-user', 'fake-pass' )

    it 'should set loading mode', ->
      @instance._elem.hasClass( Ctrl::LOADING_CLASS ).should.equal true

    it 'should call auth service', ->
      Auth.login.should.have.been.called

    describe 'when login is successfull', ->

      beforeEach ->
        @sinon.stub @instance, 'showUserCard'
        @sinon.stub @instance._pubsub.success, 'publish'
        @session = user: -> 'my-user'
        @resolve( @session )

      it 'should publish success event and show user card', ( done ) ->
        @result.then ( user ) =>
          @instance._pubsub.success.publish.should.have.been.calledWith @session
          @instance.showUserCard.should.have.been.calledWith 'my-user'
          done()
          return null

    describe 'when an error is thrown', ->

      beforeEach ->
        @sinon.spy @instance, 'handleErrors'
        @reject( new Error( 'my-fake-error' ) )

      it 'should handle it', ( done ) ->
        @result.then =>
          @instance.handleErrors.should.have.been.called
          @instance.handleErrors.args[0][0].message.should.equal 'my-fake-error'
          done()
          return null

      it 'should remove loading mode', ( done ) ->
        @result.then =>
          @instance._elem.hasClass( Ctrl::LOADING_CLASS ).should.equal false
          done()
          return null

  describe '#handleErrors', ->

    beforeEach ->
      @sinon.stub @instance, 'toggleErrors'
      @instance.handleErrors( new Error() )

    it 'should call toggle errors with corresponding message', ->
      @instance.toggleErrors.should.have.been.calledOnce
      @instance.toggleErrors.should.have.been
        .calledWith 'Unknown error connecting to the server.'

  describe '#toggleErrors', ->

    beforeAll ->
      sinon.stub @instance, 'render'
      sinon.stub @instance._pubsub.error, 'publish'
      @instance.toggleErrors( 'fake-message' )

    it 'should publish error event', ->
      @instance._pubsub.error.publish.should.have.been.calledWith 'fake-message'

    it 'should show errors element', ->
      @instance._elem.hasClass( Ctrl::ERRORS_CLASS ).should.equal true

    it 'should render the view with the message', ->
      @instance.render.should.have.been.called
      @instance.render.args[0][0].errors.should.equal 'fake-message'

    describe '#toggleErrors', ->

      beforeAll ->
        @instance.toggleErrors( '' )

      it 'should hide errors element', ->
        @instance._elem.hasClass( Ctrl::ERRORS_CLASS ).should.equal false

  describe '#showUserCard', ->

    beforeAll ->
      @instance.render.reset()
      @instance.showUserCard( 'fake-user' )

    it 'should show user card element', ->
      @instance._elem.hasClass( Ctrl::SUCCESS_CLASS ).should.equal true

    it 'should render the view with user data', ->
      @instance.render.should.have.been.called
      @instance.render.args[0][0].user.should.equal 'fake-user'

  describe '#destroy', ->

    beforeAll ->
      sinon.stub @instance._form, 'off'
      sinon.stub @instance._close, 'off'
      sinon.stub @instance._pubsub, 'destroy'
      @instance.destroy()

    it 'should unregister al events', ->
      @instance._pubsub.destroy.should.have.been.calledOnce
      @instance._close.off.should.have.been.calledWith 'click'
      @instance._form.off.should.have.been.calledWith 'submit'
