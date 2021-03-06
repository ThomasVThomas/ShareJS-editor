clone = (o) -> JSON.parse(JSON.stringify(o))

class NetworkProxy
    ###
    Класс, подменяющий сеть для sharejs
    ###
    state: "ok"
    constructor: (@id) ->
        @sentOps = []
        @sendCallbacks = []
        @receivedOps = []
        @receiveCallbacks = []

    send: (op) =>
        op = clone op
        op.meta = sid: @id
        @sentOps.push op
        num = @sentOps.length
        return if not @sendCallbacks[num]
        for callback in @sendCallbacks[num]
            callback(op)

    _onSend: (num, callback) ->
        @sendCallbacks[num] ?= []
        @sendCallbacks[num].push(callback)

    getSentOp: (opNum, callback) ->
        if @sentOps.length >= opNum
            callback @sentOps[opNum - 1]
        else
            @_onSend(opNum, callback)

    receive: (op) =>
        op = clone op
        return if op.meta.sid is @id    
        @receivedOps.push op
        num = @receivedOps.length
        return if not @receiveCallbacks.length
        callback = @receiveCallbacks.shift()
        callback @receivedOps.shift()

    getReceivedOp: (callback) ->
        if @receivedOps.length > 0
            callback @receivedOps.shift()
        else
            @_onReceive(callback)

    _onReceive: (callback) ->
        @receiveCallbacks.push(callback)
    
    receiveResponse: (msg) ->
        msg = clone msg
        @doc._onMessage(msg)

module.exports.NetworkProxy = NetworkProxy