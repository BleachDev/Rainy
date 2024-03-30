import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class RegisterView extends WatchUi.View {

    private var days;

    function initialize(days) {
        View.initialize();
        self.days = days;
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        var W = dc.getWidth();
        var H = dc.getHeight();

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(W / 2, H / 12, Graphics.FONT_LARGE, "TRIAL", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(data.blocked ? Graphics.COLOR_RED : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(W / 2, H / 4.8, Graphics.FONT_TINY, days + " Days Left", Graphics.TEXT_JUSTIFY_CENTER);
        
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(W / 2, H / 2.55, Graphics.FONT_TINY, "To Activate: Go to", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(W / 2, H / 2, Graphics.FONT_MEDIUM, "rainy.bleach.dev", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(W / 2, H / 1.55, Graphics.FONT_TINY, "and enter code", Graphics.TEXT_JUSTIFY_CENTER);
        dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(W / 2, H / 1.35, Graphics.FONT_MEDIUM, data.DEVICE_ID, Graphics.TEXT_JUSTIFY_CENTER);
    }
}
