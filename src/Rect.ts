import Coords = require("./Coords");
import utils = require("./utils");

class Rect {
    constructor(
            private topLeft_: Coords,
            private bottomRight_: Coords) {
    }

    get topLeft(): Coords { return this.topLeft_; }
    get bottomRight(): Coords { return this.bottomRight_; }
    get center(): Coords {
        return {x: (this.topLeft_.x + this.bottomRight_.x) / 2.0,
                y: (this.topLeft_.y + this.bottomRight_.y) / 2.0}; }
    get left(): number { return this.topLeft_.x; }
    get top(): number { return this.topLeft_.y; }
    get right(): number { return this.bottomRight_.x; }
    get bottom(): number { return this.bottomRight_.y; }
    get width(): number { return this.bottomRight_.x - this.topLeft_.x; }
    get height(): number { return this.bottomRight_.y - this.topLeft_.y; }

    distanceToPoint(point: Coords) {
        var center = this.center;
        var dx = Math.max(0, Math.abs(center.x - point.x) - this.width / 2);
        var dy = Math.max(0, Math.abs(center.y - point.y) - this.height / 2);
        if (dx == 0) {
            return dy;
        } else if (dy == 0) {
            return dx;
        }
        return utils.hypot(dx, dy);
    }

    distanceToRect(other: Rect) {
        var thisCenter = this.center;
        var otherCenter = other.center;
        var dx = Math.max(0,
                          Math.abs(thisCenter.x - otherCenter.x) -
                                (this.width + other.width) / 2);
        var dy = Math.max(0,
                          Math.abs(thisCenter.y - otherCenter.y) -
                               (this.height + other.height) / 2);
        if (dx == 0) {
            return dy;
        } else if (dy == 0) {
            return dx;
        }
        return utils.hypot(dx, dy);
    }
}

export = Rect;
