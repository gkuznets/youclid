import Coords = require("./Coords");

export function distance(a: Coords, b: Coords) {
    return hypot(a.x - b.x, a.y - b.y);
}

export function hypot(dx, dy) {
    return Math.sqrt(dx * dx + dy * dy);
}