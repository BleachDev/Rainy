import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class UpgradeView extends BaseView {

    function initialize() {
        BaseView.initialize(2);
    }

    // Update the view
    function onDraw(dc as Dc, W as Number, H as Number, FONT_HEIGHT as Number) as Void {
        if (page == 0) {
            drawHeader(dc, W, H, "Do you want..");

            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(W / 2, H / 4.5, Graphics.FONT_TINY, "7 Day Forecast", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(W / 2, H / 4.5 + FONT_HEIGHT * 1.1, Graphics.FONT_TINY, "48 Hour Visual Graph", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(W / 2, H / 4.5 + FONT_HEIGHT * 2.2, Graphics.FONT_TINY, "UV & Air Info", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(W / 2, H / 4.5 + FONT_HEIGHT * 3.3, Graphics.FONT_TINY, "Sun/Moon Info", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(W / 2, H / 4.5 + FONT_HEIGHT * 4.4, Graphics.FONT_TINY, "Solar Eclipse Info", Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            drawHeader(dc, W, H, "Then try..");

            dc.drawBitmap(W / 7, H / 4.6, res.getSymbol(0));
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(W / 5 + 40, H / 4.6, Graphics.FONT_LARGE, "Rainy Pro", Graphics.TEXT_JUSTIFY_LEFT);
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(W / 2, H / 4.5 + FONT_HEIGHT * 1.9, Graphics.FONT_TINY, "In the Connect-IQ", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(W / 2, H / 4.5 + FONT_HEIGHT * 2.9, Graphics.FONT_TINY, "Store", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(W / 2, H * 0.73 - FONT_HEIGHT, Graphics.FONT_TINY, "PS: You can turn this", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(W / 2, H * 0.73, Graphics.FONT_TINY, "page off in settings", Graphics.TEXT_JUSTIFY_CENTER);
        }

        dc.drawText(W / 2, H * 0.75 + FONT_HEIGHT, Graphics.FONT_TINY, (page + 1) + "/2", Graphics.TEXT_JUSTIFY_CENTER);

        // Page Indicator
        drawIndicator(dc, 5);
    }
}
