# Elm Pages Editor

## How to start the build

Unzip the archive and move to the build folder. From there
```
$ python -m SimpleHTTPServer 8080
```

or, in alternative

```
$ mkdir ~/.npm-global
$ npm config set prefix '~/.npm-global'
$ export PATH=~/.npm-global/bin:$PATH
$ npm install http-server -g
$ http-server . -o --push-state
```

and then visit [http://localhost:8080/](http://localhost:8080/)
