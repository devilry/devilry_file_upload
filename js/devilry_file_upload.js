// Generated by CoffeeScript 1.5.0

/*
A general purpose modern (html5) file upload library with fallbacks for older
browsers.
*/


(function() {
  var ArrayUtils, AsyncFileUploader, BrowserInfo, ElementWrapper, FileUpload, FileWrapper, HiddenIframe, Observable, applyOptions, browserInfo, dataTransferContainsFiles, defer, prevent_default_window_drophandler,
    __slice = [].slice,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  applyOptions = function(classorfunctionname, options, defaults, required) {
    var key, result, value, _i, _len;
    if (required == null) {
      required = [];
    }
    result = {};
    for (key in options) {
      value = options[key];
      result[key] = value;
    }
    for (key in defaults) {
      value = defaults[key];
      if (options[key] == null) {
        result[key] = value;
      }
    }
    for (_i = 0, _len = required.length; _i < _len; _i++) {
      key = required[_i];
      if (result[key] == null) {
        throw "'" + key + "' is a required argument for " + classorfunctionname + ".";
      }
    }
    return result;
  };

  defer = function(func) {
    return setTimeout(func, 0);
  };

  dataTransferContainsFiles = function(dataTransfer) {
    var typestring, _i, _len, _ref;
    _ref = dataTransfer.types;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      typestring = _ref[_i];
      if (typestring === 'Files') {
        return true;
      }
    }
    return false;
  };

  /*
  Static class with array manipulation utilities.
  */


  ArrayUtils = (function() {

    function ArrayUtils() {}

    /*
    The same as ``Array.prototype.indexOf()``, but works on old browsers
    like IE8.
    */


    ArrayUtils.indexOf = function(array, item) {
      var i, x, _i, _len;
      if (array.indexOf) {
        return array.indexOf(item);
      } else {
        for (i = _i = 0, _len = array.length; _i < _len; i = ++_i) {
          x = array[i];
          if (x === item) {
            return i;
          }
        }
        return -1;
      }
    };

    /*
    Remove an item from the given array.
    
    Returns ``null`` if no item was removed, or the item if it was removed.
    */


    ArrayUtils.remove = function(array, item) {
      var index;
      index = this.indexOf(array, item);
      if (index === -1) {
        return null;
      } else {
        array.splice(index, 1);
        return item;
      }
    };

    return ArrayUtils;

  })();

  ElementWrapper = (function() {

    ElementWrapper.prototype.attachEventEventMap = {
      click: 'onclick',
      load: 'onload'
    };

    function ElementWrapper(htmlElement) {
      this.htmlElement = htmlElement;
    }

    ElementWrapper.prototype.getTagName = function() {
      return this.htmlElement.tagName.toLocaleLowerCase();
    };

    ElementWrapper.prototype.isFileField = function() {
      return this.getTagName() === 'input' && this.getAttribute('type') === 'file';
    };

    ElementWrapper.prototype.getAttribute = function(name) {
      return this.htmlElement.getAttribute(name);
    };

    ElementWrapper.prototype.setAttribute = function(name, value) {
      return this.htmlElement.setAttribute(name, value);
    };

    ElementWrapper.prototype.removeAttribute = function(name, value) {
      return this.htmlElement.removeAttribute(name);
    };

    ElementWrapper.prototype.appendChild = function(childWrapper) {
      return this.htmlElement.appendChild(childWrapper.htmlElement);
    };

    ElementWrapper.prototype._createRandomId = function() {
      var id, randomInt;
      while (1) {
        randomInt = Math.round(Math.random() * 1000000000);
        id = "ElementWrapperItem-" + randomInt;
        if (document.getElementById(id) == null) {
          return id;
        }
      }
    };

    ElementWrapper.prototype.setRandomId = function() {
      return this.setId(this._createRandomId());
    };

    ElementWrapper.prototype.setId = function(id) {
      return this.htmlElement.id = id;
    };

    ElementWrapper.prototype.getId = function() {
      return this.htmlElement.id;
    };

    ElementWrapper.prototype.on = function(eventName, callback) {
      var _this = this;
      if (this.htmlElement.addEventListener) {
        return this.htmlElement.addEventListener(eventName, callback, false);
      } else if (this.htmlElement.attachEvent) {
        if (eventName === 'change' && this.isFileField()) {
          this.on('click', function() {
            return defer(function() {
              return callback.apply(_this);
            });
          });
          return;
        }
        if (eventName in this.attachEventEventMap) {
          eventName = this.attachEventEventMap[eventName];
        }
        return this.htmlElement.attachEvent(eventName, callback);
      }
    };

    ElementWrapper.prototype.remove = function() {
      return this.htmlElement.parentNode.removeChild(this.htmlElement);
    };

    ElementWrapper.prototype.replaceWith = function(newElementWrapper) {
      this.htmlElement.parentNode.replaceChild(newElementWrapper.htmlElement, this.htmlElement);
      return newElementWrapper;
    };

    ElementWrapper.prototype.down = function(cssSelector) {
      var htmlElement;
      htmlElement = this.htmlElement.querySelector(cssSelector);
      if (htmlElement != null) {
        return new ElementWrapper(htmlElement);
      } else {
        return null;
      }
    };

    ElementWrapper.prototype.setInnerHtml = function(html) {
      return this.htmlElement.innerHTML = html;
    };

    return ElementWrapper;

  })();

  FileWrapper = (function() {

    function FileWrapper(file) {
      this.file = file;
    }

    FileWrapper.prototype.isImage = function() {
      return this.file.type === 'image/png' || this.file.type === 'image/jpeg' || this.file.type === 'image/png';
    };

    FileWrapper.prototype.isText = function() {
      return this.file.type === 'text/plain';
    };

    return FileWrapper;

  })();

  BrowserInfo = (function() {

    function BrowserInfo() {}

    BrowserInfo.prototype.supportsXhrFileUpload = function() {
      var xhr;
      xhr = new XMLHttpRequest();
      return (xhr.upload != null) && (typeof xhr.upload.onprogress !== 'undefined') && (window.FormData != null);
    };

    BrowserInfo.prototype.supportsDragAndDropFileUpload = function() {
      return this.supportsXhrFileUpload();
    };

    BrowserInfo.prototype.logDebugInfo = function() {
      console.log('BrowserInfo logDebugInfo:');
      console.log("   - supportsXhrFileUpload: " + (this.supportsXhrFileUpload()));
      return console.log("   - supportsDragAndDropFileUpload: " + (this.supportsDragAndDropFileUpload()));
    };

    return BrowserInfo;

  })();

  browserInfo = new BrowserInfo();

  Observable = (function() {

    function Observable(options) {
      var callback, listeners, name;
      listeners = options.listeners;
      if (listeners == null) {
        listeners = {};
      }
      this.listeners = {};
      this.managedListeners = {};
      for (name in listeners) {
        callback = listeners[name];
        this.on(name, callback);
      }
    }

    Observable.prototype.on = function(name, callback) {
      if (this.listeners[name] == null) {
        this.listeners[name] = [];
      }
      return this.listeners[name].push(callback);
    };

    Observable.prototype.off = function(name, callback) {
      var listeners;
      listeners = this.listeners[name];
      if (listeners == null) {
        throw "No listeners for '" + name + "'.";
      }
      if (ArrayUtils.remove(listeners, callback) === null) {
        throw "The given callback is not registered for '" + name + "'.";
      }
    };

    Observable.prototype.fireEvent = function() {
      var abort, args, listener, listeners, name, result, _i, _len;
      name = arguments[0], args = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
      listeners = this.listeners[name];
      abort = false;
      if (listeners != null) {
        for (_i = 0, _len = listeners.length; _i < _len; _i++) {
          listener = listeners[_i];
          result = listener.apply(this, args);
          if (result === true) {
            abort = true;
          }
        }
      }
      return abort;
    };

    return Observable;

  })();

  /*
  Makes it easy create a short-lived hidden iframe that can be used to get
  dynamic form responses without reloading the page.
  
  The frame destroys itself as soon as it has been loaded.
  */


  HiddenIframe = (function(_super) {

    __extends(HiddenIframe, _super);

    function HiddenIframe(options) {
      this._onLoadIframe = __bind(this._onLoadIframe, this);      HiddenIframe.__super__.constructor.call(this, options);
      this.iframe = new ElementWrapper(document.createElement('iframe'));
      this.iframe.setRandomId();
      this.iframe.setAttribute('name', this.iframe.getId());
      this.iframe.setAttribute('style', 'visibility: hidden; display: none;');
      document.body.appendChild(this.iframe.htmlElement);
      this.iframe.on('load', this._onLoadIframe);
    }

    HiddenIframe.prototype._getContentDocument = function() {
      return this.iframe.htmlElement.contentDocument || this.iframe.htmlElement.contentWindow.document;
    };

    HiddenIframe.prototype._getBody = function() {
      return this._getContentDocument().getElementsByTagName('body')[0];
    };

    HiddenIframe.prototype._onLoadIframe = function() {
      var bodyhtml;
      bodyhtml = this._getBody().innerHTML;
      if ((bodyhtml != null) && bodyhtml !== '') {
        this._destroy();
        return this.fireEvent('load', this, bodyhtml);
      }
    };

    HiddenIframe.prototype._destroy = function() {
      return this.iframe.remove();
    };

    return HiddenIframe;

  })(Observable);

  AsyncFileUploader = (function(_super) {

    __extends(AsyncFileUploader, _super);

    function AsyncFileUploader(options) {
      var formElement;
      AsyncFileUploader.__super__.constructor.call(this, options);
      options = applyOptions('AsyncFileUploader', options, {
        files: null
      }, ['formElement', 'formFieldName']);
      formElement = options.formElement, this.formFieldName = options.formFieldName, this.files = options.files;
      this.form = new ElementWrapper(formElement);
    }

    /*
    Upload the files using XMLHttpRequest. Unless you want to exclude older
    browsers, you will probably want to use the upload function.
    */


    AsyncFileUploader.prototype.uploadXHR = function() {
      var file, formData, url, _i, _len, _ref,
        _this = this;
      formData = new FormData();
      _ref = this.files;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        file = _ref[_i];
        formData.append(this.formFieldName, file);
      }
      this.xhrRequest = new XMLHttpRequest();
      this.xhrRequest.addEventListener('load', function(event) {
        return _this._onUploaded(event.target.responseText);
      }, false);
      this.xhrRequest.upload.addEventListener('progress', function(event) {
        var currentState;
        if (event.lengthComputable) {
          currentState = (event.loaded / event.total) * 100;
          return _this.fireEvent('progress', _this, currentState);
        }
      }, false);
      url = this.form.getAttribute('action');
      this.xhrRequest.open("POST", url);
      return this.xhrRequest.send(formData);
    };

    AsyncFileUploader.prototype.abort = function() {
      if (this.xhrRequest != null) {
        this.xhrRequest.abort();
        return this.fireEvent('aborted', this);
      }
    };

    AsyncFileUploader.prototype.uploadHiddenIframeForm = function() {
      var hiddenIframe,
        _this = this;
      hiddenIframe = new HiddenIframe({
        listeners: {
          load: function(hiddenIframe, data) {
            return _this._onUploaded(data);
          }
        }
      });
      this.form.setAttribute('target', hiddenIframe.iframe.getId());
      return this.form.htmlElement.submit();
    };

    AsyncFileUploader.prototype.upload = function() {
      this.fireEvent('start', this);
      if (browserInfo.supportsXhrFileUpload()) {
        return this.uploadXHR();
      } else {
        return this.uploadHiddenIframeForm();
      }
    };

    AsyncFileUploader.prototype._onUploaded = function(data) {
      return this.fireEvent('finished', this, data);
    };

    AsyncFileUploader.prototype.getFilenames = function() {
      var file, filename, filenames, filepath, _i, _len, _ref;
      filenames = [];
      if (this.files != null) {
        _ref = this.files;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          file = _ref[_i];
          filenames.push(file.name);
        }
      } else {
        filepath = this.form.down("input[name=" + this.formFieldName + "]").htmlElement.value;
        filename = filepath.split('/').pop().split('\\').pop();
        filenames.push(filename);
      }
      return filenames;
    };

    AsyncFileUploader.prototype.getFileInfo = function() {
      var file, fileinfo, filename, _i, _j, _len, _len1, _ref, _ref1, _results;
      fileinfo = [];
      if (this.files) {
        _ref = this.files;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          file = _ref[_i];
          fileinfo.push({
            name: file.name,
            size: file.size,
            type: file.type
          });
        }
        return fileinfo;
      } else {
        _ref1 = this.getFilenames();
        _results = [];
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          filename = _ref1[_j];
          _results.push(fileinfo.push({
            name: filename
          }));
        }
        return _results;
      }
    };

    AsyncFileUploader.prototype.getFileobjectsByName = function() {
      var file, files, _i, _len, _ref;
      files = {};
      if (this.files) {
        _ref = this.files;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          file = _ref[_i];
          files[file.name] = file;
        }
      }
      return files;
    };

    return AsyncFileUploader;

  })(Observable);

  FileUpload = (function(_super) {

    __extends(FileUpload, _super);

    function FileUpload(options) {
      this._onDrop = __bind(this._onDrop, this);
      this._onDragLeave = __bind(this._onDragLeave, this);
      this._onDragEnter = __bind(this._onDragEnter, this);
      this._onDragOver = __bind(this._onDragOver, this);
      this._onUploadStart = __bind(this._onUploadStart, this);
      this._onChange = __bind(this._onChange, this);
      var containerElement;
      FileUpload.__super__.constructor.call(this, options);
      options = applyOptions('FileUpload', options, {
        uploadOnChange: true,
        dropTargetSelector: null,
        dropEffect: 'copy'
      }, ['containerElement', 'widgetRenderFunction']);
      containerElement = options.containerElement, this.widgetRenderFunction = options.widgetRenderFunction, this.uploadOnChange = options.uploadOnChange, this.allowDragAndDrop = options.allowDragAndDrop, this.dropTargetSelector = options.dropTargetSelector, this.dropEffect = options.dropEffect;
      this.container = new ElementWrapper(containerElement);
      this.draggingFiles = false;
      this._createWidget();
    }

    FileUpload.prototype._createWidget = function() {
      var renderedHtml;
      renderedHtml = this.widgetRenderFunction.apply(this);
      this.current = new ElementWrapper(document.createElement('div'));
      this.current.setInnerHtml(renderedHtml);
      this.container.appendChild(this.current);
      this._getCurrentFileField().on('change', this._onChange);
      if ((this.dropTargetSelector != null) && browserInfo.supportsDragAndDropFileUpload()) {
        this.dropTargetElement = this.current.down(this.dropTargetSelector);
        if (this.dropTargetElement === null) {
          throw "No drop target element found for selector: " + this.dropTargetSelector;
        }
        this._setupDragEvents();
      }
      return this.fireEvent('createWidget', this);
    };

    FileUpload.prototype.getContainerElement = function() {
      return this.container.htmlElement;
    };

    FileUpload.prototype.getCurrentWidgetElement = function() {
      return this.current.htmlElement;
    };

    FileUpload.prototype._getCurrentForm = function() {
      return this.current.down('form');
    };

    FileUpload.prototype.getCurrentFormElement = function() {
      return this._getCurrentForm().htmlElement;
    };

    FileUpload.prototype._getCurrentFileField = function() {
      return this.current.down('input[type=file]');
    };

    FileUpload.prototype.getCurrentFileFieldElement = function() {
      var _ref;
      return (_ref = this._getCurrentFileField()) != null ? _ref.htmlElement : void 0;
    };

    FileUpload.prototype.upload = function(files) {
      var helper, old,
        _this = this;
      old = this.current;
      helper = new AsyncFileUploader({
        formElement: this.getCurrentFormElement(),
        formFieldName: this._getCurrentFileField().getAttribute('name'),
        files: files,
        listeners: {
          start: this._onUploadStart,
          finished: function() {
            return old.remove();
          }
        }
      });
      this.current.setAttribute('style', 'display: none;');
      this._createWidget();
      return helper.upload();
    };

    FileUpload.prototype._onChange = function() {
      if (this.uploadOnChange) {
        this.upload(this.getCurrentFileFieldElement().files);
      }
      return this.fireEvent('fieldChange', this);
    };

    FileUpload.prototype._onUploadStart = function() {
      var args;
      args = 1 <= arguments.length ? __slice.call(arguments, 0) : [];
      return this.fireEvent.apply(this, ['uploadStart', this].concat(__slice.call(args)));
    };

    FileUpload.prototype._setupDragEvents = function() {
      this.dropTargetElement.on('dragover', this._onDragOver);
      this.dropTargetElement.on('dragenter', this._onDragEnter);
      this.dropTargetElement.on('dragleave', this._onDragLeave);
      return this.dropTargetElement.on('drop', this._onDrop);
    };

    FileUpload.prototype._onDragOver = function(e) {
      e.preventDefault();
      if (this.draggingFiles) {
        e.dataTransfer.dropEffect = this.dropEffect;
        this.fireEvent('dragover', this, e);
      }
      return false;
    };

    FileUpload.prototype._onDragEnter = function(e) {
      e.preventDefault();
      this.draggingFiles = dataTransferContainsFiles(e.dataTransfer);
      if (this.draggingFiles) {
        this.fireEvent('dragenter', this, e);
      }
      return false;
    };

    FileUpload.prototype._onDragLeave = function(e) {
      e.preventDefault();
      if (this.draggingFiles) {
        this.draggingFiles = false;
        this.fireEvent('dragleave', this, e);
      }
      return false;
    };

    FileUpload.prototype._onDrop = function(e) {
      e.preventDefault();
      if (e.dataTransfer.files.length > 0) {
        this.fireEvent('dropFiles', e, e.dataTransfer.files);
        if (this.uploadOnChange) {
          this.upload(e.dataTransfer.files);
        }
      }
      return false;
    };

    return FileUpload;

  })(Observable);

  prevent_default_window_drophandler = function() {
    if (window.addEventListener) {
      window.addEventListener("dragover", function(e) {
        return e.preventDefault();
      }, false);
      return window.addEventListener("drop", function(e) {
        return e.preventDefault();
      }, false);
    }
  };

  window.devilry_file_upload = {
    FileUpload: FileUpload,
    AsyncFileUploader: AsyncFileUploader,
    browserInfo: browserInfo,
    FileWrapper: FileWrapper,
    prevent_default_window_drophandler: prevent_default_window_drophandler,
    Observable: Observable,
    applyOptions: applyOptions,
    HiddenIframe: HiddenIframe
  };

}).call(this);
