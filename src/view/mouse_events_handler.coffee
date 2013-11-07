MIN_DRAG_DISTANCE = 4
MAX_CLICK_DISTANCE = 2

distance = (a, b) ->
    dx = a[0] - b[0]
    dy = a[1] - b[1]
    Math.sqrt dx * dx + dy * dy

class MouseEventsHandler
    constructor: (@element_) ->
        $(@element_).mousemove (event) => @onMouseMove_ event
        $(@element_).mousedown (event) => @onMouseDown_ event
        $(@element_).mouseup (event) => @onMouseUp_ event

        @click_ = new signals.Signal()
        @mouseMove_ = new signals.Signal()
        @hoverOut_ = new signals.Signal()

        @startDrag_ = new signals.Signal()
        @drag_ = new signals.Signal()
        @dragDrop_ = new signals.Signal()

        @mouseDownCoords_ = null
        @dragStarted_ = false

    click: -> @click_
    mouseMove: -> @mouseMove_
    hoverOut: -> @hoverOut_

    startDrag: -> @startDrag_
    drag: -> @drag_
    dragDrop: -> @dragDrop_

    coords_: (event) ->
        [event.clientX - @element_.offsetLeft,
         event.clientY - @element_.offsetTop]

    onMouseMove_: (event) ->
        coords = @coords_ event
        if @mouseDownCoords_?
            if distance(coords, @mouseDownCoords_) > MIN_DRAG_DISTANCE and
                    not @dragStarted_
                @startDrag_.dispatch @mouseDownCoords_[0], @mouseDownCoords_[1]
                @dragStarted_ = true
            if @dragStarted_
                @drag_.dispatch coords[0], coords[1]
        else
            @mouseMove_.dispatch coords[0], coords[1]


    onMouseDown_: (event) ->
        @mouseDownCoords_ = @coords_ event

    onMouseUp_: (event) ->
        coords = @coords_ event
        if @dragStarted_
            @dragDrop_.dispatch coords[0], coords[1]
            @dragStarted_ = false
        else if distance(@mouseDownCoords_, coords) < MAX_CLICK_DISTANCE
            @click_.dispatch @mouseDownCoords_[0], @mouseDownCoords_[1]

        @mouseDownCoords_ = null

module.exports.MouseEventsHandler = MouseEventsHandler
