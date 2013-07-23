from wsgiref.util import setup_testing_defaults
from wsgiref.util import FileWrapper
from wsgiref.simple_server import make_server
from os.path import dirname
from os.path import join
from os.path import exists
from os.path import isdir
from os.path import abspath
from os.path import basename
from os import listdir
from os import remove
from time import sleep
from random import randint
from cgi import FieldStorage
from mimetypes import guess_type
import json
import logging


THIS_DIR = abspath(dirname(__file__))
ROOT_DIR = abspath(dirname(THIS_DIR))
UPLOAD_DIR = join(THIS_DIR, 'uploads')


def parse_postdata(environ):
    post_environ = environ.copy()
    post_environ['QUERY_STRING'] = ''
    post = FieldStorage(
        fp=environ['wsgi.input'],
        environ=post_environ,
        keep_blank_values=True
    )
    return post


def file_upload_json_response(start_response, status, data):
    # The content type must be text/html to avoid IE issues when this is
    # used from a hidden iframe.
    headers = [('Content-type', 'text/html')]
    start_response(status, headers)
    return [json.dumps(data)]


def file_upload_bad_request_response(start_response, data):
    # NOTE: We would have liked to use '400 BAD REQUEST', but that does not
    # work with IE (we get an IE generated error page when responding with 400).
    # More details here: http://stackoverflow.com/questions/11544048/how-to-suppress-friendly-error-messages-in-internet-explorer
    return file_upload_json_response(start_response, '200 OK', data)


def example_file_upload_app(environ, start_response):
    """
    An example of a file upload server implementation.

    DO NOT USE THIS IS PRODUCTION - IT IS A MINIMALISTIC EXAMPLE WITH NO
    CONSIDERATION FOR SECURITY OR EFFICIENCY.
    """
    log = logging.getLogger('example_file_upload_app')
    if environ.get('REQUEST_METHOD') == 'POST':

        # Standard file upload - read the file and put it on the local disk in
        # the UPLOAD_DIR directory.
        # These lines are the only stuff actually required by
        # devilry_file_upload. The useful response below is up to you.
        postdata = parse_postdata(environ)
        if not 'files' in postdata:
            return file_upload_bad_request_response(start_response, {
                'success': False,
                'error': '``files`` is a required argument'
            })
        files = postdata['files']
        if not isinstance(files, list):
            files = [files]

        # Validate files - make sure we do not overwrite files
        #for fileitem in files:
            #if exists(join(UPLOAD_DIR, fileitem.filename)):
                #return file_upload_bad_request_response(start_response, {
                    #'success': False,
                    #'error': 'Can not overwrite ``{}``'.format(fileitem.filename)
                #})

        uploaded_files = []
        for fileitem in files:
            filename = fileitem.filename # You may want to generate the filename some other way, and store the original filename in a metadata store, like your database (to avoid encoding issues etc.)
            outfilepath = join(UPLOAD_DIR, filename)
            log.info('Uploading %s', outfilepath)
            open(outfilepath, 'wb').write(fileitem.file.read())
            uploaded_files.append({
                'filename': filename,
                'delete_url': '/delete'
            })

        # Format a response with some useful information about the uploaded
        # files. You write the client code to parse this information, so you can
        # choose the format and the amount of information yourself.
        result = {
            'success': True,
            'uploaded_files': uploaded_files
        }
        return file_upload_json_response(start_response, '200 OK', result)
    else:
        return file_upload_bad_request_response(start_response, {
            'success': False,
            'error': 'Only POST requests is accepted by this view.'
        })


def json_response(start_response, status, data):
    headers = [('Content-type', 'application/json')]
    start_response(status, headers)
    return [json.dumps(data)]


def example_file_delete_app(environ, start_response):
    """
    A simple app to delete files.

    USING SOMETHING LIKE THIS IS PRODUCTION IS MADNESS - THIS IS ONLY AN EXAMPLE.
    Your production code should have a lot more protection:
    - protect users from deleting other users files.
    - far stronger protections agains deleting files outside the designated
      upload directory.
    """
    log = logging.getLogger('example_file_delete_app')
    if environ.get('REQUEST_METHOD') == 'DELETE':
        try:
            request_body_size = int(environ.get('CONTENT_LENGTH', 0))
        except (ValueError):
            request_body_size = 0
        if request_body_size == 0:
            return json_response(start_response, '400 ERROR', {
                'error': 'The request body is empty or CONTENT_LENGTH is not set. Expected JSON data in the body.'
            })
        jsondata = environ['wsgi.input'].read(request_body_size)
        data = json.loads(jsondata)
        filename = basename(data['filename']) # NOTE: Use basename to ensure we do not get paths like ../../stuff.txt
        path = join(UPLOAD_DIR, filename)
        if not exists(path):
            return json_response(start_response, '404 OK', {
                'error': '{} does not exist'.format(filename)
            })
        remove(path)
        return json_response(start_response, '200 OK', {
            'filename': filename
        })
    else:
        return json_response(start_response, '400 ERROR', {
            'error': 'The request method must be DELETE.'
        })





def response_404(start_response):
    start_response('404 NOT FOUND', [('Content-type', 'text/html')])
    return ['Not found']



def directory_index(start_response, environ, fsdirpath, urlpath):
    start_response('200 OK', [('Content-type', 'text/html')])
    links = ''
    if urlpath != '':
        links += u'<li><a href="../"><strong>..</strong></a></li>\n'
    for filename in listdir(fsdirpath):
        if filename.startswith('.'):
            continue
        if isdir(join(fsdirpath, filename)):
            filename += '/'
        links += u'<li><a href="{filename}">{filename}</a></li>\n'.format(
                urlpath=urlpath,
                filename=filename)

    yield u"""<!DOCTYPE html>
<html>
    <head>
        <style type="text/css">
            body {{
                font-family:
                sans-serif;
                color: #222;
                padding: 30px;
            }}
            h1 {{
                margin-top: 0;
                padding-top: 0;
            }}
            a {{
                color: #1240AB;
                text-decoration: none;
            }}
            a:hover {{
                text-decoration: underline;
            }}
            a strong {{
                font-size: 24px;
            }}
            ul {{
                margin: 0;
                padding: 0;
            }}
            ul li {{
                list-style: none;
                margin: 6px 0 6px 0;
            }}
        </style>
    </head>
    <body style="">
        <h1>{urlpath}</h1>
        <ul>
            {links}
        </ul>
    </body>
</html>
    """.format(links=links, urlpath=urlpath).encode('utf-8')


def serve_staticfiles_app(environ, start_response):
    """
    Serve one of the *.html files in this directory, one of the *.js files
    in the ``build/`` directory, or one of the *.css files in the ``css/`` directory.
    """
    path = environ.get('PATH_INFO', '').strip('/').split('/')
    fspath = abspath(join(ROOT_DIR, *path))
    if not fspath.startswith(ROOT_DIR):
        return response_404(start_response)
    if exists(fspath):
        if isdir(fspath):
            return directory_index(start_response, environ, fspath, '/'.join(path))
        f = open(fspath, 'rb')
        content_type = guess_type(fspath)[0]
        if not content_type:
            if basename(fspath) in ('README.md', 'LICENSE'):
                content_type = 'text/plain'
            else:
                content_type = 'application/octet-stream'
        start_response('200 OK', [('Content-type', content_type)])
        return FileWrapper(f)
    else:
        return response_404(start_response)



class RouterApp(object):
    def __init__(self, slow=False):
        self.slow = slow

    def __call__(self, environ, start_response):
        """
        Route to one of the ``*_app`` functions above.
        """
        setup_testing_defaults(environ)
        path = environ.get('PATH_INFO')

        if path == '/upload':
            if self.slow:
                sleep(randint(1, 6))
            return example_file_upload_app(environ, start_response)
        elif path == '/delete':
            if self.slow:
                sleep(randint(1, 6))
            return example_file_delete_app(environ, start_response)
        else:
            return serve_staticfiles_app(environ, start_response)


if __name__ == '__main__':
    import os
    import sys
    if not exists(UPLOAD_DIR):
        os.mkdir(UPLOAD_DIR)

    slow = False
    if len(sys.argv) == 2 and sys.argv[1] == 'slow':
        slow = True
        print 'Serving in slow mode'
    else:
        print 'Serving in fast mode. Use "python {} slow" to slow down upload and delete responses for a more realistic experience.'.format(sys.argv[0])

    logging.basicConfig(level=logging.INFO)
    httpd = make_server('', 8000, RouterApp(slow=slow))
    print "Serving on port 8000..."
    httpd.serve_forever()
