import assert = require("./assert");
import signals = require("./signals");

class PlotObject {
    private static lastUnusedId_: number = 0;
    private static allObjects_: PlotObject[] = [];
    private static find(id: number) {
        return PlotObject.allObjects_[id];
    }

    private id_: number;
    public name: string;
    private children_: PlotObject[];
    private changed_: signals.Signal;

    constructor (name: string = "") {
        this.setId();
        this.name = name;
        this.children_ = [];
        this.changed_ = new signals.Signal();
    }

    destroy() {
        if (this.id_) {
            delete PlotObject.allObjects_[this.id_];
        }
    }

    get id() { return this.id_; }

    private setId(newId: number = undefined) {
        newId = newId || PlotObject.lastUnusedId_;
        if (this.id_) {
            if (this.id_ == newId) {
                return;
            }
            delete PlotObject.allObjects_[this.id_];
        }
        assert(!(newId in PlotObject.allObjects_));
        this.id_ = newId;
        PlotObject.allObjects_[newId] = this;
        PlotObject.lastUnusedId_ =
            Math.max(PlotObject.lastUnusedId_, newId) + 1;
    }

    children(recursive = false) {
        var result = this.children_;
        if (recursive) {
            this.children_.forEach(function(child) {
                result = result.concat(child.children(true));
            });
        }
        return result;
    }

    addChild(child) {
        this.children_.push(child);
    }

    get changed() { return this.changed_; }
}

export = PlotObject;
