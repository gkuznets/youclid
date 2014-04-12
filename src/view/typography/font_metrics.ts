export class Metrics {
    constructor(
        public left: number,
        public bottom: number,
        public width: number,
        public height: number) {}
}

function rowIsEmpty(row, w, data) {
    var pos = row * 4 * w;
    for (var x = 0; x < w; ++x) {
        if (data[pos] < 255 || data[pos + 1] < 255 || data[pos + 2] < 255) {
            return false
        }
        pos += 4;
    }
    return true;
}

function colPartIsEmpty(col, start, end, w, data) {
    var pos = 4 * (col + w * start);
    for (var row = start; row < end; ++row) {
        if (data[pos] < 255 || data[pos + 1] < 255 || data[pos + 2] < 255) {
            return false;
        }
        pos += 4 * w;
    }
    return true;
}

function colIsEmpty(col, w, h, data) {
    return colPartIsEmpty(col, 0, h, w, data);
}

function detectRect(data) {
    var w = data.width;
    var h = data.height;
    var pixelData = data.data;

    var top = -1;
    for (var row = 0; row < h; ++row) {
        if (!rowIsEmpty(row, w, pixelData)) {
            top = row;
            break;
        }
    }

    var bottom = -1;
    for (var row = h - 1; row > top; --row) {
        if (!rowIsEmpty(row, w, pixelData)) {
            bottom = row;
            break;
        }
    }
    if (bottom == -1) {
        bottom = h - 1;
    }

    var left = -1;
    for (var col = 0; col < w; ++col) {
        if (!colPartIsEmpty(col, top, bottom + 1, w, pixelData)) {
            left = col;
            break;
        }
    }

    var right = -1;
    for (var col = w - 1; col > left; --col) {
        if (!colPartIsEmpty(col, top, bottom + 1, w, pixelData)) {
            right = col;
            break;
        }
    }
    if (right == -1) {
        right = w - 1;
    }

    return new Metrics(left, bottom, right - left + 1, bottom - top + 1);
}

export function glyphMetrics(char: string, font: string = "") {
    return fontMetrics(font)[char];
}

function calcGlyphMetrics(char, canvas, font: string) {
    var ctx = canvas.getContext("2d");
    var w = ctx.measureText(char).width;
    var h = w * 1.5;
    canvas.width = 3 * w;
    canvas.height = 3 * h;
    ctx = canvas.getContext("2d");
    ctx.font = font;
    ctx.fillStyle = "white";
    ctx.strokeStyle = "black";
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    ctx.fillStyle = "black";
    ctx.fillText(char, w, 2 * h);

    var m = detectRect(ctx.getImageData(0, 0, canvas.width, canvas.height));
    m.left -= w;
    m.bottom -= 2 * h;
    return m;
}

var symbols = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
               "A", "B", "C", "D", "E", "F", "G", "H", "I", "J",
               "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
               "U", "V", "W", "X", "Y", "Z", "a", "b", "c", "d",
               "e", "f", "g", "h", "i", "j", "k", "l", "m", "n",
               "o", "P", "Q", "r", "s", "t", "u", "v", "w", "x",
               "y", "z"];

function calcFontMetrics(canvas: HTMLCanvasElement, font: string) {
    var metrics = {};
    symbols.forEach((char) => {
        metrics[char] = calcGlyphMetrics(char, canvas, font);
    });
    return metrics;
}

var fontMetricsCache = {};

function fontMetrics(font: string) {
    if (!(font in fontMetricsCache)) {
        var canvas = document.createElement("canvas");
        fontMetricsCache[font] = calcFontMetrics(canvas, font);
    }
    return fontMetricsCache[font];
}
