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
classes uses the widget class name as prefix, and some descriptive suffix. You
find details about the CSS classes for each widget below.

Include ``css/widgets.css`` or ``css/widgets.min.css`` to get the CSS classes.



FileUploadWidget
================
.. class:: devilry_file_upload.jquery.FileUploadWidget

A file upload widget that presents itself as a stylable frame for modern
browsers, and a plain file upload form for older browsers (like IE8 and
IE9).



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
