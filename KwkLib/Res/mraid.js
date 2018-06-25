(function() {
  var mraid = window.mraid = {};

  //////////////////////////////////////////////////////////////////////////////////////////////////

  // Bridge interface to SDK

  var bridge = window.mraidbridge = {
    nativeSDKFiredReady: false,
    nativeCallQueue: [],
    nativeCallInFlight: false,
    lastSizeChangeProperties: null
  };

  bridge.fireChangeEvent = function(properties) {
    for (var p in properties) {
      if (properties.hasOwnProperty(p)) {
        // Change handlers defined by MRAID below
        var handler = changeHandlers[p];
        handler(properties[p]);
      }
    }
  };

  bridge.nativeCallComplete = function(command) {
    console.log("nativeCallComplete: " + command);
    if (this.nativeCallQueue.length === 0)
    {
      this.nativeCallInFlight = false;
      return;
    }

    var nextCall = this.nativeCallQueue.pop();
    this.callNative(nextCall);
  };

 bridge.executeNativeCall = function(args)
 {
    console.log("executeNativeCall: " + args);
    
    if (!this.nativeSDKFiredReady)
    {
        console.log('rejecting ' + command + ' because mraid is not ready');
        bridge.notifyErrorEvent('mraid is not ready', command);
        return;
    }
 
    if (this.nativeCallInFlight)
    {
        this.nativeCallQueue.push(args);
    }
    else
    {
         this.nativeCallInFlight = true;
         this.callNative(args);
    }
  };
 
 bridge.callNative = function(args)
 {
     var funcName = args.shift();
     mobileNative[funcName].apply(mobileNative, args);
 };

  bridge.setCurrentPosition = function(x, y, width, height) {
    console.log("setCurrentPosition x: " + x + " y:" + y + " width: " + width + "height" + height);
    currentPosition = {
      x: x,
      y: y,
      width: width,
      height: height
    };
    broadcastEvent(EVENTS.INFO, 'Set current position to ' + stringify(currentPosition));
  };

  bridge.setDefaultPosition = function(x, y, width, height) {
    console.log("setDeafultPos x: " + x + " y:" + y + " width: " + width + "height" + height);

    defaultPosition = {
      x: x,
      y: y,
      width: width,
      height: height
    };
    broadcastEvent(EVENTS.INFO, 'Set default position to ' + stringify(defaultPosition));
  };
  
  bridge.setMaxSize = function(width, height) {
    
    console.log("setMaxSize width: " + width + "height" + height);
    
    maxSize = {
      width: width,
      height: height
    };

    expandProperties.width = width;
    expandProperties.height = height;

    broadcastEvent(EVENTS.INFO, 'Set max size to ' + stringify(maxSize));
  };

  bridge.setPlacementType = function(_placementType) {
    console.log("setPlacementType: " + _placementType);
    placementType = _placementType;
    broadcastEvent(EVENTS.INFO, 'Set placement type to ' + stringify(placementType));
  };

  bridge.setScreenSize = function(width, height) {

    console.log("setScreenSize width: " + width + "height" + height);

    screenSize = {
      width: width,
      height: height
    };
    broadcastEvent(EVENTS.INFO, 'Set screen size to ' + stringify(screenSize));
  };

  bridge.setState = function(_state) 
  {
    console.log("setState: " + _state);
 
    state = _state;
    broadcastEvent(EVENTS.INFO, 'Set state to ' + stringify(state));
    broadcastEvent(EVENTS.STATECHANGE, state);
  };

  bridge.setIsViewable = function(_isViewable) {
    isViewable = _isViewable;
    broadcastEvent(EVENTS.INFO, 'Set isViewable to ' + stringify(isViewable));
    broadcastEvent(EVENTS.VIEWABLECHANGE, isViewable);
  };

  bridge.setSupports = function(sms, tel, calendar, storePicture, inlineVideo) {
    console.log("supports: sms:" + sms + " tel:" + tel + " calendar:" + calendar + " storePicture:" + storePicture + " inlineVideo: " + inlineVideo);
    supportProperties = {
      sms: sms,
      tel: tel,
      calendar: calendar,
      storePicture: storePicture,
      inlineVideo: inlineVideo
    };
  };

  bridge.notifyReadyEvent = function() {
    this.nativeSDKFiredReady = true;
    broadcastEvent(EVENTS.READY);
  };

  bridge.notifyErrorEvent = function(message, action) {
    broadcastEvent(EVENTS.ERROR, message, action);
  };

  // Temporary aliases while we migrate to the new API
  bridge.fireReadyEvent = bridge.notifyReadyEvent;
  bridge.fireErrorEvent = bridge.notifyErrorEvent;

  bridge.notifySizeChangeEvent = function(width, height) {
    if (this.lastSizeChangeProperties &&
          width == this.lastSizeChangeProperties.width && height == this.lastSizeChangeProperties.height) {
      return;
    }

    console.log("notifySizeChangeEvent. New Size:(" + width + "," + height + ")");

    this.lastSizeChangeProperties = {
        width: width,
        height: height
    };
    broadcastEvent(EVENTS.SIZECHANGE, width, height);
  };

  bridge.notifyStateChangeEvent = function() {
    if (state === STATES.LOADING) {
      broadcastEvent(EVENTS.INFO, 'Native SDK initialized.');
    }

    broadcastEvent(EVENTS.INFO, 'Set state to ' + stringify(state));
    broadcastEvent(EVENTS.STATECHANGE, state);
  };

  bridge.notifyViewableChangeEvent = function() {
    broadcastEvent(EVENTS.INFO, 'Set isViewable to ' + stringify(isViewable));
    broadcastEvent(EVENTS.VIEWABLECHANGE, isViewable);
  };


  // Constants. ////////////////////////////////////////////////////////////////////////////////////

  var VERSION = mraid.VERSION = '2.0';

  var STATES = mraid.STATES = {
    LOADING: 'loading',
    DEFAULT: 'default',
    EXPANDED: 'expanded',
    HIDDEN: 'hidden',
    RESIZED: 'resized'
  };

  var EVENTS = mraid.EVENTS = {
    ERROR: 'error',
    INFO: 'info',
    READY: 'ready',
    STATECHANGE: 'stateChange',
    VIEWABLECHANGE: 'viewableChange',
    SIZECHANGE: 'sizeChange'
  };

  var PLACEMENT_TYPES = mraid.PLACEMENT_TYPES = {
    UNKNOWN: 'unknown',
    INLINE: 'inline',
    INTERSTITIAL: 'interstitial'
  };

  // External MRAID state: may be directly or indirectly modified by the ad JS. ////////////////////

  // Properties which define the behavior of an expandable ad.
  var expandProperties = {
    width: false,
    height: false,
    useCustomClose: false,
    isModal: true
  };

  var resizeProperties = {
    width: false, 
    height: false,
    offsetX: false, 
    offsetY: false,
    customClosePosition: 'top-right',
    allowOffscreen: true
  };

  var orientationProperties = {
    allowOrientationChange: true,
    forceOrientation: "none"
  };

  var supportProperties = {
    sms: false,
    tel: false,
    calendar: false,
    storePicture: false,
    inlineVideo: false
  };

  // default is undefined so that notifySizeChangeEvent can track changes
  var lastSizeChangeProperties;

  var maxSize = {};

  var currentPosition = {};

  var defaultPosition = {};

  var screenSize = {};

  var hasSetCustomClose = false;

  var listeners = {};

  // Internal MRAID state. Modified by the native SDK. /////////////////////////////////////////////

  var state = STATES.LOADING;

  var isViewable = false;

  var placementType = PLACEMENT_TYPES.UNKNOWN;

  var hostSDKVersion = {
    'major': 0,
    'minor': 0,
    'patch': 0
  };

  //////////////////////////////////////////////////////////////////////////////////////////////////

  var EventListeners = function(event) {
    this.event = event;
    this.count = 0;
    var listeners = {};

    this.add = function(func) {
      var id = String(func);
      if (!listeners[id]) {
        listeners[id] = func;
        this.count++;
      }
    };

    this.remove = function(func) {
      var id = String(func);
      if (listeners[id]) {
        listeners[id] = null;
        delete listeners[id];
        this.count--;
        return true;
      } else {
        return false;
      }
    };

    this.removeAll = function() {
      for (var id in listeners) {
        if (listeners.hasOwnProperty(id)) this.remove(listeners[id]);
      }
    };

    this.broadcast = function(args) {
      for (var id in listeners) {
        if (listeners.hasOwnProperty(id)) listeners[id].apply(mraid, args);
      }
    };

    this.toString = function() {
      var out = [event, ':'];
      for (var id in listeners) {
        if (listeners.hasOwnProperty(id)) out.push('|', id, '|');
      }
      return out.join('');
    };
  };

  var broadcastEvent = function() {
    var args = new Array(arguments.length);
    var l = arguments.length;
    for (var i = 0; i < l; i++) args[i] = arguments[i];
    var event = args.shift();
    if (listeners[event]) listeners[event].broadcast(args);
  };

  var contains = function(value, array) {
    for (var i in array) {
      if (array[i] === value) return true;
    }
    return false;
  };

  var clone = function(obj) {
    if (obj === null) return null;
    var f = function() {};
    f.prototype = obj;
    return new f();
  };

  var stringify = function(obj) {
    if (typeof obj === 'object') {
      var out = [];
      if (obj.push) {
        // Array.
        for (var p in obj) out.push(obj[p]);
        return '[' + out.join(',') + ']';
      } else {
        // Other object.
        for (var p in obj) out.push("'" + p + "': " + obj[p]);
        return '{' + out.join(',') + '}';
      }
    } else return String(obj);
  };

  var trim = function(str) {
    return str.replace(/^\s+|\s+$/g, '');
  };

  // Functions that will be invoked by the native SDK whenever a "change" event occurs.
  var changeHandlers = {
    state: function(val) {
      if (state === STATES.LOADING) {
        broadcastEvent(EVENTS.INFO, 'Native SDK initialized.');
      }
      state = val;
      broadcastEvent(EVENTS.INFO, 'Set state to ' + stringify(val));
      broadcastEvent(EVENTS.STATECHANGE, state);
    },

    viewable: function(val) {
      isViewable = val;
      broadcastEvent(EVENTS.INFO, 'Set isViewable to ' + stringify(val));
      broadcastEvent(EVENTS.VIEWABLECHANGE, isViewable);
    },

    placementType: function(val) {
      broadcastEvent(EVENTS.INFO, 'Set placementType to ' + stringify(val));
      placementType = val;
    },

    sizeChange: function(val) {
      broadcastEvent(EVENTS.INFO, 'Set screenSize to ' + stringify(val));
      for (var key in val) {
        if (val.hasOwnProperty(key)) screenSize[key] = val[key];
      }
    },

    supports: function(val) {
      broadcastEvent(EVENTS.INFO, 'Set supports to ' + stringify(val));
      supportProperties = val;
    },

    hostSDKVersion: function(val) {
      // val is expected to be formatted like 'X.Y.Z[-+]identifier'.
      var versions = val.split('.').map(function(version) {
        return parseInt(version, 10);
      }).filter(function(version) {
        return version >= 0;
      });

      if (versions.length >= 3) {
        hostSDKVersion['major'] = parseInt(versions[0], 10);
        hostSDKVersion['minor'] = parseInt(versions[1], 10);
        hostSDKVersion['patch'] = parseInt(versions[2], 10);
        broadcastEvent(EVENTS.INFO, 'Set hostSDKVersion to ' + stringify(hostSDKVersion));
      }
    }
  };

  var validate = function(obj, validators, action, merge) {
    if (!merge) {
      // Check to see if any required properties are missing.
      if (obj === null) {
        broadcastEvent(EVENTS.ERROR, 'Required object not provided.', action);
        return false;
      } else {
        for (var i in validators) {
          if (validators.hasOwnProperty(i) && obj[i] === undefined) {
            broadcastEvent(EVENTS.ERROR, 'Object is missing required property: ' + i, action);
            return false;
          }
        }
      }
    }

    for (var prop in obj) {
      var validator = validators[prop];
      var value = obj[prop];
      if (validator && !validator(value)) {
        // Failed validation.
        broadcastEvent(EVENTS.ERROR, 'Value of property ' + prop + ' is invalid: ' + value, action);
        return false;
      }
    }
    return true;
  };

  var expandPropertyValidators = {
    useCustomClose: function(v) { return (typeof v === 'boolean'); },
  };

  //////////////////////////////////////////////////////////////////////////////////////////////////

  mraid.addEventListener = function(event, listener) {
    if (!event || !listener) {
      broadcastEvent(EVENTS.ERROR, 'Both event and listener are required.', 'addEventListener');
    } else if (!contains(event, EVENTS)) {
      broadcastEvent(EVENTS.ERROR, 'Unknown MRAID event: ' + event, 'addEventListener');
    } else {
      if (!listeners[event]) {
        listeners[event] = new EventListeners(event);
      }
      listeners[event].add(listener);
    }
  };

  mraid.close = function() 
  {
    console.log("close");

    if (state === STATES.HIDDEN) 
    {
      broadcastEvent(EVENTS.ERROR, 'Ad cannot be closed when it is already hidden.',
        'close');
    } else bridge.executeNativeCall(['close']);
  };

  mraid.expand = function(URL) {
    if (!(this.getState() === STATES.DEFAULT || this.getState() === STATES.RESIZED)) 
    {
      broadcastEvent(EVENTS.ERROR, 'Ad can only be expanded from the default or resized state.', 'expand');
    } 
    else 
    {
      var args = ['expand',URL, expandProperties.useCustomClose];
      bridge.executeNativeCall(args);
    }
  };

  mraid.getExpandProperties = function() {
    var properties = {
      width: expandProperties.width,
      height: expandProperties.height,
      useCustomClose: expandProperties.useCustomClose,
      isModal: expandProperties.isModal
    };
    return properties;
  };


  mraid.getCurrentPosition = function() {
    console.log("getCurrentPosition x: " + currentPosition.x + " y:" + currentPosition.y + " width: " + currentPosition.width + "height" + currentPosition.height);
    return {
      x: currentPosition.x,
      y: currentPosition.y,
      width: currentPosition.width,
      height: currentPosition.height
    };
  };

  mraid.getDefaultPosition = function() {
    console.log("getDefaultPosition x: " + defaultPosition.x + " y:" + defaultPosition.y + " width: " + defaultPosition.width + "height" + defaultPosition.height);
    return {
      x: defaultPosition.x,
      y: defaultPosition.y,
      width: defaultPosition.width,
      height: defaultPosition.height
    };
  };

  mraid.getMaxSize = function() {
    console.log("getMaxSize width: " + maxSize.width + " height: " + maxSize.height);
    return {
      width: maxSize.width,
      height: maxSize.height
    };
  };

  mraid.getPlacementType = function() {
    return placementType;
  };

  mraid.getScreenSize = function() {
    return {
      width: screenSize.width,
      height: screenSize.height
    };
  };

  mraid.getState = function() {
    return state;
  };

  mraid.isViewable = function() {
    return isViewable;
  };

  mraid.getVersion = function() {
    return mraid.VERSION;
  };

  mraid.open = function(URL) {
    if (!URL) broadcastEvent(EVENTS.ERROR, 'URL is required.', 'open');
    else bridge.executeNativeCall(['open', URL]);
  };

  mraid.removeEventListener = function(event, listener) {
    if (!event) {
      broadcastEvent(EVENTS.ERROR, 'Event is required.', 'removeEventListener');
      return;
    }

    if (listener) {
      // If we have a valid event, we'll try to remove the listener from it.
      var success = false;
      if (listeners[event]) {
        success = listeners[event].remove(listener);
      }

      // If we didn't have a valid event or couldn't remove the listener from the event, broadcast an error and return early.
      if (!success) {
        broadcastEvent(EVENTS.ERROR, 'Listener not currently registered for event.', 'removeEventListener');
        return;
      }

    } else if (!listener && listeners[event]) {
      listeners[event].removeAll();
    }

    if (listeners[event] && listeners[event].count === 0) {
      listeners[event] = null;
      delete listeners[event];
    }
  };

  mraid.setExpandProperties = function(properties) {
    if (validate(properties, expandPropertyValidators, 'setExpandProperties', true)) 
    {
      if (properties.hasOwnProperty('useCustomClose')) 
      {
        expandProperties.useCustomClose = properties.useCustomClose;
      }
    }
  };

  mraid.useCustomClose = function(shouldUseCustomClose)
  {
    expandProperties.useCustomClose = shouldUseCustomClose;
    hasSetCustomClose = true;
  };

  // MRAID 2.0 APIs ////////////////////////////////////////////////////////////////////////////////

  mraid.createCalendarEvent = function(parameters) {
    CalendarEventParser.initialize(parameters);
    if (CalendarEventParser.parse())
    {
      bridge.executeNativeCall(['createCalendarEvent',CalendarEventParser.arguments]);
    }
    else
    {
      broadcastEvent(EVENTS.ERROR, CalendarEventParser.errors[0], 'createCalendarEvent');
    }
  };

  mraid.supports = function(feature) {
    return supportProperties[feature];
  };

  mraid.playVideo = function(uri) {
    if (!mraid.isViewable()) {
      broadcastEvent(EVENTS.ERROR, 'playVideo cannot be called until the ad is viewable', 'playVideo');
      return;
    }

    if (!uri) {
      broadcastEvent(EVENTS.ERROR, 'playVideo must be called with a valid URI', 'playVideo');
    } else {
      bridge.executeNativeCall(['playVideo', uri]);
    }
  };

  mraid.storePicture = function(uri) {
    if (!mraid.isViewable()) {
      broadcastEvent(EVENTS.ERROR, 'storePicture cannot be called until the ad is viewable', 'storePicture');
      return;
    }

    if (!uri) {
      broadcastEvent(EVENTS.ERROR, 'storePicture must be called with a valid URI', 'storePicture');
    } else {
      bridge.executeNativeCall(['storePicture', uri]);
    }
  };


  var resizePropertyValidators = {
    width: function(v) {
      return !isNaN(v) && v > 0; 
    },
    height: function(v) {
      return !isNaN(v) && v > 0; 
    },
    offsetX: function(v) {
      return !isNaN(v);
    },
    offsetY: function(v) {
      return !isNaN(v);
    },
    customClosePosition: function(v) {
      return (typeof v === 'string' && 
        ['top-right', 'bottom-right', 'top-left', 'bottom-left', 'center', 'top-center', 'bottom-center'].indexOf(v) > -1);
    },
    allowOffscreen: function(v) {
      return (typeof v === 'boolean');
    }
  };

  mraid.setOrientationProperties = function(properties) {

    if (properties.hasOwnProperty('allowOrientationChange')) {
      orientationProperties.allowOrientationChange = properties.allowOrientationChange;
    }

    if (properties.hasOwnProperty('forceOrientation')) {
      orientationProperties.forceOrientation = properties.forceOrientation;
    }

    var args = ['setOrientationProperties', orientationProperties.allowOrientationChange, orientationProperties.forceOrientation];
    bridge.executeNativeCall(args);
  };

  mraid.getOrientationProperties = function() {
    return {
      allowOrientationChange: orientationProperties.allowOrientationChange,
      forceOrientation: orientationProperties.forceOrientation
    };
  };

  mraid.resize = function() {
 
    console.log("getstate: " + this.getState());
    if (!(this.getState() === STATES.DEFAULT || this.getState() === STATES.RESIZED)) {
      broadcastEvent(EVENTS.ERROR, 'Ad can only be resized from the default or resized state.', 'resize');
    } else if (!resizeProperties.width || !resizeProperties.height) {
      broadcastEvent(EVENTS.ERROR, 'Must set resize properties before calling resize()', 'resize');
    } else {
      var args = ['resize',
        resizeProperties.offsetX || 0,
        resizeProperties.offsetY || 0,
        resizeProperties.width,
        resizeProperties.height,
        resizeProperties.customClosePosition,
        !!resizeProperties.allowOffscreen
        ];

      bridge.executeNativeCall(args);
    } 
  };

  mraid.getResizeProperties = function() {
    var properties = {
      width: resizeProperties.width,
      height: resizeProperties.height,
      offsetX: resizeProperties.offsetX,
      offsetY: resizeProperties.offsetY,
      customClosePosition: resizeProperties.customClosePosition,
      allowOffscreen: resizeProperties.allowOffscreen
    };
    return properties;
  };

  mraid.setResizeProperties = function(properties) {
    if (validate(properties, resizePropertyValidators, 'setResizeProperties', true)) {

      var desiredProperties = ['width', 'height', 'offsetX', 'offsetY', 'customClosePosition', 'allowOffscreen'];

      var length = desiredProperties.length;

      for (var i = 0; i < length; i++) {
        var propname = desiredProperties[i];
        if (properties.hasOwnProperty(propname)) {
          resizeProperties[propname] = properties[propname];
        }
      }
    }
  };

  // Determining SDK version ///////////////////////////////////////////////////////////////////////

  mraid.getHostSDKVersion = function() {
    return hostSDKVersion;
  }

  // Calendar helpers //////////////////////////////////////////////////////////////////////////////

  var CalendarEventParser = {
    initialize: function(parameters) {
      this.parameters = parameters;
      this.errors = [];
      this.arguments = [];
    },

    parse: function() {
      if (!this.parameters) {
        this.errors.push('The object passed to createCalendarEvent cannot be null.');
      } else {
        this.parseDescription();
        this.parseLocation();
        this.parseSummary();
        this.parseStartAndEndDates();
        this.parseReminder();
        this.parseRecurrence();
        this.parseTransparency();
      }

      var errorCount = this.errors.length;
      if (errorCount) {
        this.arguments.length = 0;
      }

      return (errorCount === 0);
    },

    parseDescription: function() {
      this._processStringValue('description');
    },

    parseLocation: function() {
      this._processStringValue('location');
    },

    parseSummary: function() {
      this._processStringValue('summary');
    },

    parseStartAndEndDates: function() {
      this._processDateValue('start');
      this._processDateValue('end');
    },

    parseReminder: function() {
      var reminder = this._getParameter('reminder');
      if (!reminder) {
        return;
      }

      if (reminder < 0) {
        this.arguments.push('relativeReminder');
        this.arguments.push(parseInt(reminder) / 1000);
      } else {
        this.arguments.push('absoluteReminder');
        this.arguments.push(reminder);
      }
    },

    parseRecurrence: function() {
      var recurrenceDict = this._getParameter('recurrence');
      if (!recurrenceDict) {
        return;
      }

      this.parseRecurrenceInterval(recurrenceDict);
      this.parseRecurrenceFrequency(recurrenceDict);
      this.parseRecurrenceEndDate(recurrenceDict);
      this.parseRecurrenceArrayValue(recurrenceDict, 'daysInWeek');
      this.parseRecurrenceArrayValue(recurrenceDict, 'daysInMonth');
      this.parseRecurrenceArrayValue(recurrenceDict, 'daysInYear');
      this.parseRecurrenceArrayValue(recurrenceDict, 'monthsInYear');
    },

    parseTransparency: function() {
      var validValues = ['opaque', 'transparent'];

      if (this.parameters.hasOwnProperty('transparency')) {
        var transparency = this.parameters.transparency;
        if (contains(transparency, validValues)) {
          this.arguments.push('transparency');
          this.arguments.push(transparency);
        } else {
          this.errors.push('transparency must be opaque or transparent');
        }
      }
    },

    parseRecurrenceArrayValue: function(recurrenceDict, kind) {
      if (recurrenceDict.hasOwnProperty(kind)) {
        var array = recurrenceDict[kind];
        if (!array || !(array instanceof Array)) {
          this.errors.push(kind + ' must be an array.');
        } else {
          var arrayStr = array.join(',');
          this.arguments.push(kind);
          this.arguments.push(arrayStr);
        }
      }
    },

    parseRecurrenceInterval: function(recurrenceDict) {
      if (recurrenceDict.hasOwnProperty('interval')) {
        var interval = recurrenceDict.interval;
        if (!interval) {
          this.errors.push('Recurrence interval cannot be null.');
        } else {
          this.arguments.push('interval');
          this.arguments.push(interval);
        }
      } else {
        // If a recurrence rule was specified without an interval, use a default value of 1.
        this.arguments.push('interval');
        this.arguments.push(1);
      }
    },

    parseRecurrenceFrequency: function(recurrenceDict) {
      if (recurrenceDict.hasOwnProperty('frequency')) {
        var frequency = recurrenceDict.frequency;
        var validFrequencies = ['daily', 'weekly', 'monthly', 'yearly'];
        if (contains(frequency, validFrequencies)) {
          this.arguments.push('frequency');
          this.arguments.push(frequency);
        } else {
          this.errors.push('Recurrence frequency must be one of: "daily", "weekly", "monthly", "yearly".');
        }
      }
    },

    parseRecurrenceEndDate: function(recurrenceDict) {
      var expires = recurrenceDict.expires;

      if (!expires) {
        return;
      }

      this.arguments.push('expires');
      this.arguments.push(expires);
    },

    _getParameter: function(key) {
      if (this.parameters.hasOwnProperty(key)) {
        return this.parameters[key];
      }

      return null;
    },

    _processStringValue: function(kind) {
      if (this.parameters.hasOwnProperty(kind)) {
        var value = this.parameters[kind];
        this.arguments.push(kind);
        this.arguments.push(value);
      }
    },

    _processDateValue: function(kind) {
      if (this.parameters.hasOwnProperty(kind)) {
        var dateString = this._getParameter(kind);
        this.arguments.push(kind);
        this.arguments.push(dateString);
      }
    }
  };
}());
