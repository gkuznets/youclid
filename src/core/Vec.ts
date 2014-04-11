import Coords = require("./Coords");

class Vec implements Coords {
    constructor(private x_: number, private y_: number) {}

    get x() { return this.x_; }
    get y() { return this.y_; }

    get perp() {
        return new Vec(-this.y_, this.x_);
    }
}

export = Vec;

