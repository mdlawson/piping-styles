# Piping-styles

Similar stuff to [piping](http://github.com/mdlawson/piping) and [piping-browser](http://github.com/mdlawson/piping-browser) but for stylesheets. currently supports stylus with (optional) nib.

## Installation
```
npm install piping-styles
```
## Usage

Piping-styles is not a binary, so you can continue using your current workflow for running your application ("wooo!"). Basic usage is as follows:

```javascript
require("piping-styles")({main:"./client/styles/app.styl",out:"./public/app.css"});
```
### Options

- __main__ _(path)_: The path to your top style
- __out__ _(path)_: The path to where you want your css to be written to. Relative to the file where piping-styles was required
- __ignore__ _(regex)_: Files/paths matching this regex will not be watched. Defaults to `/(\/\.|~$)/`
- __watch__ _(boolean)_: Whether or not piping should rebuild on changes. Defaults to true, could be set to false for production
- __vendor__ _(object)_: Specify configuration for building vendor files. Vendor files are concatenated in order, and written to the given path.
  - __path__ _(string)_: Directory where vendor files are located, relative to file where piping-styles was required
  - __out__ _(string)_: Path where vendor ouput should be written, relative to the file where piping-styles was required
  - __files__ _(array)_: Array of vendor files, relative to vendor path.
- __build__ _(object)_: An object that maps file extensions, eg ".styl" to functions that take a filename, file data, and a callback and compile the source, sending it to the callback.


Piping-styles can also be used just by passing two strings. In this case, the strings are taken as the main and out options
```javascript
require("piping-styles")("./client/styles/app.styl","./public/app.css");
```

piping-styles plays nice with piping. To use it, ensure piping-styles is required when piping returns false:

```javascript
if(!require("piping")()){
  require("piping-styles")("./client/styles/app.styl","./public/app.css");
  return;
}
// application logic here
```