=======================================================================================
multifile-draganddrop.html --- Shows off most of the features of devilry_file_upload.js
=======================================================================================

We setup a :class:`devilry_file_upload.FileUpload` just like in
:doc:`examples/simple`, but we include a bit of extra HTML and styles that
enables us to support drag and drop.

The javascript code for drag and drop is only executed if
:func:`devilry_file_upload.BrowserInfo.supportsDragAndDropFileUpload` is
``true``. When drag and drop is supported, we add some classes to indicate drag
and drop (the CSS is in ``css/widgets.css``), and event-listeners for the drag
and drop events.

When the user drags files over our drag and drop target box,
we add the ``dragover`` class (also in ``css/widgets.css``).

When the user drops a file, we use
:func:`devilry_file_upload.FileUpload.upload` to upload the file. Because we
attach an event listener to the FileUpload object that triggers when a file
upload succeeds, that is also triggered when we manually upload a file using
the upload-function.


.. literalinclude:: /../../examples/multifile-draganddrop.html
    :language: html


.. note:: See :doc:`/examples` for information about running the example.
