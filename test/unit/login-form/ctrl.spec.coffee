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
    @elem = document.createElement( 'DIV' )
    @elem.innerHTML = require( 'src/login-form/tpl' )()
    document.body.appendChild( @elem )

  afterAll ->
    document.body.removeChild( @elem )
    @elem = null

  beforeEach ->
    @sandbox = sinon.sandbox.create()
    @instance = new Ctrl( $( @elem ) )
    @instance.render = @sandbox.stub()
    @instance.init()

  afterEach ->
    @sandbox.restore()
    @instance = null

  describe '#init', ->

    beforeEach ->
      @sandbox.stub auth.i18n, 'translate'

      auth.i18n.translate.withArgs( 'USER' ).returns( 'user' )
      auth.i18n.translate.withArgs( 'PASSWORD' ).returns( 'password' )
      auth.i18n.translate.withArgs( 'ACCESS' ).returns( 'access' )
      auth.i18n.translate.withArgs( 'COPYRIGHT' ).returns( '' )
      auth.i18n.translate.withArgs( 'REMEMBER_ME' ).returns( 'access' )

    it 'should call the render passing the translations', ->
      @instance.render.should.have.been.calledWith(
        ACCESS: 'access'
        PASSWORD: 'password'
        USER: 'user'
        COPYRIGHT: 'COPYRIGHT'
        REMEMBER_ME: 'Remember me'
        stayLoggedIn: undefined
        showRememberMe: true
      )

    describe 'when stayLoggedIn option is set to true', ->

      beforeEach ->
        @instance.init( { stayLoggedIn: true } )

      it 'should hide \'Remember Me\' and set checkbox to true', ->
        @instance.render.args[1][0].stayLoggedIn.should.equal true
        @instance.render.args[1][0].showRememberMe.should.equal false

    describe 'when stayLoggedIn option is set to false', ->

      beforeEach ->
        @instance.init( { stayLoggedIn: false } )

      it 'should hide \'Remember Me\' and set checkbox to false', ->
        @instance.render.args[1][0].stayLoggedIn.should.equal false
        @instance.render.args[1][0].showRememberMe.should.equal false

  describe '#setChannel', ->

    beforeEach ->
      @sandbox.spy factory, 'create'
      @instance.setChannel( 'my-channel' )

    it 'should create pubsub channel', ->
      factory.create.should.have.been.calledOnce
      factory.create.should.have.been.calledWith 'my-channel'

  describe '#setUrl', ->

    beforeEach ->
      @sandbox.stub Auth, 'setUrl'
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
      @sandbox.stub Auth, 'login'
        .returns @deferred

      @result = @instance.login( 'fake-user', 'fake-pass' )

    it 'should set loading mode', ->
      @instance._elem.hasClass( Ctrl::LOADING_CLASS ).should.equal true

    it 'should call auth service', ->
      Auth.login.should.have.been.called

    describe 'when login is successfull', ->

      beforeEach ->
        @sandbox.stub @instance, 'showUserCard'
        @session = user: -> 'my-user'
        @instance._pubsub = success: publish: @sandbox.stub()
        @resolve( @session )

      it 'should publish success event and show user card', ( done ) ->
        @result.then ( user ) =>
          @instance._pubsub.success.publish.should.have.been.calledWith @session
          @instance.showUserCard.should.have.been.calledWith 'my-user'
          done()
          return null

    describe 'when an error is thrown', ->

      beforeEach ->
        @sandbox.spy @instance, 'handleErrors'
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
      @sandbox.stub @instance, 'toggleErrors'
      @sandbox.stub auth.i18n, 'translate'

      auth.i18n.translate.withArgs( 'SERVICE_UNAVAILABLE' )
        .returns( 'error #1' )
      auth.i18n.translate.withArgs( 'AUTHENTICATION_FAILED' )
        .returns( 'error #2' )
      auth.i18n.translate.withArgs( 'TOO_MANY_ATTEMPTS' )
        .returns( 'error #3' )
      auth.i18n.translate.withArgs( 'UNKNOWN_ERROR' )
        .returns( 'error #4' )

    it 'should call toggle errors with corresponding message on error 404', ->
      @instance.handleErrors( { status: 404 } )
      @instance.toggleErrors.should.have.been.calledOnce
      @instance.toggleErrors.should.have.been
        .calledWith 'error #1'

    it 'should call toggle errors with corresponding message on error 404', ->
      @instance.handleErrors( { status: 401 } )
      @instance.toggleErrors.should.have.been.calledOnce
      @instance.toggleErrors.should.have.been
        .calledWith 'error #2'

    it 'should call toggle errors with corresponding message on error 404', ->
      @instance.handleErrors( { status: 429 } )
      @instance.toggleErrors.should.have.been.calledOnce
      @instance.toggleErrors.should.have.been
        .calledWith 'error #3'

    it 'should call toggle errors with corresponding message on error 404', ->
      @instance.handleErrors( { status: 'unknown' } )
      @instance.toggleErrors.should.have.been.calledOnce
      @instance.toggleErrors.should.have.been
        .calledWith 'error #4'


  describe '#toggleErrors', ->

    beforeEach ->
      @instance._pubsub = error: publish: @sandbox.stub()
      @instance.render = @sandbox.stub()
      @instance.toggleErrors( 'fake-message' )

    it 'should publish error event', ->
      @instance._pubsub.error.publish.should.have.been.calledWith 'fake-message'

    it 'should show errors element', ->
      @instance._elem.hasClass( Ctrl::ERRORS_CLASS ).should.equal true

    it 'should render the view with the message', ->
      @instance.render.should.have.been.called
      @instance.render.args[0][0].errors.should.equal 'fake-message'

    describe '#toggleErrors', ->

      beforeEach ->
        @instance.toggleErrors( '' )

      it 'should hide errors element', ->
        @instance._elem.hasClass( Ctrl::ERRORS_CLASS ).should.equal false

  describe '#showUserCard', ->

    beforeEach ->
      @instance.render = @sandbox.stub()
      @instance.showUserCard( 'fake-user' )

    it 'should show user card element', ->
      @instance._elem.hasClass( Ctrl::SUCCESS_CLASS ).should.equal true

    it 'should render the view with user data', ->
      @instance.render.should.have.been.called
      @instance.render.args[0][0].user.should.equal 'fake-user'

  describe '#destroy', ->

    beforeEach ->
      @sandbox.stub @instance._form, 'off'
      for input in @instance._inputs
        @sandbox.stub input, 'removeEventListener'
      @instance.render = @sandbox.stub()
      @instance._pubsub = destroy: @sandbox.stub()
      @instance.destroy()

    it 'should unregister al events', ->
      @instance._pubsub.destroy.should.have.been.calledOnce
      @instance._form.off.should.have.been.calledWith 'submit'
      for input in @instance._inputs
        input.removeEventListener.should.have.been.calledWith 'focus'
