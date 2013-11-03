Curve = (require "./curve").Curve
PlotObject = (require "./plot_object").PlotObject
Point = (require "./point").Point

class Plot
    constructor: ->
        @points_ = []
        @curves_ = []
        @title_ = "plot"

        @changed = new signals.Signal

    add: (obj) ->
        if $.isArray obj
            @add o for o in obj
        else if obj instanceof Point
            @points_.push obj
        else if obj instanceof Curve
            @curves_.push obj

        @changed.dispatch()

    points: -> @points_

    addCurve: (c) ->
        @curves_.push(c)

    curves: -> @curves_

    encoded: ->
        head = "{\
               \"title\": \"#{@title_}\",\
               \"objects\": ["

        objs = []
        objs.push p.encoded() for p in @points_
        objs.push c.encoded() for c in @curves_

        return head + (objs.join ",") + "]}"

    @decoded = (json) ->
        plot = new Plot
        d = JSON.parse json
        plot.title_ = d.title

        d.objects.sort (x, y) -> x.id > y.id
        for obj in d.objects
            implClass = PlotObject.getImplClass obj.impl
            decodedObject = implClass.fromJSON obj
            decodedObject.setId obj.id
            decodedObject.setName obj.name
            plot.add decodedObject

        return plot


module.exports.Plot = Plot
