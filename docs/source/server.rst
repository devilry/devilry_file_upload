===============================
How to implement the server API
===============================

.. highlight:: coffeescript

You need to implement the server API yourself. Unless you use some horrible
framework, it should be really easy. You just have to support normal
old-fasioned multiple file upload.



Important properties
====================

Your file upload API must:

- Use ``text/html`` as content type. ``application/json``, ``application/xml``,
  etc. does not work with Internet Explorer and iFrames, and some browsers wrap
  text in ``application/text`` responses in ``<pre>``-tags. So it is easiest to
  just use ``text/html`` to transport your response. You can, and should, of
  course still respond using structured data formats like JSON. If you use XML,
  ``text/plain`` may be better.
- Only respond with status ``200 OK``. This is the only reliable status for
  Internet Explorer and iFrame upload. With short response bodies, IE shows its
  own pages for most other statuse numbers, and you will not get the error
  messages from your API. Indicate errors using your data serialization format,
  as illustrated in the examples below.
- Consider security carefully. You should at least have some protection
  agains overwriting files, uploading executable files and filenames containing
  relative or absolute paths.


Examples
========

This example **pseudocode** illustrates how the server could work::

    function uploadHandler(request)
        outdir = '/path/to/outdir'
        for file in request.POST['files']
            outpath = fs.join(outdir, file.name)
            fs.writeFile(outpath, file.readFile())
        return HttpResonse({
            status: "200 OK",
            data: 'success',
            contentType: "text/html"
        })


This example is slightly more full featured. It responds using JSON, and
protects against overwriting files. It also includes a list of uploaded files
and provides an URL to delete each file. Since you handle the response data
yourself in your client code, you can format the response to suite your
application perfectly::

    function uploadHandler(request)
        outdir = '/path/to/outdir'
        uploadedFiles = []
        for file in request.POST['files']
            outpath = fs.join(outdir, file.name)
            if fs.fileExists(outpath)
                # NOTE: We use "200 OK" for errors, and indicate the
                #       error in the response data.
                return HttpResonse({
                    status: "200 OK",
                    data: JSON.stringify({
                        success: false,
                        error: "Can not overwrite " + file.name
                    }),
                    contentType: "text/html"
                })
                
        for file in request.POST['files']
            outpath = fs.join(outdir, file.name)
            fs.writeFile(outpath, file.readFile())
            uploadedFiles.append({
                filename: file.name,
                delete_url: '/delete'
            })
        return HttpResonse({
            status: "200 OK",
            data: JSON.stringify({
                success: true,
                uploadedFiles: uploadedFiles
            }),
            contentType: "text/html"
        })

We also provide an example in ``examples/server.py``, but you should not even
consider using that example in production.
