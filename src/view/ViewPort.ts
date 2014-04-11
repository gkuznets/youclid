class ViewPort {
    private width_: number;
    private height_: number;
    private scale_: number;
    private rcx_: number;
    private rcy_: number;

    constructor(width, height) {
        this.width_ = width;
        this.height_ = height;
        this.scale_ = 2;
        // real center coordinates
        this.rcx_ = 0;
        this.rcy_ = 0;
    }

    get width() { return this.width_; }
    get height() { return this.height_; }

    // zoom around pixel coordinates (px, py)
    zoom(px, py, factor) {
        var newCenter = this.revMap(px, py);
        this.rcx_ = newCenter.x;
        this.rcy_ = newCenter.y;
        this.scale_ *= Math.pow(2, factor);
    }

    // move by pixel coordinates
    move(pxdx, pxdy) {
        this.rcx_ -= this.revMapDist(pxdx);
        this.rcy_ -= this.revMapDist(pxdy);
    }

    mapX(rx) {
        return this.scale_ * (rx - this.rcx_) + this.width_ / 2;
    }

    mapY(ry) {
        return this.scale_ * (this.rcy_ - ry) + this.height_ / 2;
    }

    // map real coordinates to pixel coordinates
    map(rx, ry) {
        return [ this.mapX(rx), this.mapY(ry) ]
    }

    revMapX(pxx: number) {
        return (pxx - this.width_ / 2) / this.scale_ + this.rcx_;
    }

    revMapY(pxy: number) {
        return this.rcy_ + (this.height_ / 2 - pxy) / this.scale_;
    }

    // map pixel coordinates to real ones
    revMap(pxx: number, pxy: number) {
        return {x: this.revMapX(pxx), y: this.revMapY(pxy)};
    }

    // map real distance to pixel distance
    mapDist(rd) {
        return rd * this.scale_;
    }

    revMapDist(pd) {
        return pd / this.scale_;
    }
}

export = ViewPort;
