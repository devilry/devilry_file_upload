fs = require('fs')
path = require('path')
less = require('less')
{print} = require('sys')
{spawn} = require('child_process')


coffeeSourceDir = 'src'
coffeeBuildDir = 'js'
lessDir = 'less'
cssDir = 'css'
lessFiles = ['widgets.less']
lessImportPath = [lessDir]


logError = (args...) ->
    console.error('[ERROR]', args...)


coffee = (options, onError=null, onSuccess=null) ->
    coffee = spawn 'coffee', options
    coffee.stderr.on 'data', (data) ->
        process.stderr.write data.toString()
    coffee.stdout.on 'data', (data) ->
        print data.toString()
    coffee.on 'exit', (code) ->
        if code == 0
            if onSuccess?
                onSuccess()
        else
            if onError
                onError(code)

coffeeBuildAll = (onSuccess) ->
    coffee(['-c', '-o', coffeeBuildDir, coffeeSourceDir]
        , (code) ->
            logError('Coffescript build FAILED with exit-code:', code)
        , ->
            console.log 'Built all coffescript successfully.'
            if onSuccess?
                onSuccess()
    )

task 'coffeeBuild', 'Build the coffeescript sources.', ->
    coffeeBuildAll()

task 'coffeeWatch', 'Watch the coffeescript sources for changes, and rebuild automatically.', ->
    coffee(['-o', coffeeBuildDir, '-cw', coffeeSourceDir])



lessBuild = (lessfilepath, compress=false, onSuccess=null) ->
    options = {
        compress: compress
    }
    suffix = '.css'
    if compress
        suffix = '.min.css'
    cssfilepath = path.join(cssDir, path.basename(lessfilepath, '.less') + suffix)
    parser = new(less.Parser)({
        paths: lessImportPath # Specify search paths for @import directives
        filename: path.basename(lessfilepath) # Specify a filename, for better error messages
    })

    lessdata = fs.readFileSync(lessfilepath, 'utf-8')
    parser.parse lessdata, (error, tree) ->
        if error
            logError "Could not build #{lessfilepath}: ", error
        else
            css = tree.toCSS(options)
            fs.writeFile cssfilepath, css, (error) ->
                if error
                    throw error
                console.log "[less compile] #{lessfilepath} => #{cssfilepath}"
                if onSuccess?
                    onSuccess()

        
    

lessBuildAll = (compress, onSuccess=null) ->
    count = 0
    for filename in lessFiles
        lessBuild path.join(lessDir, filename), compress, ->
            count += 1
            if count == lessFiles.length
                if onSuccess?
                    onSuccess()


lessBuildOnChange = ->
    fs.watch lessDir, { persistent: true }, (event, filename) ->
        console.log event, filename
        console.log '[LESS changed]', filename
        setImmediate ->
            lessBuildAll()

task 'lessWatch', 'Watch for changes to the less sources, and rebuild when needed.', ->
    lessBuildAll()
    lessBuildOnChange()

task 'lessBuild', 'Build the configured .less files', ->
    lessBuildAll()

task 'lessBuildCompress', 'Build the configured .less files compressed.', ->
    lessBuildAll(true)


task 'productionBuild', 'Build coffeescript and less files', ->
    lessBuildAll false, ->
        console.log 'Built all less sources successfully to UNCOMPRESSED css.'
        lessBuildAll true, ->
            console.log 'Built all less sources successfully to COMPRESSED css.'
            coffeeBuildAll()
