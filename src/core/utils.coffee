_ABSTRACT = ->
    throw "Call to abstract function"

class AssertionError
    constructor: (@message_ = "Assertion error") ->
    toString: -> @message_

assert = (expr, message) ->
    if not expr
        throw new AssertionError message

clone = (obj, deep = true) -> $.extend deep, {}, obj

rand = (n) ->
    Math.floor(Math.random() * n)

toCoords = (args) ->
    if args.length == 2
        args
    else if $.isArray args[0]
        args[0]
    else
        [args[0].x, args[0].y]
