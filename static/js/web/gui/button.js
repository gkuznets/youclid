var Button = function(elem) {
    this.elem_ = elem;
}

Button.prototype = {
    onClick: function(func) {
        this.elem_.onclick = func;
    }
}
