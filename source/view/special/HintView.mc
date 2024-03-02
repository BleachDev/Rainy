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
        dc.drawText(W / 2, H / 2.5, Graphics.FONT_TINY, text, Graphics.TEXT_JUSTIFY_CENTER);

        if (!INSTINCT_MODE && buttons.indexOf(0) != -1) {
            BaseView.drawDots(dc, 5, -1, 5.73, 0.06);
        }
        /*if (buttons.indexOf(1) != -1) {
            BaseView.drawDots(dc, 5, -1, 3.14, 0.06);
        }*/
    }
}
