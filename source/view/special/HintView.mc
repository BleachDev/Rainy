import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class HintView extends WatchUi.View {

    private var text;
    private var buttons;

    function initialize(text, buttons) {
        View.initialize();
        self.text = text;
        self.buttons = buttons;
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        var W = dc.getWidth();
        var H = dc.getHeight();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(INSTINCT_MODE ? W / 2.9 : W / 2,
                    H / 8, Graphics.FONT_LARGE, "HINT", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(W / 2, H / 2.8, Graphics.FONT_TINY, text, Graphics.TEXT_JUSTIFY_CENTER);

        if (buttons.indexOf(0) != -1) {
            drawIndicator(dc, 5.63);
        }
        if (buttons.indexOf(1) != -1) {
            drawIndicator(dc, 3.0);
        }
    }

    function drawIndicator(dc, angle) {
        var _size = 5;
        var height = 6;
        for (var i = 0; i < _size; i++) {
            var b = dc.getWidth() / 2 - height + 2;

            var x_i = b * Math.cos(angle + i * 0.06) + dc.getWidth() / 2;
            var y_i = b * Math.sin(angle + i * 0.06) + dc.getHeight() / 2;

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(x_i, y_i, height / 2);
        }
    }
}
