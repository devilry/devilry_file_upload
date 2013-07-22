================
jquerywidgets.js
================

.. default-domain:: js

This module provides the ``devilry_file_upload.jquery`` namespace with widgets.
The philosophy behind the widgets is flexibility and decoupling.

We consider the process of file upload as a three-step process, and we provide
widgets for all three steps:

1. Select one or more local files

    - :class:`devilry_file_upload.jquery.FileUploadWidget`

2. Monitor the upload progress:

    - :class:`devilry_file_upload.jquery.FileUploadProgressContainerWidget`
    - :class:`devilry_file_upload.jquery.FileUploadWidget`

3. List/preview uploaded files:

    - :class:`devilry_file_upload.jquery.UploadedFilesWidget`
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


FileUploadProgressContainerWidget
=================================
.. class:: devilry_file_upload.jquery.FileUploadProgressContainerWidget(options)




FileUploadWidget
================
.. class:: devilry_file_upload.jquery.FileUploadWidget(options)



UploadedFilesWidget
===================
.. class:: devilry_file_upload.jquery.UploadedFilesWidget


UploadedFileWidget
==================
.. class:: devilry_file_upload.jquery.UploadedFileWidget


UploadedFilePreviewWidget
=========================
.. class:: devilry_file_upload.jquery.UploadedFilePreviewWidget
