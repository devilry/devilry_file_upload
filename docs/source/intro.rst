========================
Introduction
========================


Design
#################


No hard dependencies
====================
We do not want the core functionality to have any dependencies on external
libraries. This is because we want to be able to re-use the component in any
environment.


Separation of logic and view
============================
We provide callbacks where you can render views using your preferred method
(template engines, pure JS, etc.)


Decoupled design
================
We create components that solve a single thing. This means that our widgets
has very few dependencies between them, and the widgets communicate using
events or callbacks. Furthermore, we consider file upload a 3 step process:

1. Select one or more local files (typically file upload field and/or drag and drop).
2. Monitor the upload progress (typically a progress bar with a cancel button).
3. Add uploaded files to some kind of listing widget, which typically has the
   ability to remove/undo the upload. For single file upload widgets, one
   typically provides a replace button instead of a remove button.


We handle as little of the data flow as possble
===============================================
Instead, we provide hooks where YOU can handle your data flow. Example:

    We define a strict data flow for your file upload API, but we do not
    define the format of the response data at all. We have to restrict the
    file upload API to guarantee compatibility with old and new browsers.
    So, when a file is uploaded, you get a string that you have to decode
    yourself, and you decide what to do next (E.g.: Show a success message,
    send it ot the ``UploadedFilesWidget``, ...).



The Devilry project
###################

The reason for the ``devilry_`` prefix, is that the library is developed by
the `Devilry <http://devilry.org>`_ project.
