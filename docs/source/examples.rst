========================
Examples
========================


To run the examples, you have to check out the `GIT repo
<https://github.com/devilry/devilry_file_upload>`_, and run::

    $ python examples/server.py

Then open your browser at http://localhost:8000/examples/. The source code for
the examples are in ``examples/``. Each example is explained below. You should
start with :doc:`examples/simple`.

.. note::

    We have to use a server to run the examples because:

    - File upload is not possible without a server.
    - We can not use a local HTML file with an external server --- Because we do
      not want to host such a server, and because browsers do not allow it with
      default security settings.


Detailed guides for each example
################################

.. toctree::
    :maxdepth: 1

    examples/simple
