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
            implClass = Plot.getImplClass obj.impl
            decodedObject = implClass.fromJSON obj
            decodedObject.setId obj.id
            decodedObject.setName obj.name
            plot.add decodedObject

        return plot

Plot.registeredImpls_ = {}
Plot.registerImpl = (implClass) ->
    Plot.registeredImpls_[implClass.fullName] = implClass
    Plot.registeredImpls_.length - 1

Plot.getImplClass = (implName) ->
    Plot.registeredImpls_[implName]


# Base class for all geometric figures
class PlotObject
    # Constructor
    #
    # @param impl_ [PlotObjectImpl] concrete object implementation
    # @param [String] name object name
    # @param [Style] style style used to render object
    constructor: (@impl_, name, @style) ->
        @name = name or @generateName()
        @children_ = []
        @setId PlotObject.lastUnusedId_

    id: -> @id_

    setId: (newId) ->
        delete PlotObject.allObjects_[@id_] if @id_?
        @id_ = newId
        PlotObject.allObjects_[@id_] = this
        PlotObject.lastUnusedId_ = 1 + Math.max(PlotObject.lastUnusedId_, newId)

    setName: (newName) ->
        @name = newName

    generateName: -> ""

    implName: -> @impl_.constructor.fullName

    addChild: (c) ->
        @children_.push(c)

    destroy: ->
        delete PlotObject.allObjects_[@id_] if @id_?
        PlotObject.selectedObject_ = undefined if @selected()

    encoded: ->
        # TODO escape name
        """{"id": #{@id_}, "name":"#{@name}","impl":"#{@implName()}", #{@impl_.encoded()}}"""

    @selectedObject_ = undefined
    select: ->
        PlotObject.selectedObject_ = this
    selected: ->
        PlotObject.selectedObject_ is this

    @lastUnusedId_ = 0
    @allObjects_ = {} # map from id to object
    @find = (id) ->
        PlotObject.allObjects_[id]


class PlotObjectImpl
    @register = (name) ->
        Plot.registerImpl @
        name

class Curve extends PlotObject
    constructor: (impl, name) ->
        super impl, name, Style.defaultCurveStyle()

