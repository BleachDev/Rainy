import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class BaseView extends WatchUi.View {

    function initialize() {
        View.initialize();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        var W = dc.getWidth();
        var H = dc.getHeight();
        onDraw(dc, W, H, H / (INSTINCT_MODE || LOWTEXT_MODE ? 9 : 13));
    }

    function onDraw(dc as Dc, W as Number, H as Number, FONT_HEIGHT as Number) as Void {
    }

    function drawHeader(dc as Dc, W as Number, H as Number, text as String) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(INSTINCT_MODE ? W / 2.9 : W / 2,
                    text.length() > 12 ? H / 15 : H / 26,
                    text.length() > 15 ? Graphics.FONT_TINY : text.length() > 12 ? Graphics.FONT_SMALL : Graphics.FONT_MEDIUM,
                    text,
                    Graphics.TEXT_JUSTIFY_CENTER);
    }

    public function drawIndicator(dc as Dc, selectedIndex as Number) as Void {
        var height = dc.getWidth() / 25;
        for (var i = 0; i < BaseDelegate.pageCount; i++) {
            var b = dc.getWidth() / 2 - height + 2;

            //round page indicator
            var x_i = b * Math.cos(3.14 + ((BaseDelegate.pageCount - 1f) / 2) * 0.12 - i * 0.12) + dc.getWidth() / 2;
            var y_i = b * Math.sin(3.14 + ((BaseDelegate.pageCount - 1f) / 2) * 0.12 - i * 0.12) + dc.getHeight() / 2;

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
