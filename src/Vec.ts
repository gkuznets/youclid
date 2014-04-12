import Coords = require("./Coords");

class Vec implements Coords {
    static zero: Vec = new Vec(0, 0);

    constructor(private x_: number, private y_: number) {}

    get x() { return this.x_; }
    get y() { return this.y_; }

    get length() { return Math.sqrt(this.x_ * this.x_ + this.y_ * this.y_); }

    get perp() {
        return new Vec(-this.y_, this.x_);
    }

    get unit() {
        var len = this.length;
        return new Vec(this.x_ / len, this.y_ / len);
    }

    get neg() {
        return new Vec(-this.x_, -this.y_);
    }

    plus(vec: Vec) {
        return new Vec(this.x_ + vec.x_, this.y_ + vec.y_);
    }

    mult(s: number) {
        return new Vec(this.x_ * s, this.y_ * s);
    }

    resized(len: number) {
        var thisLen = this.length;
        var coeff = len / this.length;
        return new Vec(this.x_ * coeff, this.y_ * coeff);
    }
}

export = Vec;
