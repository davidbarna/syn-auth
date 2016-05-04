# syn-auth
Auth module.

## Getting started

Install the module in a node 4+ environment.
```
$ npm install syn-auth
```

If you are going to use components you can do either options:
* SASS: Add syn-auth sass to your sass
```sass
@import "path/to/node_modules/syn-auth/src/index.scss";
```
* CSS: Add css file to your page
```html
<link type="text/css" href="path/to/node_modules/syn-auth/dest/index.css" />
```

## Services

### AuthResource
A service to authenticate user/pass through a webservice.

**Example of use:**

```coffee-script
auth = new syn.auth.resource.Auth( 'http://my-api.fake/login' )
auth.login( 'my-user', 'my-password' )
  .then ( session ) =>
    console.log 'Welcome ' + session.user().name() + '!!!'
  .catch ( error ) =>
    console.log error
```

### SessionGlobal
A service set and retrieve a unique session object.

**Example of use:**

```coffee-script
gSession = syn.auth.session.global

if !gSession.get()
  document.href.location = '/login-page'
  
gSession.on session.CHANGE, ( session ) ->
  # Stuff to do whenever session changes

```



## Components

### &lt;syn-auth-login-form @url @channel /&gt;
Basic login form.
To see an example, execute the demo:

```
$ gulp serve
```

and open http://localhost:3000/docs/
