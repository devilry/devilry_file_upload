###
A general purpose modern (html5) file upload library with fallbacks for older
browsers.
###


applyOptions = (classorfunctionname, options, defaults, required=[]) ->
    result = {}
    for key, value of options
        result[key] = value
    for key, value of defaults
        if not options[key]?
            result[key] = value
    for key in required
        if not result[key]?
            throw "'#{key}' is a required argument for #{classorfunctionname}."
    return result


defer = (func) ->
    setTimeout(func, 0)


dataTransferContainsFiles = (dataTransfer) ->
    for typestring in dataTransfer.types
        if typestring == 'Files'
            return true
    return false



###
Static class with array manipulation utilities.
###
class ArrayUtils

    ###
    The same as ``Array.prototype.indexOf()``, but works on old browsers
    like IE8.
    ###
    @indexOf: (array, item) ->
        if array.indexOf
            return array.indexOf(item)
        else
            for x, i in array
                return i if x is item
            return -1

    ###
    Remove an item from the given array.

    Returns ``null`` if no item was removed, or the item if it was removed.
    ###
    @remove: (array, item) ->
        index = @indexOf(array, item)
        if index == -1
            return null
        else
            array.splice(index, 1)
            return item
        


class ElementWrapper
    attachEventEventMap: {
        click: 'onclick'
        load: 'onload'
    }

    constructor: (@htmlElement) ->

    getTagName: ->
        return @htmlElement.tagName.toLocaleLowerCase()

    isFileField: ->
        return @getTagName() == 'input' and @getAttribute('type') == 'file'

    getAttribute: (name) ->
        return @htmlElement.getAttribute(name)

    setAttribute: (name, value) ->
        return @htmlElement.setAttribute(name, value)

    removeAttribute: (name, value) ->
        return @htmlElement.removeAttribute(name)

    appendChild: (childWrapper) ->
        @htmlElement.appendChild(childWrapper.htmlElement)

    _createRandomId: ->
        while 1
            randomInt = Math.round(Math.random() * 1000000000)
            id = "ElementWrapperItem-#{randomInt}"
            if not document.getElementById(id)?
                return id

    setRandomId: ->
        @setId(@_createRandomId())

    setId: (id) ->
        @htmlElement.id = id

    getId: ->
        return @htmlElement.id

    on: (eventName, callback) ->
        if (@htmlElement.addEventListener)
            @htmlElement.addEventListener(eventName, callback, false)
        else if (@htmlElement.attachEvent)
            if eventName == 'change' and @isFileField()
                @on 'click', (e) =>
                    defer =>
                        if @htmlElement.value? and @htmlElement.value != ''
                            callback.apply(@)
            else
                if eventName of @attachEventEventMap
                    eventName = @attachEventEventMap[eventName]
                @htmlElement.attachEvent(eventName, callback)

    remove: ->
        @htmlElement.parentNode.removeChild(@htmlElement)

    replaceWith: (newElementWrapper) ->
        @htmlElement.parentNode.replaceChild(newElementWrapper.htmlElement, @htmlElement)
        return newElementWrapper

    down: (cssSelector) ->
        htmlElement = @htmlElement.querySelector(cssSelector) #https://developer.mozilla.org/en-US/docs/Web/API/document.querySelector
        if htmlElement?
            return new ElementWrapper(htmlElement)
        else
            return null

    setInnerHtml: (html) ->
        @htmlElement.innerHTML = html



class FileWrapper
    constructor: (@file) ->

    isImage: ->
        return @file.type == 'image/png' or @file.type == 'image/jpeg' or @file.type == 'image/png'

    isText: ->
        return @file.type == 'text/plain'



class BrowserInfo
    #constructor: ->
        #@userAgent = navigator.userAgent.toLocaleLowerCase()

    #isIE: ->
        #return /msie/.test(@userAgent)

    #isIE8: ->
        #return @isIE() && /msie 8/.test(@userAgent)

    supportsXhrFileUpload: ->
        xhr = new XMLHttpRequest()
        return (xhr.upload?) and (typeof(xhr.upload.onprogress) != 'undefined') and (window.FormData?)

    supportsDragAndDropFileUpload: ->
        return @supportsXhrFileUpload()

    logDebugInfo: ->
        console.log 'BrowserInfo logDebugInfo:'
        console.log "   - supportsXhrFileUpload: #{@supportsXhrFileUpload()}"
        console.log "   - supportsDragAndDropFileUpload: #{@supportsDragAndDropFileUpload()}"

browserInfo = new BrowserInfo()



class ObservableResult
    constructor: (options) ->
        @isObservableResult = true
        @abort = options.abort == true
        @remove = options.remove == true


class Observable
    constructor: (options) ->
        {listeners} = options
        if not listeners?
            listeners = {}
        @listeners = {}
        @managedListeners = {}
        for name, callback of listeners
            @on(name, callback)

    on: (name, callback) ->
        if not @listeners[name]?
            @listeners[name] = []
        @listeners[name].push(callback)

    off: (name, callback) ->
        listeners = @listeners[name]
        if not listeners?
            throw "No listeners for '#{name}'."
        if ArrayUtils.remove(listeners, callback) == null
            throw "The given callback is not registered for '#{name}'."

    fireEvent: (name, args...) ->
        listeners = @listeners[name]
        abort = false
        if listeners?
            autoremove = []
            for listener in listeners
                if listener?
                    result = listener.apply(@, args)
                    if result?.isObservableResult
                        if result.abort
                            abort = true
                        if result.remove
                            autoremove.push([name, listener])
            for item in autoremove
                @off(item[0], item[1])
        return abort

                


###
Makes it easy create a short-lived hidden iframe that can be used to get
dynamic form responses without reloading the page.

The frame destroys itself as soon as it has been loaded.
###
class HiddenIframe extends Observable
    constructor: (options) ->
        super(options)
        @iframe = new ElementWrapper(document.createElement('iframe'))
        @iframe.setRandomId()
        @iframe.setAttribute('name', @iframe.getId()) # IE 8 and 9, uses name instead of ID for target
        @iframe.setAttribute('style', 'visibility: hidden; display: none;')
        document.body.appendChild(@iframe.htmlElement)
        @iframe.on('load', @_onLoadIframe)

    _getContentDocument: ->
        return @iframe.htmlElement.contentDocument || @iframe.htmlElement.contentWindow.document

    _getBody: ->
        return @_getContentDocument().getElementsByTagName('body')[0]

    _onLoadIframe: =>
        bodyhtml = @_getBody().innerHTML
        if bodyhtml? and bodyhtml != ''
            @_destroy()
            @fireEvent('load', @, bodyhtml)

    _destroy: ->
        @iframe.remove()


class AsyncFileUploader extends Observable
    constructor: (options) ->
        super(options)
        options = applyOptions('AsyncFileUploader', options, {
            files: null
        }, ['formElement', 'formFieldName'])
        {formElement, @formFieldName, @files} = options
        @form = new ElementWrapper(formElement)



    _onXHRProgress: (e) =>
        if (e.lengthComputable)
            currentState = (e.loaded / e.total) * 100
            @fireEvent('progress', @, currentState, e)

    _onXHRError: (e) =>
        @fireEvent('error', @, e)

    _onXHRAbort: (e) =>
        @fireEvent('abort', @, e)

    _onXHRLoad: (e) =>
        @_onUploaded(e.target.responseText)

    ###
    Upload the files using XMLHttpRequest. Unless you want to exclude older
    browsers, you will probably want to use the upload function.
    ###
    uploadXHR: ->
        formData = new FormData()
        for file in @files
            formData.append(@formFieldName, file)
        @xhrRequest = new XMLHttpRequest()
        @xhrRequest.upload.addEventListener('progress', @_onXHRProgress, false)
        @xhrRequest.addEventListener('error', @_onXHRError, false)
        @xhrRequest.addEventListener('abort', @_onXHRAbort, false)
        @xhrRequest.addEventListener('load', @_onXHRLoad, false)
        url = @form.getAttribute('action')
        @xhrRequest.open("POST", url)
        @xhrRequest.send(formData)

    abort: ->
        if @xhrRequest?
            @xhrRequest.abort()

    uploadHiddenIframeForm: ->
        hiddenIframe = new HiddenIframe({
            listeners: {
                load: (hiddenIframe, data) =>
                    @_onUploaded(data)
            }
        })
        @form.setAttribute('target', hiddenIframe.iframe.getId())
        @form.htmlElement.submit()

    upload: ->
        abort = @fireEvent('start', @)
        if abort
            console.log 'aborted'
            return
        if browserInfo.supportsXhrFileUpload()
            @uploadXHR()
        else
            @uploadHiddenIframeForm()

    _onUploaded: (data) ->
        @fireEvent('finished', @, data)

    getFilenames: ->
        filenames = []
        if @files?
            for file in @files
                filenames.push(file.name)
        else
            filepath = @form.down("input[name=#{@formFieldName}]").htmlElement.value
            filename = filepath.split('/').pop().split('\\').pop()
            filenames.push(filename)
        return filenames

    hasMultipleFiles: ->
        return @getFilenames().length > 1

    getFileInfo: ->
        fileinfo = []
        if @files
            for file in @files
                fileinfo.push({
                    name: file.name
                    size: file.size
                    type: file.type
                })
            return fileinfo
        else
            for filename in @getFilenames()
                fileinfo.push({
                    name: filename
                })

    getFileobjectsByName: ->
        files = {}
        if @files
            for file in @files
                files[file.name] = file
        return files



class FileUpload extends Observable
    constructor: (options) ->
        super(options)
        options = applyOptions('FileUpload', options, {
            uploadOnChange: true
            dropTargetSelector: null
            dropEffect: 'copy'
        }, ['containerElement', 'widgetRenderFunction'])
        {containerElement, @widgetRenderFunction,
            @uploadOnChange, @allowDragAndDrop,
            @dropTargetSelector, @dropEffect} = options
        @container = new ElementWrapper(containerElement)
        @draggingFiles = false
        @_createWidget()

    _createWidget: ->
        renderedHtml = @widgetRenderFunction.apply(this)
        @current = new ElementWrapper(document.createElement('div'))
        @current.setInnerHtml(renderedHtml)
        @container.appendChild(@current)
        @_getCurrentFileField().on('change', @_onChange)
        if @dropTargetSelector? and browserInfo.supportsDragAndDropFileUpload()
            @dropTargetElement = @current.down(@dropTargetSelector)
            if @dropTargetElement == null
                throw "No drop target element found for selector: #{@dropTargetSelector}"
            @_setupDragEvents()
        @fireEvent('createWidget', @)

    getContainerElement: ->
        return @container.htmlElement

    getCurrentWidgetElement: ->
        return @current.htmlElement

    _getCurrentForm: ->
        return @current.down('form')

    getCurrentFormElement: ->
        return @_getCurrentForm().htmlElement

    _getCurrentFileField: ->
        return @current.down('input[type=file]')

    getCurrentFileFieldElement: ->
        return @_getCurrentFileField()?.htmlElement

    pause: ->
        @paused = true
        @fireEvent('pause', @)

    resume: ->
        @paused = false
        @fireEvent('resume', @)

    upload: (files) ->
        if @paused
            throw "Can not upload while paused."
        old = @current
        helper = new AsyncFileUploader({
            formElement: @getCurrentFormElement()
            formFieldName: @_getCurrentFileField().getAttribute('name')
            files: files
            listeners: {
                start: @_onUploadStart
                finished: =>
                    old.remove()
            }
        })
        @current.setAttribute('style', 'display: none;')
        @_createWidget()
        helper.upload()

    _onChange: =>
        if @uploadOnChange
            @upload(@getCurrentFileFieldElement().files)
        @fireEvent('fieldChange', @)

    _onUploadStart: (args...) =>
        abort = @fireEvent('uploadStart', @, args...)
        if abort
            return new ObservableResult({
                abort: true
            })

    _setupDragEvents: ->
        @dropTargetElement.on('dragover', @_onDragOver)
        @dropTargetElement.on('dragenter', @_onDragEnter)
        @dropTargetElement.on('dragleave', @_onDragLeave)
        @dropTargetElement.on('drop', @_onDrop)

    _onDragOver: (e) =>
        e.preventDefault()
        if @draggingFiles
            e.dataTransfer.dropEffect = @dropEffect
            @fireEvent('dragover', @, e)
        return false

    _onDragEnter: (e) =>
        e.preventDefault()
        @draggingFiles = dataTransferContainsFiles(e.dataTransfer)
        if @draggingFiles
            @fireEvent('dragenter', @, e)
        return false

    _onDragLeave: (e) =>
        e.preventDefault()
        if @draggingFiles
            @draggingFiles = false
            @fireEvent('dragleave', @, e)
        return false

    _onDrop: (e) =>
        e.preventDefault()
        if e.dataTransfer.files.length > 0
            @fireEvent('dropFiles', e, e.dataTransfer.files)
            if @uploadOnChange
                @upload(e.dataTransfer.files)
        return false

prevent_default_window_drophandler = ->
    if window.addEventListener
        window.addEventListener("dragover", (e) ->
            e.preventDefault()
        , false)
        window.addEventListener("drop", (e) ->
            e.preventDefault()
        , false)


window.devilry_file_upload = {
    FileUpload: FileUpload
    AsyncFileUploader: AsyncFileUploader
    browserInfo: browserInfo
    FileWrapper: FileWrapper
    prevent_default_window_drophandler: prevent_default_window_drophandler
    Observable: Observable
    ObservableResult: ObservableResult
    applyOptions: applyOptions
    HiddenIframe: HiddenIframe
}
