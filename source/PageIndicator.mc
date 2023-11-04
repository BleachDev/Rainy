import Toybox.Graphics;
import Toybox.Lang;

//! Draws a graphic indicating which page the user is currently on
class PageIndicator {

    private var _size as Number;

    public function initialize(size as Number) {
        _size = size;
    }

    //! Draw the graphic
    public function draw(dc as Dc, selectedIndex as Number) as Void {
        var height = dc.getWidth() / 25;
        for (var i = 0; i < _size; i++) {
            var b = dc.getWidth() / 2 - height + 2;

            //round page indicator
            var x_i = b * Math.cos(3.14 + (_size / 2) * 0.12 - i * 0.12) + dc.getWidth() / 2;
            var y_i = b * Math.sin(3.14 + (_size / 2) * 0.12 - i * 0.12) + dc.getWidth() / 2;

            if (i == selectedIndex) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(x_i, y_i, height / 2);
            } else {
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.drawCircle(x_i, y_i, height / 2);
            }
        }
    }
}