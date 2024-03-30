import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Time;

class CelestialView extends BaseView {

    public static var page as Number = 0;

    function initialize() {
        BaseView.initialize();
    }

    // Update the view
    function onDraw(dc as Dc, W as Number, H as Number, FONT_HEIGHT as Number) as Void {
        drawHeader(dc, W, H, page == 0 ? "Sun" : "Moon");
        System.println(data.DEVICE_ID);
        
        var mw = W * 0.14; // Margin Width
        var mh = H * 0.23; // Margin Height
        var cw = W - mw * 2.0; // Chart Width
        var ch = (H - mh * 2.0) * 0.4; // Chart Height

        // Sun line
        if (page == 0) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(mw, H - mh,            mw + cw, H - mh);
            dc.drawLine(mw, H - mh - ch * 0.5, mw + cw, H - mh - ch * 0.5);
            dc.drawLine(mw, H - mh - ch,       mw + cw, H - mh - ch);

            var len = data.sunElevation.size();
            var sunPoints = new [len * 2] as Array<Array<Float>>;
            var lightPoints = [];
            for (var i = 0; i < len; i++) {
                var x = mw + (cw / (len - 1.0) * i);    

                sunPoints[i] = [ x, H - mh - ch * 0.5 - (data.sunElevation[i] / 150) * ch];
                sunPoints[len * 2 - 1 - i] = [ x, H - mh - ch * 0.5 - H / 150 - (data.sunElevation[i] / 150) * ch];
                if (data.sunElevation[i] >= 0) {
                    lightPoints.add(sunPoints[i]);
                }
            }

            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            dc.fillPolygon(lightPoints);

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.fillPolygon(sunPoints);

            // Sun ball
            var time = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
            var minute = time.hour * 60 + time.min;
            var sunY = sunPoints[(sunPoints.size() / 2 * (minute / 1441.0)).toNumber()][1];

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(mw + cw * (minute / 1440.0), sunY, W / 28);
            dc.setColor(sunY > H - mh - ch * 0.5 ? Graphics.COLOR_BLACK : Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(mw + cw * (minute / 1440.0), sunY, W / 32);

            // Timestamps
            var riseTime = Gregorian.info(new Moment(data.sunRise), Time.FORMAT_SHORT);
            var maxTime = Gregorian.info(new Moment(data.sunMax), Time.FORMAT_SHORT);
            var setTime = Gregorian.info(new Moment(data.sunSet), Time.FORMAT_SHORT);

            var riseX = mw + cw * ((riseTime.hour * 60 + riseTime.min) / 1440.0);
            var maxX = mw + cw * ((maxTime.hour * 60 + maxTime.min) / 1440.0);
            var setX = mw + cw * ((setTime.hour * 60 + setTime.min) / 1440.0);

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(riseX, H - mh - ch - FONT_HEIGHT, Graphics.FONT_XTINY, "RISE", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(riseX, H - mh, Graphics.FONT_XTINY,
                        riseTime.hour.format("%02d") + ":" + riseTime.min.format("%02d"), Graphics.TEXT_JUSTIFY_CENTER);

            dc.drawText(maxX, H - mh - ch - FONT_HEIGHT, Graphics.FONT_XTINY, "NOON", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(maxX, H - mh, Graphics.FONT_XTINY,
                        maxTime.hour.format("%02d") + ":" + maxTime.min.format("%02d"), Graphics.TEXT_JUSTIFY_CENTER);

            dc.drawText(setX, H - mh - ch - FONT_HEIGHT, Graphics.FONT_XTINY, "SET", Graphics.TEXT_JUSTIFY_CENTER);
            dc.drawText(setX, H - mh, Graphics.FONT_XTINY,
                        setTime.hour.format("%02d") + ":" + setTime.min.format("%02d"), Graphics.TEXT_JUSTIFY_CENTER);

            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawLine(riseX, H - mh - ch, riseX, H - mh);
            dc.drawLine(maxX, H - mh - ch, maxX, H - mh);
            dc.drawLine(setX, H - mh - ch, setX, H - mh);

            // Top Text
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.drawText(mw, mh, Graphics.FONT_XTINY,
                        "Daylight " + (data.sunLength / 3600).format("%d") +
                        "h " + ((data.sunLength / 60) % 60).format("%d") + "m", Graphics.TEXT_JUSTIFY_LEFT);
            dc.drawText(mw, mh + FONT_HEIGHT, Graphics.FONT_XTINY,
                        "Today " + (data.sunLength >= 0 ? "+" : "-") + (data.sunDifference.abs() / 60).format("%d") +
                        "m " + (data.sunDifference.abs() % 60).format("%d") + "s", Graphics.TEXT_JUSTIFY_LEFT);

            // Sun Icon
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(W - mw - W / 10, mh + H / 10, W / 13);
            dc.setColor(Graphics.COLOR_ORANGE, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(W - mw - W / 10, mh + H / 10, W / 15);
            dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(W - mw - W / 10, mh + H / 10, W / 17);
        } else {
            // Top Text
            var eclipseTime = Gregorian.info(new Moment(data.sunNextEclipse), Time.FORMAT_MEDIUM);
            dc.drawText(mw, mh, Graphics.FONT_XTINY,
                        "Next Solar\nEclipse (" + (data.sunEclipseObsc > 0.99 ? "total" : "partial") + ")\n" +
                        eclipseTime.day + ". " + eclipseTime.month + " " + eclipseTime.year, Graphics.TEXT_JUSTIFY_LEFT);

            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(W - mw - W / 10, mh + H / 10, W / 13);
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_TRANSPARENT);
            dc.fillCircle(W - mw - W / 10 + (W / 13) * data.moonIllumination / 100, mh + H / 10 - (W / 13) * data.moonIllumination / 100, W / 13);

            // Bottom Text
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
            var fullTime = Gregorian.info(new Moment(data.moonNextFull), Time.FORMAT_MEDIUM);
            var newTime = Gregorian.info(new Moment(data.moonNextNew), Time.FORMAT_MEDIUM);
            dc.drawText(mw, H - mh - ch, Graphics.FONT_XTINY,
                        "Full Moon\n" + fullTime.month + ". " + fullTime.day + " " +
                        fullTime.hour.format("%02d") + ":" + fullTime.min.format("%02d") +
                        "\nNew Moon\n" + newTime.month + ". " + newTime.day + " " +
                        newTime.hour.format("%02d") + ":" + newTime.min.format("%02d"), Graphics.TEXT_JUSTIFY_LEFT);

            dc.drawText(W - mw, H - mh - ch, Graphics.FONT_XTINY,
                        data.moonIllumination.toNumber() + "% Visible\n" + replace(data.moonPhase, " ", "\n"), Graphics.TEXT_JUSTIFY_RIGHT);
        }

        // Local Page Indicator
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(W / 2, H * 0.8 + FONT_HEIGHT, Graphics.FONT_TINY, (page + 1) + "/2", Graphics.TEXT_JUSTIFY_CENTER);

        // Page Indicator
        drawIndicator(dc, 6);
    }


    function replace(str, oldString, newString) {
        var result = str;

        while (true) {
            var index = result.find(oldString);

            if (index != null) {
                var index2 = index+oldString.length();
                result = result.substring(0, index) + newString + result.substring(index2, result.length());
            } else {
                return result;
            }
        }

        return "";
    } 
}
