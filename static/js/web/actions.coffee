targetCoords = (event) ->
    x: event.pageX - event.target.offsetLeft,
    y: event.pageY - event.target.offsetTop

class Action
    @current = null

    @classes_ = {}
    @registerClass =(clsStr, actionClass) ->
        Action.classes_[clsStr] = actionClass

    @assignAll = (canvas, render) ->
        for cls, actionClass of Action.classes_
            elem = $ ".#{cls}"
            if elem.length > 0
                (new actionClass canvas, render).assign elem[0]
            else
                console.log ".#{cls} not found"

    assign: (button) ->
        $(button).click => @activate()
        $(button).onclick = => @activate()

    constructor: (@canvas_, @render_) ->

    activate: ->
        Action.current?.deactivate()

        Action.current = this
        $(@canvas_).bind 'mousedown', (event) =>
            @onMouseDown event
        $(@canvas_).bind 'mousemove', (event) =>
            @onMouseMove event
        $(@canvas_).bind 'mouseup', (event) =>
            @onMouseUp event
        $(@canvas_).bind 'click', (event) =>
            @onClick event

    deactivate: ->
        $(@canvas_).unbind('mouseover')
                   .unbind('mousemove')
                   .unbind('mouseup')
                   .unbind('click')

    onClick: (event) ->
    onMouseDown: (event) ->
    onMouseUp: (event) ->
    onMouseMove: (event) ->


Action.registerClass "select-action", class extends Action
    activate: ->
        super
        @selectedPoint_ = null

    onMouseDown: (e) ->
        # Checking if there is some object under mouse cursor
        obj = @render_.findObject targetCoords e
        if obj
            $("#selectionInfo")[0].innerHTML = obj.toString()
            @selectedPoint_ = obj
            obj.select()
            render.run()

    onMouseMove: (e) ->
        if @selectedPoint_?
            if @selectedPoint_.independent()
                pos = render.toReal targetCoords e
                @selectedPoint_.setX(pos.x).setY(pos.y)
                @render_.run()
            else
                console.log "trying to move dependent point"

    onMouseUp: (e) ->
        @selectedPoint_ = null


Action.registerClass "save-action", class extends Action
    activate: ->
        super()
        encoded_plot = plot.encoded()
        $.post \
            "/save/",
            encoded_plot: encoded_plot,
            (data, success, xhr) ->
                alert data


Action.registerClass "load-action", class extends Action
    activate: ->
        super()
        $.get \
            "/load/",
            (data, textStatus, xhr) ->
                plot = Plot.decoded data
                render = new Render plot, plotCanvas
                render.run()


Action.registerClass "point-action", class extends Action
    onClick: (e) ->
        pos = @render_.toReal targetCoords e
        plot.add Point.independent pos.x, pos.y

# Mid-point
Action.registerClass "midpoint-action", class extends Action
    activate: ->
        super()
        @firtPoint_ = null

    onClick: (e) ->
        pt = @render_.findPoint targetCoords e
        if not pt
            # adding new point
            pos = render.toReal targetCoords e
            pt = Point.independent pos.x, pos.y
            plot.add pt

        if not @firstPoint_
            @firstPoint_ = pt
        else
            plot.add Point.midpoint @firstPoint_, pt
            @firstPoint_ = null

Action.registerClass "line-action", class extends Action
    activate: ->
        super()
        @firstPoint_ = null

    onClick: (e) ->
        pt = @render_.findPoint targetCoords e
        if not pt
            # adding new point
            pos = render.toReal targetCoords e
            pt = Point.independent pos.x, pos.y
            plot.add pt

        if not @firstPoint_
            @firstPoint_ = pt
        else
            plot.add Line.by2Points @firstPoint_, pt
            @firstPoint_ = null


Action.registerClass "circlebcp-action", class extends Action
    activate: ->
        super
        @center_ = null

    onClick: (e) ->
        pt = @render_.findPoint targetCoords e
        if not pt
            # adding new point
            pos = @render_.toReal targetCoords e
            pt = Point.independent pos.x, pos.y, true
            plot.add pt

        if not @center_
            @center_ = pt
        else
            plot.add Circle.byCenterAndPoint @center_, pt
            @center_ = null


Action.registerClass "ln-crv-int-action", class extends Action
    activate: ->
        super
        @firstCurve_ = null

    onClick: (e) ->
        curve = render.findCurve targetCoords e
        if curve
            if not @firstCurve_
                @firstCurve_ = curve
            else if curve != @firstCurve_
                intersection = new Intersection @firstCurve_, curve
                plot.add point for point in intersection
                @firstCurve_ = null


Action.registerClass "parallel-action", class extends Action
    activate: ->
        super
        @point_ = null
        @line_ = null

    onClick: (e) ->
        pt = @render_.findPoint targetCoords e
        if pt
            @point_ = pt
        else
            line = render.findCurve targetCoords e
            if line and line instanceof Line
                @line_ = line

        if @line_ and @point_
            plot.add Line.parallel @point_, @line_
            @point_ = null
            @line_ = null


Action.registerClass "perpendicular-action", class extends Action
    activate: ->
        super
        @point_ = null
        @line_ = null

    onClick: (e) ->
        pt = @render_.findPoint targetCoords e
        if pt
            @point_ = pt
        else
            line = render.findCurve targetCoords e
            if line and line instanceof Line
                @line_ = line

        if @line_ and @point_
            plot.add Line.perpendicular @point_, @line_
            @point_ = null
            @line_ = null

Action.registerClass "zoom", class extends Action
    onClick: (e) ->
        @render_.zoomIn targetCoords e
