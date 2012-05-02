# This is a simple port of microevent.js to Coffeescript. I've changed the
# function names to be consistent with node.js EventEmitter.
#
# microevent.js is copyright Jerome Etienne, and licensed under the MIT license:
# https://github.com/jeromeetienne/microevent.js

nextTick = process?.nextTick || (fn) -> setTimeout fn, 0

class MicroEvent
    on: (event, fct) ->
        @_events ||= {}
        @_events[event] ||= []
        @_events[event].push(fct)
        this

    removeListener: (event, fct) ->
        @_events ||= {}
        listeners = (@_events[event] ||= [])
        
        # Sadly, there's no IE8- support for indexOf.
        i = 0
        while i < listeners.length
            listeners[i] = undefined if listeners[i] == fct
            i++

        nextTick -> listeners = (x for x in listeners when x)

        this

    removeListeners: (event) ->
        @_events ||= {}
        delete @_events[event] if @_events.hasOwnProperty(event)
        @

    emit: (event, args...) ->
        return this unless @_events?[event]
        fn.apply this, args for fn in @_events[event] when fn
        this

# mixin will delegate all MicroEvent.js function in the destination object
MicroEvent.mixin = (obj) ->
    proto = obj.prototype || obj

    # Damn closure compiler :/
    proto.on = proto['on'] = MicroEvent.prototype.on
    proto.removeListener = proto['removeListener'] = MicroEvent.prototype.removeListener
    proto.removeListeners = proto['removeListeners'] = MicroEvent.prototype.removeListeners
    proto.emit = MicroEvent.prototype.emit
    obj

module.exports = MicroEvent if module?.exports
