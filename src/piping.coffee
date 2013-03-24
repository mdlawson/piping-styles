path = require "path"
fs = require "fs"
colors = require "colors"
chokidar = require "chokidar"

options =
  ignore: /(\/\.|~$)/ 
  watch: true
  minify: false
  build:
    ".styl": (file,code,fn) ->
      try
        stylus = require "stylus"
        s = stylus(code).set("filename",file)
        try
          s.use(require("nib")())
        catch e
        s.render (err,css) ->
          if err then console.log "[piping-styles]".bold.magenta,"Error compiling",path.relative(process.cwd(),file),err
          else fn css
      catch e
        console.log "[piping-styles]".bold.magenta,"Stylus module not found, can't build stylus files"


module.exports = (ops,out) ->
  if (typeof ops is "string" or ops instanceof String) and (typeof out is "string" or out instanceof String)
    options.main = ops
    options.out = out
  else
    options[key] = value for key,value of ops when key isnt "build"
    if ops.build 
      options.build[key] = value for key,value of ops.build

  basedir = path.dirname module.parent.filename
  main = path.resolve basedir,options.main
  out = path.resolve basedir,options.out

  watcher = chokidar.watch path.dirname(main),
    ignored: options.ignore
    ignoreInitial: true
    persistent: true

  build = (i, o) ->
    type = path.extname i
    if options.build[type]
      start = Date.now()
      code = fs.readFileSync(i,"utf8")
      options.build[type](i,code, (data) ->
        fs.writeFileSync(o,data)
        console.log "[piping-styles]".bold.magenta,"Built in",Date.now()-start,"ms"
      )

  watcher.on "change", (file) ->
    unless options.watch then return 
    console.log "[piping-styles]".bold.magenta,"File",path.relative(process.cwd(),file),"has changed, rebuilding"
    build main,out

  if options.vendor and options.vendor.files.length and options.vendor.out and options.vendor.path
    files = []
    for file in options.vendor.files
      files.push path.resolve basedir,options.vendor.path,file
    vendor = chokidar.watch files,
      ignored: options.ignore
      ignoreInitial: true
      persistent: true

    vendorBuild = (files,out) ->
      start = Date.now()
      css = ""
      for file in files
        css += fs.readFileSync(file,"utf8") + "\n"
      fs.writeFileSync path.resolve(basedir,out),css
      console.log "[piping-styles]".bold.magenta,"Vendor built in",Date.now()-start,"ms"

    vendor.on "change", (file) ->
      unless options.watch then return
      console.log "[piping-styles]".bold.magenta,"File",path.relative(process.cwd(),file),"has changed, rebuilding vendor"
      vendorBuild files,options.vendor.out
    vendorBuild files,options.vendor.out

  build main,out

