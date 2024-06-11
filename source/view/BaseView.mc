import Toybox.Application;
import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class BaseView extends WatchUi.View {

    public static var page as Number = 0;
    public static var pages as Number = 1; // Super not correct use of static but we do what the voices in my head tell us to

    function initialize(pages) {
        View.initialize();
        self.pages = pages;
        self.page = 0;
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        // Bad place but yeah
        if (Properties.getValue("manLocation").length() > 0) {
            data.enterText(Properties.getValue("manLocation"));
            Properties.setValue("manLocation", "");
            return;
        }

        var W = dc.getWidth();
        var H = dc.getHeight();
        onDraw(dc, W, H, dc.getFontHeight(Graphics.FONT_XTINY));
    }

    function onDraw(dc as Dc, W as Number, H as Number, FONT_HEIGHT as Number) as Void {
    }

    function drawHeader(dc as Dc, W as Number, H as Number, text as String) {
        if (INSTINCT_MODE && text.length() > 12) {
            text = text.substring(0, 11) + ".";
        }

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var font = text.length() > 16 ? Graphics.FONT_XTINY : text.length() > 13 ? Graphics.FONT_TINY : text.length() > 11 ? Graphics.FONT_SMALL : Graphics.FONT_MEDIUM;
        dc.drawText(INSTINCT_MODE ? W / 2.9 : W / 2, H / 5.1 - dc.getFontHeight(font), font, text, Graphics.TEXT_JUSTIFY_CENTER);
    }

    public static function drawIndicator(dc as Dc, selectedIndex as Number) as Void {
        drawDots(dc, BaseDelegate.pageCount, selectedIndex, 3.14, 0.1);
    }

    public static function drawDots(dc as Dc, count as Number, selected as Number, angle as Float, space as Float) as Void {
        var height = dc.getWidth() / 30;
        for (var i = 0; i < count; i++) {
            var b = dc.getWidth() / 2 - height + 2;

            //round page indicator
            var x_i = b * Toybox.Math.cos(angle + ((count - 1f) / 2) * space - i * space) + dc.getWidth() / 2;
            var y_i = b * Toybox.Math.sin(angle + ((count - 1f) / 2) * space - i * space) + dc.getHeight() / 2;

            if (INSTINCT_MODE || SQUARE_MODE) {
                x_i = x_i < dc.getWidth() / 2 ? height - 2 : dc.getWidth() - height + 2;
            }

            if (i == selected || selected == -1) {
                dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
                dc.fillCircle(x_i, y_i, height / 2);
            } else {
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.drawCircle(x_i, y_i, height / 2);
            }
        }
    }
}