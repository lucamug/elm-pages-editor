# Elm Pages Editor

Inspired by

* elm-logo
* elm-spa-boilerplate
* elm-style-framework
* elm-styleguide-generator

## Usage

To install global packages with npm follow https://docs.npmjs.com/getting-started/fixing-npm-permissions
```
$ mkdir ~/.npm-global
$ npm config set prefix '~/.npm-global'
$ pico ~/.profile
```
add this line in the .profile file
```
$ export PATH=~/.npm-global/bin:$PATH
```
then
```
$ source ~/.profile
```
Now it should be possible to install global npm packages in the folder ~/.npm-global without using `sudo`

## Elm installation
If you don’t have Elm yet:
```
$ npm install -g elm
```

## create-elm-app installation
If you don’t have create-elm-app yet:
```
$ npm install -g create-elm-app
```
then
```
$ cd elm-pages-editor
$ npm start  # To start the local server
```
Then access http://localhost:3000/, and everything should work.

Open the code, in `src`, and poke around!

To build the production version:
```
$ npm run build
```
The production version is built in `build` folder

## Stand alone version

To build a stand alone version of the form (without editor)

```
$ elm-live --output=docs/standalone.js src/Pages/Form.elm --dir=docs --open --debug --pushstate
```

## Sizes

### Lines of code

```
$ cloc src > loc.txt
```

```
-------------------------------------------------------------------------------
Language                     files          blank        comment           code
-------------------------------------------------------------------------------
Elm                              9            419             66           1543
JavaScript                       2             15             27            107
-------------------------------------------------------------------------------
SUM:                            11            434             93           1650
-------------------------------------------------------------------------------
```

### Stand alone pages

```
* elm-live --output=docs/standalone.js src/Pages/Form.elm --dir=docs --pushstate
* elm-live --output=docs/withEditor.js src/Main.elm       --dir=docs --pushstate
* uglifyjs docs/standalone.js --mangle --toplevel --compress > docs/standalone-min.js
* uglifyjs docs/withEditor.js --mangle --toplevel --compress > docs/withEditor-min.js
```

### Regular

* Standalone      825,716 bytes
* WithEditor    1,288,281 bytes

### Uglified

* Standalone     226,145 bytes
* WithEditor     309,322 bytes

### Zipped

* Standalone      55,113 bytes
* WithEditor      71,620 bytes
