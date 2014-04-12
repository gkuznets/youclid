import Coords = require("../Coords");
import curve = require("./curve");
import point = require("./point");

export class Circle extends curve.Curve {
    get center(): Coords {
        throw "Not implemented";
    }
    get radius(): number {
        throw "Not implemented";
    }
    sqDist(x: number, y: number): number {
        throw "Not implemented";
    }
}

class CircleByCenterAndPoint extends Circle {
    constructor(
            private center_: point.Point,
            private point_: point.Point) {
        super();
        this.center_.addChild(this);
        this.point_.addChild(this);
    }

    get center() { return this.center_; }

    get radius() {
        var dx = this.center_.x - this.point_.x;
        var dy = this.center_.y - this.point_.y;
        return Math.sqrt(dx * dx + dy * dy);
    }

    sqDist(x, y) {
        var dx = this.center.x - x;
        var dy = this.center.y - y;
        var distToCenter = Math.sqrt(dx * dx + dy * dy);
        var dist = distToCenter - this.radius;
        return dist * dist;
    }
}

export function byCenterAndPoint(center, point): Circle {
    return new CircleByCenterAndPoint(center, point);
}


