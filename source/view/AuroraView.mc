import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class AuroraView extends BaseView {

    function initialize() {
        BaseView.initialize(1);
    }

    // Update the view
    function onDraw(dc as Dc, W as Number, H as Number, FONT_HEIGHT as Number) as Void {
        drawHeader(dc, W, H, "Aurora");
        if (data.hourlyClouds == null) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(W / 2, H / 2.5, Graphics.FONT_TINY, "Aurora & Cloud Data\nUnavailable.", Graphics.TEXT_JUSTIFY_CENTER);
        } else {
            var mw = W * 0.15; // Margin Width
            var mh = H * 0.23; // Margin Height
            var cw = W - mw * 2.0; // Chart Width
            var ch = H - mh * 2.0; // Chart Height

            // Aurora guidelines
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(mw, mh + ch - ch * 0.4 * 0.15, mw + cw, mh + ch - ch * 0.4 * 0.15);
            dc.drawLine(mw, mh + ch - ch * 0.4 * 0.5,  mw + cw, mh + ch - ch * 0.4 * 0.5);
            dc.drawLine(mw, mh + ch - ch * 0.4,        mw + cw, mh + ch - ch * 0.4);
            dc.drawText(mw + cw + 3, mh + ch - ch * 0.4 * 0.15 - H / 26, Graphics.FONT_XTINY, "Lo", Graphics.TEXT_JUSTIFY_LEFT);
            dc.drawText(mw + cw + 3, mh + ch - ch * 0.4 * 0.5 - H / 26, Graphics.FONT_XTINY, "Hi", Graphics.TEXT_JUSTIFY_LEFT);

            var len = data.hourlyEntries() > 32 ? 32 : data.hourlyEntries();
            var cloudPoints = new [len * 2];
            var auroraPoints = new [len + 2];

            var hour = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT).hour;
            var maxAurora = 0;
            var cloudY = mh + FONT_HEIGHT + ch * 0.12;
            for (var i = 0; i < len; i++) {
                var x = mw + (cw / (len - 1.0) * i);    
                cloudPoints[i] = [ x, cloudY + ch * data.hourlyClouds[i] / 1000 ];
                    cloudPoints[len * 2 - 1 - i] = [ x, cloudY - ch * data.hourlyClouds[i] / 1000 ];

                var aurStrength = data.hourlyAurora != null && data.hourlyAurora.size() > i ? data.hourlyAurora[i] : 0;
                auroraPoints[i] = [ x, mh + ch - (ch * aurStrength * 0.4)];
                maxAurora = aurStrength > maxAurora ? aurStrength : maxAurora;

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
                dc.drawText(mw, mh, Graphics.FONT_XTINY, data.hourlyClouds[0].format("%d") + "% Cloudy", Graphics.TEXT_JUSTIFY_LEFT);
            }

            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            dc.fillPolygon(auroraPoints);

            dc.drawText(mw + cw, mh, Graphics.FONT_XTINY,
                (maxAurora == 0 ? "No" : maxAurora < 0.5 ? "Low" : "High") + " Kp", Graphics.TEXT_JUSTIFY_RIGHT);
        }

        // Page Indicator
        drawIndicator(dc, 4);
    }
}
