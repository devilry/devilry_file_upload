========================
Examples
========================


To run the examples, you have to check out the GIT repo, and run::

    $ python examples/server.py

Then open your browser at http://localhost:8000/examples/. The source code for
the examples are in ``examples/``. Each example is explained below. You should
start with :doc:`examples/simple`.

.. note::

    We have to use a server to run the examples because file upload is not
    possible without a server, and we can not use a local HTML file and an
    external server (both because we do not want to host such a server, and
    because browsers does not allow it).


Detailed guides for each example
################################

.. toctree::
    :maxdepth: 1

    examples/simple
