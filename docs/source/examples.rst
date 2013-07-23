========================
Examples
========================


To run the examples, you have to check out the `GIT repo
<https://github.com/devilry/devilry_file_upload>`_, and run::

    $ python examples/server.py

Then open your browser at http://localhost:8000/examples/. The source code for
the examples are in ``examples/``. The upload API used by the examples puts
files in ``examples/uploads/``. Each example is explained below. You should
start with :doc:`examples/simple`.

.. note::

    We have to use a server to run the examples because:

    - File upload is not possible without a server.
    - We can not use a local HTML file with an external server --- Because we do
      not want to host such a server, and because browsers do not allow it with
      default security settings.


A note about simplicity
#######################
Some of the examples may seem very verbose compared to other file upload
solutions. We believe that simplicity does not come from writing as little code
as possible --- it comes from deterministic behavior and as little magical
behavior as possible. Our API is not designed to be a copy paste file uploader,
it is designed to make it easy for you to make your own.


Detailed guides for each example
################################

.. toctree::
    :maxdepth: 1

    examples/simple
    examples/simple-multifile
    examples/multifile-draganddrop
    examples/jquerywidgets-multifile
    examples/jquerywidgets-singlefile
