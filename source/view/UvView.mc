import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class UvView extends BaseView {

    function initialize() {
        BaseView.initialize(1);
    }

    // Update the view
    function onDraw(dc as Dc, W as Number, H as Number, FONT_HEIGHT as Number) as Void {
        drawHeader(dc, W, H, "UV / Air");
        
        var mw = W * 0.15; // Margin Width
        var mh = H * 0.23; // Margin Height
        var cw = W - mw * 2.0; // Chart Width
        var ch = (H - mh * 2.0) * 0.4; // Chart Height

        // UV guidelines
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(mw, H - mh - ch, mw + cw, H - mh - ch);
        dc.drawLine(mw, H - mh - ch * 0.65, mw + cw, H - mh - ch * 0.65);
        dc.drawLine(mw, H - mh - ch * 0.3, mw + cw, H - mh - ch * 0.3);
        dc.drawText(mw + cw + 3, H - mh - ch - H / 26, Graphics.FONT_XTINY, "10", Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(mw + cw + 3, H - mh - ch * 0.65 - H / 26, Graphics.FONT_XTINY, "6", Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(mw + cw + 3, H - mh - ch * 0.3 - H / 26, Graphics.FONT_XTINY, "3", Graphics.TEXT_JUSTIFY_LEFT);

        // UV chart
        var len = data.hourlyEntries() > 25 ? 25 : data.hourlyEntries();
        var hour = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT).hour;
        for (var i = 0; i < len; i++) {
            var x = mw + (cw / len * i);
            var h = Math.floor(data.uv[i] < 0.3 ? ch / 20 : data.uv[i] * ch / 10);

            colorUv(dc, data.uv[i]);
            dc.drawRectangle(x, H - mh - h, cw / len * 0.9, h);

            if (i % 4 == 0) {
                dc.drawText(x, H - mh, Graphics.FONT_XTINY, ((hour + i) % 24).format("%02d"), Graphics.TEXT_JUSTIFY_CENTER);
            }
        }

        // UV Text
        colorUv(dc, data.uv[0]);
        dc.drawText(mw, mh * 0.8, Graphics.FONT_NUMBER_MEDIUM, data.uv[0].format("%d"), Graphics.TEXT_JUSTIFY_LEFT);
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(mw, mh * 1.85, Graphics.FONT_XTINY,
                    data.uv[0] >= 11 ? "Extreme" : data.uv[0] >= 8 ? "Strong" : data.uv[0] >= 6 ? "High" :
                    data.uv[0] >= 3 ? "Medium" : data.uv[0] >= 0.3 ? "Low" : "No UV", Graphics.TEXT_JUSTIFY_LEFT);

        // yep 
        var temp = data.temperatures[0];
        var hum = data.humidity[0];
        var dew = 243.04 * (Math.ln(hum / 100) + ((17.625 * temp) / (243.04 + temp))) / (17.625 - Math.ln(hum / 100) - ((17.625 * temp) / (243.04 + temp)));

        // Humidity Text
        dc.drawText(mw + cw, mh, Graphics.FONT_XTINY, "Humidity " + hum.format("%d") + "%", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(mw + cw, mh + FONT_HEIGHT, Graphics.FONT_XTINY, "Dew " + dew.format("%d") + "°", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.setColor(dew < 15 ? Graphics.COLOR_GREEN :
                    dew < 20 ? Graphics.COLOR_YELLOW :
                    dew < 24 ? Graphics.COLOR_ORANGE : Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.drawText(mw + cw, mh + FONT_HEIGHT * 2, Graphics.FONT_XTINY,
                    dew < 15 ? "Pleasant" : dew < 20 ? "Sticky" : dew < 24 ? "Uncomfortable" : "Unbearable", Graphics.TEXT_JUSTIFY_RIGHT);

        // Page Indicator
        drawIndicator(dc, 5);
    }

    function colorUv(dc, uv) {
        dc.setColor(uv >= 11 ? Graphics.COLOR_PURPLE :
                    uv >= 8 ? Graphics.COLOR_RED :
                    uv >= 6 ? Graphics.COLOR_ORANGE :
                    uv >= 3 ? Graphics.COLOR_YELLOW :
                    uv >= 0.3 ? Graphics.COLOR_GREEN : Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
    }
}
