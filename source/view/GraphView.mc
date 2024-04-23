import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;

class GraphView extends BaseView {

    function initialize() {
        BaseView.initialize((data.hourlyEntries() - 2) / 12 + 1);
    }

    function onDraw(dc as Dc, W as Number, H as Number, FONT_HEIGHT as Number) as Void {
        drawHeader(dc, W, H, page ? "In " + (page * 12) + " Hours" : "Now");
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);

        var offset = page * 12;
        var mw = W * 0.16; // Margin Width
        var mh = H * 0.25; // Margin Height
        var lw = (W - mw * 2) / 12.0; // Line Width
        var lh = (H - mh * 2) / 9.0; // Line Height
        var points = data.hourlyEntries() - offset > 12 ? 12 : data.hourlyEntries() - offset - 1;
        var startHour = Time.Gregorian.info(data.time, Time.FORMAT_SHORT).hour;

        var minTemp = data.temperatures[0];
        var maxTemp = data.temperatures[0];
        for (var i = 0; i < data.temperatures.size(); i++) {
            if (data.temperatures[i] - 2 < minTemp) {
                minTemp = data.temperatures[i] - 2;
            }
            if (data.temperatures[i] + 2 > maxTemp) {
                maxTemp = data.temperatures[i] + 2;
            }
        }
        var diffTemp = maxTemp - minTemp;

        // Horizontal Graph Background
        dc.setColor(INSTINCT_MODE ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        for (var i = 0; i < 10; i++) {
            dc.drawLine(mw, mh + lh * i, W - mw - lw * (12 - points), mh + lh * i);
        }
        
        // 0 Degree line
        if (minTemp < 0 && maxTemp > 0) {
            var freezingY = H - mh - (-minTemp / diffTemp) * (H - mh * 2);
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(mw, freezingY, W - mw - lw * (12 - points), freezingY);
        }

        // Vertical Graph Background + Timestamps
        for (var i = 0; i < points + 1; i++) {
            dc.setColor((startHour + offset + i) % 24 == 0 || INSTINCT_MODE ? Graphics.COLOR_LT_GRAY : Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(mw + lw * i, mh, mw + lw * i, H - mh);

            // Bottom time text
            if (i % 3 == 0) {
                dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
                dc.drawText(mw + lw * i, H - mh, Graphics.FONT_XTINY, ((startHour + offset + i) % 24).format("%02d"), Graphics.TEXT_JUSTIFY_CENTER);
            }
        }

        var tempPoints = new [points * 2 + 2];
        for (var i = 0; i < points; i++) {
            // Rain (fillRectancle uses wh instead of xy :troll:)
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            var maxRain = data.maxRainfall[offset + i];
            dc.fillRectangle(mw + lw * i, H - mh - lh * maxRain, lw, lh * maxRain);

            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            var rain = data.rainfall[offset + i];
            dc.fillRectangle(mw + lw * i, H - mh - lh * rain, lw, lh * rain);

            // Temperature
            var t1 = H - mh - ((data.temperatures[offset + i].toFloat() - minTemp) / diffTemp) * (H - mh * 2);
            tempPoints[i] = [ mw + lw * i, t1 ];
            tempPoints[tempPoints.size() - 1 - i] = [ mw + lw * i, t1 - lh / 4 ];
            if (i + 1 == points) {
                var t2 = H - mh - ((data.temperatures[offset + i + 1].toFloat() - minTemp) / diffTemp) * (H - mh * 2);
                tempPoints[i + 1] = [ mw + lw * (i + 1), t2 ];
                tempPoints[i + 2] = [ mw + lw * (i + 1), t2 - lh / 4 ];
            }
        }

        dc.setColor(INSTINCT_MODE ? Graphics.COLOR_WHITE : Graphics.COLOR_RED, Graphics.COLOR_TRANSPARENT);
        dc.fillPolygon(tempPoints);

        // Left side temperature text
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(mw - 3, mh - (INSTINCT_MODE ? 6 : 0), Graphics.FONT_XTINY, degrees(maxTemp, data.tempUnits) + "°", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(mw - 3, mh + (H - mh * 2) * 0.27, Graphics.FONT_XTINY, degrees(maxTemp - diffTemp * 0.33, data.tempUnits) + "°", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(mw - 3, mh + (H - mh * 2) * 0.55, Graphics.FONT_XTINY, degrees(maxTemp - diffTemp * 0.66, data.tempUnits) + "°", Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(mw - 3, H - mh - FONT_HEIGHT, Graphics.FONT_XTINY, degrees(minTemp, data.tempUnits) + "°", Graphics.TEXT_JUSTIFY_RIGHT);

        // Right side rainfall text
        dc.drawText(W - mw + 3, mh - (INSTINCT_MODE ? 6 : 0), Graphics.FONT_XTINY, "9", Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(W - mw + 3, mh + (H - mh * 2) * 0.27, Graphics.FONT_XTINY, "6", Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(W - mw + 3, mh + (H - mh * 2) * 0.55, Graphics.FONT_XTINY, "3", Graphics.TEXT_JUSTIFY_LEFT);
        dc.drawText(W - mw + 3, H - mh - FONT_HEIGHT, Graphics.FONT_XTINY, "0", Graphics.TEXT_JUSTIFY_LEFT);

        // Local Page Indicator
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(W / 2, H - mh + FONT_HEIGHT, Graphics.FONT_TINY, (page + 1) + "/" + pages, Graphics.TEXT_JUSTIFY_CENTER);

        // Page Indicator
        if (!INSTINCT_MODE) {
            drawIndicator(dc, data.pageOrder ? 1 : 3);
        }
    }
}
