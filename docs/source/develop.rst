========================
Develop
========================


Develop JS and CSS
##################

Install development deps
========================

Install the nodejs modules required to build the CoffeeScript sources. Run the
following from the reporoot::

    $ npm install

The packages are installed in ``node_modules/`` in the current directory.


Build the CoffeeScript sources
==============================

To watch the sources for changes and rebuild automatically, run::

    $ cake coffeeWatch

To just build the sources, run::

    $ cake coffeeBuild

The result of the build ends up in ``js/``.


Build the LESS sources
======================

To watch the sources for changes and rebuild automatically, run::

    $ cake lessWatch

To just build the sources, run::

    $ cake lessBuild

The result of the build ends up in ``css/``.


Build JS and CSS for release
============================

To build both coffeescript and LESS for release, run::

    $ cake productionBuild

Then commit all the built files.



Write docs
##########


Install deps
============
Install `sphinx <http://sphinx-doc.org/>`_ and deps using::

    $ cd docs/
    $ virtualenv venv
    $ source venv/bin/activate
    $ pip install -r requirements.txt


Build the docs
==============

Make sure the virtualenv created in the previous section is active::

    $ cd docs/
    $ source venv/bin/activate

Build the docs::

    $ make html

You can view the docs at ``build/html/index.html``, but to view them as they
appear on readthedocs, you will have to run the example server (see
:file:`examples``, and navigate to
http://localhost:8000/docs/build/html/index.html.
