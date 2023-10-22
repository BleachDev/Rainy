import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class AuroraView extends WatchUi.View {

    function initialize() {
        View.initialize();

        System.println("Init Aurora");
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);

        var W = dc.getWidth();
        var H = dc.getHeight();
        var mw = W * 0.14; // Margin Width
        var mh = H * 0.23; // Margin Height
        var cw = W - mw * 2.0; // Chart Width
        var ch = H - mh * 2.0; // Chart Height

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(W / 2, H / 26, Graphics.FONT_MEDIUM, "Aurora", Graphics.TEXT_JUSTIFY_CENTER);
        if (data.hourlyAurora == null) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(W / 2, H / 2.5, Graphics.FONT_TINY, "Aurora & Cloud Data\nUnavailable.", Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            // Aurora guidelines
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(mw, mh + ch - ch * 0.4 * 0.15, mw + cw, mh + ch - ch * 0.4 * 0.15);
            dc.drawLine(mw, mh + ch - ch * 0.4 * 0.5,  mw + cw, mh + ch - ch * 0.4 * 0.5);
            dc.drawLine(mw, mh + ch - ch * 0.4,        mw + cw, mh + ch - ch * 0.4);
            dc.drawText(mw + cw + 3, mh + ch - ch * 0.4 * 0.15 - H / 26, Graphics.FONT_XTINY, "Lo", Graphics.TEXT_JUSTIFY_LEFT);
            dc.drawText(mw + cw + 3, mh + ch - ch * 0.4 * 0.5 - H / 26, Graphics.FONT_XTINY, "Hi", Graphics.TEXT_JUSTIFY_LEFT);

            var len = data.hourlyAurora.size();
            var cloudPoints = new [len * 2];
            var auroraPoints = new [len + 2];

            var hour = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT).hour;
            var maxAurora = 0;
            for (var i = 0; i < len; i++) {
                var x = mw + (cw / (len - 1.0) * i);
                cloudPoints[i] = [ x, mh + ch * 0.26 + ch * data.hourlyClouds[i] / 1000 ];
                cloudPoints[len * 2 - 1 - i] = [ x, mh + ch * 0.26 - ch * data.hourlyClouds[i] / 1000 ];

                auroraPoints[i] = [ x, mh + ch - (ch * data.hourlyAurora[i] * 0.4)];
                maxAurora = data.hourlyAurora[i] > maxAurora ? data.hourlyAurora[i] : maxAurora;

                if (i % 6 == 0) {
                    dc.drawText(x, mh + ch, Graphics.FONT_XTINY, ((hour + i) % 24).format("%02d"), Graphics.TEXT_JUSTIFY_CENTER);
                }
                if ((hour + i) % 24 == 0) {
                    dc.drawLine(x, mh + ch * 0.6, x, mh + ch - 1);
                }
            }

            auroraPoints[len] = [ mw + cw, mh + ch ];
            auroraPoints[len + 1] = [ mw, mh + ch ];

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.fillPolygon(cloudPoints);

            if (len > 0) {
                dc.drawText(mw, mh, Graphics.FONT_XTINY, data.hourlyClouds[0] + "% Cloudy", Graphics.TEXT_JUSTIFY_LEFT);
            }

            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            dc.fillPolygon(auroraPoints);

            dc.drawText(mw + cw, mh, Graphics.FONT_XTINY,
                (maxAurora == 0 ? "No" : maxAurora < 0.5 ? "Low" : "High") + " Kp", Graphics.TEXT_JUSTIFY_RIGHT);
        }

        // Page Indicator
        res.indicator.draw(dc, 3);
    }
}
