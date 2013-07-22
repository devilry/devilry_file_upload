================
jquerywidgets.js
================

.. default-domain:: js
.. highlight:: js

This module provides the ``devilry_file_upload.jquery`` namespace with widgets.
The philosophy behind the widgets is flexibility and decoupling.

We consider the process of file upload as a three-step process, and we provide
widgets for all three steps:

1. Select one or more local files

    - :class:`devilry_file_upload.jquery.FileUploadWidget`

2. Monitor the upload progress:

    - :class:`devilry_file_upload.jquery.FileUploadProgressWidget`

3. List/preview uploaded files:

    - :class:`devilry_file_upload.jquery.UploadedFileWidget`
    - :class:`devilry_file_upload.jquery.UploadedFilePreviewWidget`


.. note::

    The code is developed using CoffeeScript. We provide the compiled
    JavaScript, so you do not have to know CoffeeScript to use the library.
    When we talk about classes, we are talking about coffeescript classes,
    which you can extend in both CoffeeScript and JavaScript. Refer to
    the `CoffeeScript docs <http://coffeescript.org/#classes>`_ for more info.



CSS
===
We provide CSS for our widgets. You do not have to use this CSS, but it is
generally recommended to use the layout classes. All our widgets have layout classes
that takes care of the basic layout of the widget (show/hide components
depending on the browser capabilities), and optional visual classes. The layout classes
is named after the widget class (E.g.: FileUploadWidget), and the visual
classes is used in addition to the layout class. You find details about the CSS
classes for each widget below.

Include ``css/widgets.css`` or ``css/widgets.min.css`` to get the CSS classes.



FileUploadWidget
================
.. class:: devilry_file_upload.jquery.FileUploadWidget(options)

    A file upload widget that presents itself as a stylable frame for modern
    browsers, and a plain file upload form for older browsers (like IE8 and
    IE9).

    :param options: Object with the following attributes:

        fileUpload (required)
            A :class:`devilry_file_upload.FileUpload` object.

        fileUploadButtonSelector
            A CSS selector to find the file upload button within the current
            widget element of the ``fileUpload`` (see
            :class:`devilry_file_upload.FileUpload.getCurrentWidgetElement`).
            The file upload button is a html element (typically an ``a`` or
            ``button``) that the user can click to show the regular file upload
            dialog. This is only used when the browser support drag and drop.
            On old browsers, users click the file input directly to show the
            dialog. Defaults to ``.fileUpload``.

        draggingClass
            CSS class to add to the ``fileUpload.getContainerElement()`` when
            dragging files over the container. Defaults to ``dragover``.

        supportsDragAndDropFileUploadClass
            CSS class to add to the ``fileUpload.getContainerElement()`` when
            the browser supports drag and drop. Defaults to
            ``supportsDragAndDropFileUpload``.


Usage
-----

Create a :class:`devilry_file_upload.FileUpload` object. Then create the
FileUploadWidget with the FileUpload-object as input to the constructor as the
``fileUpload`` option::

    var fileUpload = new devilry_file_upload.FileUpload({
        ...
    });
    var fileUploadWidget = new devilry_file_upload.jquery.FileUploadWidget({
        fileUpload: fileUpload
    });

To get it working with the provided CSS, use a ``widgetRenderFunction`` (option
for FileUpload) that provides something like this html:

.. code-block:: html

    <form action="/upload" method="post" enctype="multipart/form-data">
        <input type="file" name="files" multiple>
    </form>
    <div class="dragHelp">
        Add files by dragging and dropping them into this box, or
        by <a href="#" class="fileUploadButton">uploading them</a>.
    </div>
    <div class="dropHelp">Drop your files to upload them.</div>
    <div class="dropTarget"></div>

The following properties of ``widgetRenderFunction`` is important:

    - Provide a ``div.dragHelp``, ``div.dropHelp`` and ``div.dropTarget``
      **outside** the form, because the form is hidden when drag and drop is
      supported (through the ``supportsDragAndDropFileUpload`` css class).
    - The form has ``enctype`` set correctly.
    - The form  contains only one file field.
    - You **do not** set the id-attribute of any of the elements.
      :class:`devilry_file_upload.FileUpload` creates multiple widgets at the
      same time so you will end up with muliple elements with the same ID in
      your page.


Autohide on abort
-----------------
The widget hides itself (hides the
:func:`devilry_file_upload.FileUpload.getContainerElement`) whenever the
FileUpload fires the ``abort``-event. It shows itself again on the
``resume``-event. This is useful in many cases, especially when implementing
single file upload - you just have to pause the file upload when a file is
added, and resume the upload if it is delete, or the upload fails.


CSS classes
-----------

You set these classes on the ``containerElement`` for the ``FileUpload``.

``.FileUploadWidget``
    The basic layout for the widget.

``.FileUploadWidget.FileUploadWidgetLargeStriped``
    Styles the widget as a large box width striped border. The box expands when
    you drag files into it.

``.FileUploadWidget.FileUploadWidgetSlimLine``
    Styles the widget as a slim box, kind of like the one used in github issues.

``.FileUploadWidget.FileUploadWidgetSlimLineExpand``
    Almost the same as FileUploadWidgetSlimLine, but the box expands when you
    drag files into it, providing the user with a clearer visual indicator.

    

.. warning::

    The CSS will not work if you set ``draggingClass`` or
    ``supportsDragAndDropFileUpload`` to something other than their defaults.


Methods
-------

.. function:: devilry_file_upload.jquery.FileUploadWidget.destroy

    Detach all event listeners from the object.



FileUploadProgressWidget
========================
.. class:: devilry_file_upload.jquery.FileUploadProgressWidget(options)

    A widget showing the progress of a single file upload. Supports multifile
    upload.

    :param options: Object with the following attributes:

        fileUpload (required)
            A :class:`devilry_file_upload.FileUpload` object.

        renderFunction (required)
            A render function that renders 

        progressSelector
            A CSS selector matching the progress box element.
            This must be a parent of the element matching the
            ``progressBarSelector``. This element is hidden until
            we get a progress event, which we do not get for old browsers or
            for small files. Defaults to ``.inlineProgress``.

        progressBarSelector
            A CSS selector matching the progress bar element within the element
            matched by ``progressSelector``. The width of this element is set to
            match the percent argument of the ``progress``-event.
            Defaults to ``.bar``.

        abortButtonSelector
            A CSS selector matching the abort button. Set this to ``null`` if
            you do not provide an abort-button. Defaults to ``.abortButton``.


.. attribute:: devilry_file_upload.jquery.FileUploadProgressWidget.elementJq

    The jQuery element containing the HTML rendered by ``renderFunction``.
    


Usage
-----

Add an empty ``div``-element wherever you want to render your progress indicators:

.. code-block:: html

    <div id="myFileUploadProgressContainer"></div>

In the ``uploadStart`` event handler for your
:class:`devilry_file_upload.FileUpload`, create a ``FileUploadProgressWidget``,
and add it to your ``div``-element::

    var fileUpload = new devilry_file_upload.FileUpload({
        listeners: {
            uploadStart: function(fileUpload, asyncFileUploader) {
                var uploadProgressWidget = new devilry_file_upload.jquery.FileUploadProgressWidget({
                    fileUpload: fileUpload,
                    asyncFileUploader: asyncFileUploader,
                    renderFunction: function(asyncFileUploader) {
                        ...
                    }
                });
                $('#myFileUploadProgressContainer').append(uploadProgressWidget.elementJq);
            }
        }
    });
    var fileUploadWidget = new devilry_file_upload.jquery.FileUploadWidget({
        fileUpload: fileUpload
    });

To get it working with the provided CSS, use a ``renderFunction`` that provides
something like this html:

.. code-block:: html

    <div class="FileUploadProgressWidget GrayFileBox">
        <div class="inlineProgress">
            <div class="bar"></div>
        </div>
        Uploading myfile.txt
        <button type="button" class="abortButton closeButtonDanger">&times;</button>
    </div>

You can use something very different, just make sure to set the
``progressSelector``, ``progressBarSelector`` and ``abortButtonSelector``
options accordingly.


CSS
---

``.FileUploadProgressWidget``
    Basic layout of the widget.

``.FileUploadProgressWidget GrayFileBox``
    Style the progress widget as a light gray box with darker gray border.
    
``.FileUploadProgressWidget GrayFileBox large``
    Make the box and fonts larger.



UploadedFileWidget
==================
.. class:: devilry_file_upload.jquery.UploadedFileWidget

    A widget for displaying uploaded files, with an optional delete button.

    :param options: Object with the following attributes:

        renderFunction (required)
            A function that renders the HTML for the widget.

        deleteRequestArgs
            Forwarded to `jQuery.ajax <http://api.jquery.com/jQuery.ajax/>`_
            when deleting the file.  If deleteRequestArgs is ``null`` or undefined,
            the delete button event handler will not be attached. Note that the widget sets
            ``succes``, error`` and ``complete``, so setting them will have no
            effect. Defaults to ``null``.

        deleteButtonSelector
            A CSS selector for finding the delete button within the rendered
            HTML created by ``renderFunction``. Required if
            ``deleteRequestArgs!=null``. Defaults to ``.deleteButton``.

        deletingMessageSelector
            A CSS selector for finding the deleting message --- a message shown
            while the file is deleted. If this is ``null``, no deleting message
            is shown. If it is set, the message is hidden when the widget is
            created, and shown while the delete request is in progress. Ignored
            if ``deleteRequestArgs==null``. Defaults to ``.deletingMessage``.

.. attribute:: devilry_file_upload.jquery.UploadedFileWidget.elementJq

    The jQuery element containing the HTML rendered by ``renderFunction``.


Usage
-----
Add an empty ``div``-element wherever you want to render your list of uploaded files:

.. code-block:: html

    <div id="myUploadedFiles"></div>

An UploadedFileWidget is typically created in a ``finish`` event handler for
:class:`devilry_file_upload.AsyncFileUploader`. This means that you typically create
a :class:`devilry_file_upload.FileUpload` object, and attach a ``finished`` listener
to the AsyncFileUploader-object provided by the ``uploadStart`` event::

    var fileUpload = new devilry_file_upload.FileUpload({
        ...
        listeners: {
            uploadStart: function(fileUpload, asyncFileUploader) {
                asyncFileUploader.on('finished', function(asyncFileUploader, data) {
                    // ... parse the data string
                    var uploadedFileWidget = new devilry_file_upload.jquery.UploadedFilePreviewWidget({
                        ...
                    });
                    $('#myUploadedFiles').append(uploadedFileWidget.elementJq);
                }
            }
        }
    });
    

To get it working with the provided CSS, use a ``renderFunction`` that provides
something like this html:

.. code-block:: html

    <div class="UploadedFilePreviewWidget GrayFileBox">
       <div class="filename">myfile.txt</div>
       <button type="button" class="deleteButton closeButtonDanger">&times;</button>
       <div class="deletingMessage">Deleting...</div>
    </div>'


CSS
---

``.UploadedFileWidget``
    Basic layout of the widget.

``.UploadedFileWidget GrayFileBox``
    Style the widget as a light gray box with darker gray border.
    
``.UploadedFileWidget GrayFileBox large``
    Make the box and fonts larger.


UploadedFilePreviewWidget
=========================
.. class:: devilry_file_upload.jquery.UploadedFilePreviewWidget

    Extends :class:`devilry_file_upload.jquery.UploadedFileWidget` with
    previews. Can use local files for previews on modern browsers, but can also
    use preview thumbnails or text generated by you (or your server API).

    :param options: The same as UploadedFileWidget, but you can additionally supply

        hasPreviewCls
            The CSS class to add to the root element created by
            ``renderFunction`` if we show a preview.
            Defaults to ``hasPreview``.
        previewSelector
            CSS selector for the preview element. Defaults to ``.preview``.
        previewFile
            A File API File to show in the preview field. This works for modern
            browsers if :class:`devilry_file_upload.FileWrapper` identifies the
            file as image or text. Ignored if ``previewUrl`` or ``previewText``
            is provided.
        previewUrl
            Set the preview image to a URL. Typically used when your server API
            creates a thumbnail when you upload your file.
        previewText
            Set the preview as a text string. Typically used when your server
            API extract text from some text-based format, such as PDF or ODF.

.. function:: devilry_file_upload.jquery.UploadedFilePreviewWidget.setPreviewUrl(url)

    set the the preview image from an URL --- same effect as the ``previewUrl``
    option.

.. function:: devilry_file_upload.jquery.UploadedFilePreviewWidget.setPreviewText(textstring)

    Set the the preview text from a string --- same effect as the
    ``previewText`` option.


Usage
-----
The usage is more or less the same as for UploadedFileWidget, but you must also
include a preview-div in the HTML rendered by ``renderFunction``:

.. code-block:: html

    <div class="UploadedFilePreviewWidget GrayFileBox">
       <div class="preview"></div>
       <div class="filename">myfile.txt</div>
       <button type="button" class="deleteButton closeButtonDanger">&times;</button>
       <div class="deletingMessage">Deleting...</div>
    </div>'

CSS
---

``.UploadedFilePreviewWidget``
    Basic layout of the widget.

``.UploadedFilePreviewWidget GrayFileBox``
    Style the widget as a light gray box with darker gray border and 40x40px preview.
    
``.UploadedFilePreviewWidget GrayFileBox large``
    Make the box 100px high, and the preview 100px wide. Also increase the font sizes.
