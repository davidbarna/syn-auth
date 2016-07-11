describe '<syn-auth-login-form />', ->

  ERRORS_CLASS = 'syn-form_errors'

  inputs = element.all( By.tagName('input') )
  elements =
    errors: element.all( By.className( ERRORS_CLASS ) ).get(0)
    username: inputs.get(1)
    password: inputs.get(2)
    submit: element.all( By.tagName('button') ).get(0)
    stayLoggedIn: element.all( By.id( 'stay-logged-in' ) ).get( 0 )

  beforeAll ->
    browser.get( '/docs/' )


  describe 'when users submits the form', ->

    beforeAll ->
      elements.username.sendKeys( 'fake-user' )
      elements.password.sendKeys( 'fake-password' )
      elements.submit.click()
      browser.wait( ->
        elements.errors.getText().then (text) ->
          return text isnt ''
      , 3000)

    it 'should show the remember me checkbox', ->
      expect( elements.stayLoggedIn.isDisplayed() ).toEqual false

    it 'should display error message in the UI', ->
      expect( elements.errors.getText() ).toEqual 'Service unavailable. Try again later.'

    it 'should publish "error" event with the message', ->
      browser.manage().logs().get('browser').then ( browserLog ) ->
        log = browserLog.pop()
        expect( log.message )
          .toContain( 'Error: Service unavailable. Try again later.' )

    describe 'when users clicks or focus on any field', ->

      beforeAll ->
        elements.username.click()
        browser.wait(
          protractor.until.elementIsNotVisible( elements.errors )
        , 3000)

      it 'should hide errors message', ->
        expect( elements.errors.isDisplayed() ).toEqual false
