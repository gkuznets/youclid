toCoords = (args) ->
    if args.length == 2
        args
    else if $.isArray args[0]
        args[0]
    else
        [args[0].x, args[0].y]
