###
jQuery widgets that uses ``devilry_file_upload``.


Requirements
============
- jQuery (http://jquery.com/)


Style guide
===========
- All classes use ``devilry_file_upload.applyOptions`` for their options.
- Classes raise events using ``devilry_file_upload.Observable``.
- We use the ``Jq`` suffix to distinguish jQuery elements from normal html
  elements.
###


if not window.devilry_file_upload?
    throw "devilry_file_upload.js must be imported before bootstrap_widgets.js"



class UploadedFileWidget extends devilry_file_upload.Observable
    constructor: (options) ->
        super(options)
        options = devilry_file_upload.applyOptions('UploadedFileWidget', options, {
            deleteRequestArgs: null
            deleteButtonSelector: '.deleteButton'
            deletingMessageSelector: '.deletingMessage'
        }, ['renderFunction'])
        {renderFunction,
            @deleteRequestArgs,
            @deleteButtonSelector, @deletingMessageSelector} = options

        renderedHtml = renderFunction.apply(this)
        @elementJq = jQuery(renderedHtml)
        if @deleteRequestArgs?
            @deleteButton = @elementJq.find(@deleteButtonSelector)
            if @deleteButton.length == 0
                throw "Could not find '#{@deleteButtonSelector}' in the rendered view: #{renderedHtml}"
            if @deletingMessageSelector?
                @deletingMessage = @elementJq.find(@deletingMessageSelector)
                @deletingMessage.hide()
            @deleteButton.on('click', @_onDelete)

    destroy: ->
        if @deleteRequestArgs?
            @deleteButton.off('click', @_onDelete)
        

    showDeletingMessage: ->
        if @deletingMessage?
            @deleteButton.hide()
            @deletingMessage.show()

    hideDeletingMessage: ->
        if @deletingMessage?
            @deletingMessage.hide()
            @deleteButton.show()


    _onDelete: (e) =>
        e.preventDefault()
        abort = @fireEvent('delete', @)
        if abort
            return
        else
            @deleteFile()

    deleteFile: ->
        @showDeletingMessage()
        options = jQuery.extend({}, @deleteRequestArgs, {
            success: @_onDeleteSuccess
            error: @_onDeleteError
            complete: =>
                @hideDeletingMessage()
        })
        jQuery.ajax(options)

    _onDeleteSuccess: (data, status) =>
        @fireEvent('deleteSuccess', @, data, status)
        @elementJq.remove()

    _onDeleteError: (jqXHR, textStatus, errorThrown) =>
        @fireEvent('deleteError', @, jqXHR, textStatus, errorThrown)



class UploadedFilePreviewWidget extends UploadedFileWidget
    constructor: (options) ->
        super(options)
        options = devilry_file_upload.applyOptions('UploadedFilePreviewWidget', options, {
            hasPreviewCls: 'hasPreview',
            previewSelector: '.preview'
            previewFile: null
            previewUrl: null
            previewText: null
        }, [])
        {previewFile, previewUrl, previewText, previewSelector, hasPreviewCls} = options
        @previewJq = @elementJq.find(previewSelector)

        if previewUrl?
            @setPreviewUrl(previewUrl)
        else if previewText?
            @setPreviewText(previewText)
        else if previewFile?
            fileWrapper = new devilry_file_upload.FileWrapper(previewFile)
            if fileWrapper.isImage() or fileWrapper.isText()
                @elementJq.addClass(hasPreviewCls)
                reader = new FileReader()
                if fileWrapper.isImage()
                    reader.onload = @onLoadPreviewImage
                    reader.readAsDataURL(fileWrapper.file)
                else
                    reader.onload = @onLoadPreviewText
                    reader.readAsText(fileWrapper.file)

    setPreviewUrl: (url) ->
        @previewJq.css({
            'background-image': "url(#{url})"
        })

    setPreviewText: (text) ->
        @previewJq.text(text)

    onLoadPreviewImage: (event) =>
        @setPreviewUrl(event.target.result)

    onLoadPreviewText: (event) =>
        text = event.target.result
        @setPreviewText(text)


class FileUploadWidget
    constructor: (options) ->
        options = devilry_file_upload.applyOptions('FileUploadWidget', options, {
            draggingClass: 'dragover'
            supportsDragAndDropFileUploadClass: 'supportsDragAndDropFileUpload'
            fileUploadButtonSelector: '.fileUploadButton'
            dragAndDrop: null
        }, ['fileUpload'])
        {@fileUpload, @dragAndDrop, @draggingClass, @supportsDragAndDropFileUploadClass,
            @fileUploadButtonSelector} = options
        @containerJq = jQuery(@fileUpload.getContainerElement())
        if devilry_file_upload.browserInfo.supportsDragAndDropFileUpload()
            @dragAndDrop.on('dragenter', @_onDragEnter)
            @dragAndDrop.on('dragleave', @_onDragLeave)
            @dragAndDrop.on('dropfiles', @_onDropFiles)
            @containerJq.addClass(@supportsDragAndDropFileUploadClass)
            @_attachFileUploadListener()
        @fileUpload.on('pause', @_onPause)
        @fileUpload.on('resume', @_onResume)
        @fileUpload.on('createWidget', @_onCreateWidget)

    destroy: ->
        if devilry_file_upload.browserInfo.supportsDragAndDropFileUpload()
            @dragAndDrop.off('dragenter', @_onDragEnter)
            @dragAndDrop.off('dragleave', @_onDragLeave)
            @dragAndDrop.off('dropfiles', @_onDropFiles)
        @fileUpload.off('createWidget', @_onCreateWidget)
        @fileUpload.off('pause', @_onPause)
        @fileUpload.off('resume', @_onResume)

    _attachFileUploadListener: ->
        jQuery(@fileUpload.getCurrentWidgetElement()).find(@fileUploadButtonSelector).on('click', @_onClickFileUploadButton)

    _onCreateWidget: =>
        if devilry_file_upload.browserInfo.supportsDragAndDropFileUpload()
            @_attachFileUploadListener()

    _onDragEnter: =>
        @containerJq.addClass(@draggingClass)

    _onDragLeave: =>
        @containerJq.removeClass(@draggingClass)

    _onDropFiles: =>
        @containerJq.removeClass(@draggingClass)

    _onClickFileUploadButton: (e) =>
        e.preventDefault()
        jQuery(@fileUpload.getCurrentFileFieldElement()).click()

    _onPause: =>
        @containerJq.hide()

    _onResume: =>
        @containerJq.show()



class FileUploadProgressWidget
    constructor: (options) ->
        options = devilry_file_upload.applyOptions('FileUploadProgressWidget', options, {
            progressSelector: '.inlineProgress'
            progressBarSelector: '.bar'
            abortButtonSelector: '.abortButton'
        }, ['asyncFileUploader', 'renderFunction'])
        {@asyncFileUploader, renderFunction, progressBarSelector,
            progressSelector, abortButtonSelector} = options

        renderedHtml = renderFunction.apply(this)
        @elementJq = jQuery(renderedHtml)
        @progressJq = @elementJq.find(progressSelector)
        @progressBarJq = @progressJq.find(progressBarSelector)
        @progressJq.hide()

        @asyncFileUploader.on('progress', @_onProgress)
        @asyncFileUploader.on('finished', @_onFinished)
        if devilry_file_upload.browserInfo.supportsXhrFileUpload()
            if abortButtonSelector?
                @abortButtonJq = @elementJq.find(abortButtonSelector)
            @abortButtonJq.on('click', @_onAbort)
            @abortButtonJq.show()

    _destroy_common: ->
        @asyncFileUploader.off('progress', @_onProgress)
        @elementJq.remove()

    destroy: ->
        @_destroy_common()
        @asyncFileUploader.off('finished', @_onFinished)

    _onAbort: =>
        @asyncFileUploader.abort()
        @destroy()

    _onProgress: (asyncFileUploader, state) =>
        @progressJq.show()
        @progressBarJq.width("#{state}%")

    _onFinished: (asyncFileUploader, state) =>
        @_destroy_common()
        return new devilry_file_upload.ObservableResult({
            # We can not use @asyncFileUploader.off because we can not remove
            # _this_ function from the event loop while the loop is running
            remove: true
        })




window.devilry_file_upload.jquery = {
    FileUploadWidget: FileUploadWidget
    FileUploadProgressWidget: FileUploadProgressWidget
    UploadedFileWidget: UploadedFileWidget
    UploadedFilePreviewWidget: UploadedFilePreviewWidget
}
