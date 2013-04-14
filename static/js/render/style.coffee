class Style
    constructor: ->
        @color_ = "rgb(0, 0, 0)"

    color: (cl) ->
        if cl? then @color_ = cl; @ else @color_

    size: (sz) ->
        if sz? then @size_ = sz; @ else @size_

    thickness: (th) ->
        if th? then @thickness_ = th; @ else @thickness_

    @defaultPointStyle = ->
        (new Style).color("rgb(200, 0, 0)").size(3)

    @defaultCurveStyle = ->
        (new Style).color("rgb(100, 200, 50)").thickness(1)
