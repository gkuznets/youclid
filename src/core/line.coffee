Curve = (require "./curve").Curve
PlotObjectImpl = (require "./plot_object").PlotObjectImpl

class Line extends Curve
    constructor: (impl, name) ->
        super impl, name

    # Arbitrary point on the line
    source: ->
        @impl_.source()

    # Направляющий вектор
    dir: ->
        @impl_.dir()

    # Угол наклона
    k: ->
        @impl_.k()

    # Коэффициент a в уравнении ax + by + c = 0
    a: ->
        @impl_.a()

    # Коэффициент b в уравнении ax + by + c = 0
    b: ->
        @impl_.b()

    # Коэффициент c в уравнении ax + by + c = 0
    c: ->
        @impl_.c()

    # x в зависимости от y
    x: (y) ->
        @impl_.x y

    # y в зависимости от x
    y: (x) ->
        @impl_.y x

    sqDist: ->
        [x, y] = toCoords arguments
        @impl_.sqDist x, y

    toString: ->
       "Line " + @name + " (" + @a() + ", " + @b() + ", " + @c() + ")"


# implementations

Line.By2Points = class extends PlotObjectImpl
    @fullName = @register "Line.By2Points"

    constructor: (@p0_, @p1_) ->

    source: -> @p0_

    dir: -> null
        #{x: @p1_.x() - @p0_.x(), y: @p1_.y() - @p0_.y()}

    a: ->
        if (@p0_.y() == @p1_.y()) then 0.0 else 1.0

    b: ->
        dy = @p0_.y() - @p1_.y()
        if dy == 0
            1.0
        else
            (@p1_.x() - @p0_.x()) / dy

    c: ->
        -(@a() * @p0_.x() + @b() * @p0_.y())

    k: ->
        # -b/a
        dy = @p0_.y() - @p1_.y()
        if dy == 0
            Infinity
        else
            -(@p1_.x() - @p0_.x()) / dy

    x: (y) ->
        dy = @p1_.y() - @p0_.y()
        if 0 != dy
            @p0_.x() + (y - @p0_.y()) * (@p1_.x() - @p0_.x()) / dy
        else
            undefined

    y: (x) ->
        dx = @p1_.x() - @p0_.x()
        if 0 != dx
            @p0_.y() + (x - @p0_.x()) * (@p1_.y() - @p0_.y()) / dx
        else
            undefined

    sqDist: (x, y) ->
        dx = @p1_.x() - @p0_.x()
        dy = @p1_.y() - @p0_.y()
        dx0 = x - @p0_.x()
        dy0 = y - @p0_.y()

        return (dx0*dy*dy + dy0*dx*dx - dy*dx*(dx0 + dy0)) / (dx*dx + dy*dy)

    encoded: ->
        """ "parents":[#{@p0_.id()}, #{@p1_.id()}]"""

    @fromJSON = (json) ->
        p0 = PlotObject.find json.parents[0]
        p1 = PlotObject.find json.parents[1]
        Line.by2Points p0, p1


Line.by2Points = (p0, p1) ->
    new Line(new Line.By2Points p0, p1)


Line.Perpendicular = class extends PlotObjectImpl
    @fullName = @register "Line.Perpendicular"

    constructor: (@pt_, @line_) ->

    source: -> @pt_

    dir: -> null

    a: ->
        if @k() == Infinity then 0 else 1.0

    b: ->
        k_ = @k()
        if k_ == 0 then 0.0 else -k_

    c: ->
        if @a() == 0
            -@b() * @pt_.y()
        else
            -(@pt_.x() + @b() * @pt_.y())

    k: ->
        -1.0/@line_.k()

    x: (y) ->
        k_ = @k()
        if k_ == Infinity then undefined else k_ * y - @c()

    y: (x) ->
        k_ = @k()
        if k_ == 0 then undefined else (@a() * x + @c()) / k_

    sqDist: (x, y) ->
        # dx = 1.0
        dy = y(@pt_.x() + 1) - @pt_.x()
        dx0 = x - @pt_.x()
        dy0 = y - @pt_.y()

        return (dx0*dy*dy + dy0 - dy*(dx0 + dy0)) / (1.0 + dy*dy)

    encoded: ->
        """ "parents":[#{@pt_.id()}, #{@line_.id()}]"""

    @fromJSON = (json) ->
        p = PlotObject.find json.parents[0]
        l = PlotObject.find json.parents[1]
        new Line.perpendicular p, l

Line.perpendicular = (pt, line) ->
    new Line(new Line.Perpendicular pt, line)


Line.Parallel = class extends PlotObjectImpl
    @fullName = @register "Line.Parallel"

    constructor: (@pt_, @line_) ->

    source: -> @pt_

    dir: ->
        @line_.dir()

    a: ->
        @line_.a()

    b: ->
        @line_.b()

    c: ->
        - @a() * @pt_.x() - @b() * @pt_.y()

    k: ->
        @line_.k()

    x: (y) ->
        if @a() != 0
            - (@c() + @b() * y) / @a()
        else
            undefined

    y: (x) ->
        if @b() != 0
            - (@c() + @a() * x) / @b()
        else
            undefined

    sqDist: (x, y) ->
        # copy-pasted from perpendicular
        # dx = 1.0
        dy = y(@pt_.x() + 1) - @pt_.x()
        dx0 = x - @pt_.x()
        dy0 = y - @pt_.y()

        return (dx0*dy*dy + dy0 - dy*(dx0 + dy0)) / (1.0 + dy*dy)

    encoded: ->
        """ "parents":[#{@pt_.id()}, #{@line_.id()}]"""

    @fromJSON = (json) ->
        p = PlotObject.find json.parents[0]
        l = PlotObject.find json.parents[1]
        new Line.parallel p, l

Line.parallel = (pt, line) ->
    new Line(new Line.Parallel pt, line)


module.exports.Line = Line
