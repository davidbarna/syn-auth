describe '<syn-auth-login-form />', ->

  ERRORS_CLASS = 'syn-form_errors'

  inputs = element.all( By.tagName('input') )
  elements =
    demo1:
      errors: element.all( By.className( ERRORS_CLASS ) ).get(0)
      username: inputs.get(1)
      password: inputs.get(2)
      submit: element.all( By.tagName('button') ).get(0)
      rememberMe: element.all( By.className( 'syn-login_remember-me' ) ).get( 0 )
      stayLoggedIn: element.all( By.className( 'syn-login_stay-logged-in' ) ).get( 0 )
    demo2:
      rememberMe: element.all( By.className( 'syn-login_remember-me' ) ).get( 1 )
      stayLoggedIn: element.all( By.className( 'syn-login_stay-logged-in' ) ).get( 1 )

  beforeAll ->
    browser.get( '/docs/' )


  describe 'when users submits the form', ->

    beforeAll ->
      elements.demo1.username.sendKeys( 'fake-user' )
      elements.demo1.password.sendKeys( 'fake-password' )
      elements.demo1.submit.click()
      browser.wait( ->
        elements.demo1.errors.getText().then (text) ->
          return text isnt ''
      , 3000)

    it 'should show the remember me checkbox unchecked', ->
      expect( elements.demo1.rememberMe.isDisplayed() ).toEqual true
      expect( elements.demo1.stayLoggedIn.getAttribute( 'checked' ) ).toEqual null

    it 'should display error message in the UI', ->
      expect( elements.demo1.errors.getText() )
        .toEqual 'Service unavailable. Try again later.'

    it 'should publish "error" event with the message', ->
      browser.manage().logs().get('browser').then ( browserLog ) ->
        log = browserLog.pop()
        expect( log.message )
          .toContain( 'Error: Service unavailable. Try again later.' )

    describe 'when users clicks or focus on any field', ->

      beforeAll ->
        elements.demo1.username.click()
        browser.wait(
          protractor.until.elementIsNotVisible( elements.demo1.errors )
        , 3000)

      it 'should hide errors message', ->
        expect( elements.demo1.errors.isDisplayed() ).toEqual false

  describe 'when stay-logged-in option was set to true', ->

    it 'should show the remember me checkbox checked', ->
      expect( elements.demo2.rememberMe.isDisplayed() ).toEqual false
      expect( elements.demo2.stayLoggedIn.getAttribute( 'checked' ) ).toEqual 'true'
