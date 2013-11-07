# Base class for all geometric figures
class PlotObject
    # Constructor
    #
    # @param impl_ [PlotObjectImpl] concrete object implementation
    # @param [String] name object name
    constructor: (@impl_, name) ->
        @name = name or @generateName()
        @children_ = []
        @setId PlotObject.lastUnusedId_
        @changed = new signals.Signal()

    id: -> @id_

    setId: (newId) ->
        delete PlotObject.allObjects_[@id_] if @id_?
        @id_ = newId
        PlotObject.allObjects_[@id_] = @
        PlotObject.lastUnusedId_ = 1 + Math.max(PlotObject.lastUnusedId_, newId)

    setName: (newName) ->
        @name = newName

    generateName: -> ""

    implName: -> @impl_.constructor.fullName

    addChild: (c) ->
        @children_.push c

    children: (recursive = false) ->
        res = @children_
        if recursive
            for c in @children_
                res = res.concat c.children true
        res

    destroy: ->
        delete PlotObject.allObjects_[@id_] if @id_?
        PlotObject.selectedObject_ = undefined if @selected()
        # TODO: remove from parent's children list
        # TODO: remove all children (-:

    encoded: ->
        # TODO escape name
        """{"id": #{@id_}, "name":"#{@name}","impl":"#{@implName()}", #{@impl_.encoded()}}"""

    # default behavior, redefined in Point class
    independent: -> false

    # TODO: move stuff about selection outta here
    @selectedObject_ = undefined
    select: ->
        PlotObject.selectedObject_ = @
    selected: ->
        PlotObject.selectedObject_ is @

    @lastUnusedId_ = 0
    @allObjects_ = {} # map from id to object
    @find = (id) ->
        PlotObject.allObjects_[id]


PlotObject.registeredImpls_ = {}
PlotObject.registerImpl = (implClass) ->
    PlotObject.registeredImpls_[implClass.fullName] = implClass
    PlotObject.registeredImpls_.length - 1

PlotObject.getImplClass = (implName) ->
    PlotObject.registeredImpls_[implName]


class PlotObjectImpl
    @register = (name) ->
        PlotObject.registerImpl @
        name


module.exports.PlotObject = PlotObject
module.exports.PlotObjectImpl = PlotObjectImpl

