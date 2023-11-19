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

        onDraw(dc, dc.getWidth(), dc.getHeight(), dc.getHeight() / (INSTINCT_MODE ? 9 : 13));
    }

    function onDraw(dc as Dc, W as Number, H as Number, FONT_HEIGHT as Number) as Void {
    }

    function drawHeader(dc as Dc, W as Number, H as Number, text as String) {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(INSTINCT_MODE ? W / 5 : W / 2,
                    H / 26,
                    text.length() > 15 ? Graphics.FONT_TINY : text.length() > 12 ? Graphics.FONT_SMALL : Graphics.FONT_MEDIUM,
                    text,
                    INSTINCT_MODE ? Graphics.TEXT_JUSTIFY_LEFT : Graphics.TEXT_JUSTIFY_CENTER);
    }
}
