import Toybox.Communications;
import Toybox.Position;
import Toybox.Lang;
import Toybox.Application;
import Toybox.Time;

class YrFullData extends YrBaseData {

    public var hints               as Number = 0;
    // Aurora
    public var hourlyAurora        as Array<Float>? = null;
    public var hourlyClouds        as Array<Float>? = null;
    // Water
    public var waterNames          as Array<String> = [];
    public var waterTemperatures   as Array<Float> = [];
    public var waterDistances      as Array<Number> = [];
    public var waterTimestamps     as Array<Moment> = [];

    function initialize() {
        YrBaseData.initialize();
    }

    // Callback function for Position.enableLocationEvents
    function posCB(loc as Position.Info) as Void {
        if (loc.position != null) {
            update(loc.position.toDegrees());
        }
    }

    function save() {
        YrBaseData.save();

        Storage.setValue("hints", hints);

        Storage.setValue("hourlyAurora", hourlyAurora);
        Storage.setValue("hourlyClouds", hourlyClouds);

        Storage.setValue("waterNames", waterNames);
        Storage.setValue("waterTemperatures", waterTemperatures);
        Storage.setValue("waterDistances", waterDistances);

        var serialized = new Array<Number>[waterTimestamps.size()];
        for (var t = 0; t < waterTimestamps.size(); t++) {
            serialized[t] = waterTimestamps[t].value();
        }
        Storage.setValue("waterTimestamps", serialized);
    }

    function load() {
        YrBaseData.load();

        if (Storage.getValue("hints") != null) { hints = Storage.getValue("hints"); }

        if (Storage.getValue("hourlyAurora") != null) { hourlyAurora = Storage.getValue("hourlyAurora"); }
        if (Storage.getValue("hourlyClouds") != null) { hourlyClouds = Storage.getValue("hourlyClouds"); }
        
        if (Storage.getValue("waterNames") != null) { waterNames = Storage.getValue("waterNames"); }
        if (Storage.getValue("waterTemperatures") != null) { waterTemperatures = Storage.getValue("waterTemperatures"); }
        if (Storage.getValue("waterDistances") != null) { waterDistances = Storage.getValue("waterDistances"); }
        if (Storage.getValue("waterTimestamps") != null) {
            var serialized = Storage.getValue("waterTimestamps");
            waterTimestamps = new [serialized.size()];
            for (var t = 0; t < serialized.size(); t++) {
                waterTimestamps[t] = new Moment(serialized[t]);
            }
        }
        Storage.clearValues();
        WatchUi.requestUpdate();

        // Save back sints so we're sure that its saved
        Storage.setValue("hints", hints);
    }

    // Fetching Methods

    function fetchForecastData(responseCode as Number, data as Dictionary?) as Boolean {
        if (!YrBaseData.fetchForecastData(responseCode, data)) {
            return false;
        }

        var forecastData = data["forecast"] as Dictionary;

        var hours = forecastData.size();
        hourlyClouds = new [hours];
        for (var i = 0; i < hours; i++) {
            var hour = forecastData[i];
            hourlyClouds[i] = hour["cloud_area_fraction"];
        }
        
        time = parseISODate(forecastData[0]["time"]);

        if (data["nowcast"] != null) {
            var nowData = data["nowcast"] as Dictionary;
            nowRainfall = new [nowData.size() < 19 ? nowData.size() : 19];
            for (var i = 0; i < nowRainfall.size(); i++) {
                nowRainfall[i] = nowData[i];
            }
        }

        return true;
    }

    function fetchGeoData(responseCode as Number, data as Dictionary?) as Boolean {
        if (!YrBaseData.fetchGeoData(responseCode, data)) {
            return false;
        }

        var showWater = "NO".equals(data[0]["code"]);
        BaseView.pageCount = showWater ? 5 : 4;
        
        request("https://www.yr.no/api/v0/locations/" + position[0] + "," + position[1] + "/auroraforecast", method(:fetchAuroraData));
        if (showWater) {
            request("https://www.yr.no/api/v0/locations/" + position[0] + "," + position[1] + "/nearestwatertemperatures", method(:fetchWaterData));
        }
        return true;
    }

    function fetchAuroraData(responseCode as Number, data as Dictionary?) as Void {
        System.println("AUR " + responseCode);
        if (responseCode != 200 || data == null) {
            System.println("AUR EXIT " + data);
            return;
        }

        if (data["shortIntervals"] == null) {
            hourlyAurora = null;
            return;
        }

        var len = data["shortIntervals"].size() > 32 ? 32 : data["shortIntervals"].size();
        hourlyAurora = new [len];
        for (var i = 0; i < len; i++) {
            hourlyAurora[i] = data["shortIntervals"][i]["auroraValue"];
        }

        WatchUi.requestUpdate();
    }

    function fetchWaterData(responseCode as Number, data as Dictionary?) as Void {
        System.println("WTR " + responseCode);
        if (responseCode != 200 || data == null || data["_embedded"] == null) {
            System.println("WTR EXIT " + data);
            return;
        }

        var len = data["_embedded"]["nearestLocations"].size();
        waterNames = new [len];
        waterTemperatures = new [len];
        waterDistances = new [len];
        waterTimestamps = new [len];
        for (var i = 0; i < len; i++) {
            var waterData = data["_embedded"]["nearestLocations"][i];
            waterNames[i] = waterData["location"]["name"];
            waterTemperatures[i] = waterData["temperature"];
            waterDistances[i] = waterData["distanceFromLocation"];
            waterTimestamps[i] = parseISODate(waterData["time"]);
        }

        WatchUi.requestUpdate();
    }

    // Helper Methods

    // converts rfc3339 formatted timestamp to Time::Moment (null on error)
    // Thanks trisiak @ https://forums.garmin.com/developer/connect-iq/f/discussion/2124/parsing-a-date-string-to-moment
    function parseISODate(date as String) {
        // 0123456789012345678901234
        // 2011-10-17T13:00:00-07:00
        // 2011-10-17T16:30:55.000Z
        // 2011-10-17T16:30:55Z
        if (date.length() < 20) {
            return null;
        }

        var moment = Gregorian.moment({
            :year => date.substring( 0, 4).toNumber(),
            :month => date.substring( 5, 7).toNumber(),
            :day => date.substring( 8, 10).toNumber(),
            :hour => date.substring(11, 13).toNumber(),
            :minute => date.substring(14, 16).toNumber(),
            :second => date.substring(17, 19).toNumber()
        });
        var suffix = date.substring(19, date.length());

        // skip over to time zone
        var tz = 0;
        if (suffix.substring(tz, tz + 1).equals(".")) {
            while (tz < suffix.length()) {
                var first = suffix.substring(tz, tz + 1);
                if ("-+Z".find(first) != null) {
                    break;
                }
                tz++;
            }
        }

        if (tz >= suffix.length()) {
            // no timezone given
            return null;
        }

        var tzOffset = 0;
        if (!suffix.substring(tz, tz + 1).equals("Z")) {
            // +HH:MM
            if (suffix.length() - tz < 6) {
                return null;
            }
            tzOffset = suffix.substring(tz + 1, tz + 3).toNumber() * Gregorian.SECONDS_PER_HOUR;
            tzOffset += suffix.substring(tz + 4, tz + 6).toNumber() * Gregorian.SECONDS_PER_MINUTE;

            var sign = suffix.substring(tz, tz + 1);
            if (sign.equals("+")) {
                tzOffset = -tzOffset;
            } else if (sign.equals("-") && tzOffset == 0) {
                // -00:00 denotes unknown timezone
                return null;
            }
        }

        return moment.add(new Duration(tzOffset));
    }
}