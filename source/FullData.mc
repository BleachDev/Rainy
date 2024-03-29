import Toybox.Communications;
import Toybox.Position;
import Toybox.Lang;
import Toybox.Application;
import Toybox.Time;

class FullData extends BaseData {

    public var hints               as Number = 0;
    public var pageOrder           as Boolean = false;
    // Aurora
    public var hourlyAurora        as Array<Float>? = null;
    public var hourlyClouds        as Array<Float>? = null;
    // Uv
    public var uv                  as Array<Float> = [];
    // Celestial
    public var sunLength           as Number = 0;
    public var sunDifference       as Number = 0;
    public var sunRise             as Number = 0;
    public var sunMax              as Number = 0;
    public var sunSet              as Number = 0;
    public var sunElevation        as Array<Float> = [];
    public var sunNextEclipse      as Number = 0;
    public var sunEclipseObsc      as Float = 0.0;
    public var moonNextNew         as Number = 0;
    public var moonNextFull        as Number = 0;
    public var moonIllumination    as Number = 0;
    public var moonPhase           as String = "";
    // Water
    public var waterNames          as Array<String> = [];
    public var waterTemperatures   as Array<Float> = [];
    public var waterDistances      as Array<Number> = [];
    public var waterTimestamps     as Array<Moment> = [];

    function initialize() {
        BaseData.initialize();
    }

    // Callback function for Position.enableLocationEvents
    function posCB(loc as Position.Info) as Void {
        if (loc.position != null) {
            update(loc.position.toDegrees());
        }
    }

    function save() {
        BaseData.save();

        Storage.setValue("hints", hints);
        Storage.setValue("pageOrder", pageOrder);

        Storage.setValue("hourlyAurora", hourlyAurora);
        Storage.setValue("hourlyClouds", hourlyClouds);

        Storage.setValue("uv", uv);

        Storage.setValue("sunLength", sunLength);
        Storage.setValue("sunDifference", sunDifference);
        Storage.setValue("sunRise", sunRise);
        Storage.setValue("sunMax", sunMax);
        Storage.setValue("sunSet", sunSet);
        Storage.setValue("sunElevation", sunElevation);
        Storage.setValue("sunNextEclipse", sunNextEclipse);
        Storage.setValue("sunEclipseObsc", sunEclipseObsc);
        Storage.setValue("moonNextNew", moonNextNew);
        Storage.setValue("moonNextFull", moonNextFull);
        Storage.setValue("moonIllumination", moonIllumination);
        Storage.setValue("moonPhase", moonPhase);

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
        if (Storage.getValue("hints") != null) { hints = Storage.getValue("hints"); }
        if (Storage.getValue("pageOrder") != null) { pageOrder = Storage.getValue("pageOrder"); }

        if (Storage.getValue("hourlyAurora") != null) { hourlyAurora = Storage.getValue("hourlyAurora"); }
        if (Storage.getValue("hourlyClouds") != null) { hourlyClouds = Storage.getValue("hourlyClouds"); }

        if (Storage.getValue("uv") != null) { uv = Storage.getValue("uv"); }

        if (Storage.getValue("sunLength") != null) { sunLength = Storage.getValue("sunLength"); }
        if (Storage.getValue("sunDifference") != null) { sunDifference = Storage.getValue("sunDifference"); }
        if (Storage.getValue("sunRise") != null) { sunRise = Storage.getValue("sunRise"); }
        if (Storage.getValue("sunMax") != null) { sunMax = Storage.getValue("sunMax"); }
        if (Storage.getValue("sunSet") != null) { sunSet = Storage.getValue("sunSet"); }
        if (Storage.getValue("sunElevation") != null) { sunElevation = Storage.getValue("sunElevation"); }
        if (Storage.getValue("sunNextEclipse") != null) { sunNextEclipse = Storage.getValue("sunNextEclipse"); }
        if (Storage.getValue("sunEclipseObsc") != null) { sunEclipseObsc = Storage.getValue("sunEclipseObsc"); }
        if (Storage.getValue("moonNextNew") != null) { moonNextNew = Storage.getValue("moonNextNew"); }
        if (Storage.getValue("moonNextFull") != null) { moonNextFull = Storage.getValue("moonNextFull"); }
        if (Storage.getValue("moonIllumination") != null) { moonIllumination = Storage.getValue("moonIllumination"); }
        if (Storage.getValue("moonPhase") != null) { moonPhase = Storage.getValue("moonPhase"); }
        
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
        
        BaseData.load();
    }

    // Fetching Methods

    function fetchForecastData(responseCode as Number, data as Dictionary?) as Boolean {
        if (!BaseData.fetchForecastData(responseCode, data)) {
            return false;
        }

        var forecastData = data["forecast"] as Dictionary;

        var hours = forecastData.size();
        hourlyClouds = new [hours];
        uv = new [hours];
        for (var i = 0; i < hours; i++) {
            var hour = forecastData[i];
            hourlyClouds[i] = hour["cloud_area_fraction"];
            uv[i] = hour["uv"];
        }

        return true;
    }

    function fetchGeoData(responseCode as Number, data as Dictionary?) as Boolean {
        if (!BaseData.fetchGeoData(responseCode, data)) {
            return false;
        }

        var showWater = "NO".equals(data[0]["code"]);
        BaseDelegate.pageCount = showWater ? 8 : 7;
        
        request("https://api.bleach.dev/weather/aurora?noclouds&limit=32&lat=" + position[0] + "&lon=" + position[1], method(:fetchAuroraData));
        request("https://api.bleach.dev/weather/celestial?lat=" + position[0] + "&lon=" + position[1], method(:fetchCelestialData));
        if (showWater) {
            request("https://api.bleach.dev/weather/water?lat=" + position[0] + "&lon=" + position[1], method(:fetchWaterData));
        }
        return true;
    }

    function fetchAuroraData(responseCode as Number, data as Dictionary?) as Void {
        System.println("AUR " + responseCode);
        if (responseCode != 200 || data == null) {
            System.println("AUR EXIT " + data);
            return;
        }

        hourlyAurora = new [data["aurora"].size()];
        for (var i = 0; i < data["aurora"].size(); i++) {
            hourlyAurora[i] = data["aurora"][i]["activity"];
        }

        WatchUi.requestUpdate();
    }

    function fetchCelestialData(responseCode as Number, data as Dictionary?) as Void {
        System.println("CST " + responseCode);
        if (responseCode != 200 || data == null) {
            System.println("CST EXIT " + data);
            return;
        }

        sunLength = data["sun"]["day_length"];
        sunDifference = data["sun"]["difference"];
        sunRise = data["sun"]["rise"];
        sunMax = data["sun"]["max"];
        sunSet = data["sun"]["set"];
        sunNextEclipse = data["sun"]["next_eclipse_time"];
        sunEclipseObsc = data["sun"]["next_eclipse_obscuration"];
        moonNextNew = data["moon"]["next_new"];
        moonNextFull = data["moon"]["next_full"];
        moonIllumination = data["moon"]["illumination_percent"];
        moonPhase = data["moon"]["phase"];

        WatchUi.requestUpdate();
    }

    function fetchWaterData(responseCode as Number, data as Dictionary?) as Void {
        System.println("WTR " + responseCode);
        if (responseCode != 200 || data == null) {
            System.println("WTR EXIT " + data);
            return;
        }

        var len = data["water"].size();
        waterNames = new [len];
        waterTemperatures = new [len];
        waterDistances = new [len];
        waterTimestamps = new [len];
        for (var i = 0; i < len; i++) {
            var waterData = data["water"][i];
            waterNames[i] = waterData["name"];
            waterTemperatures[i] = waterData["temperature"];
            waterDistances[i] = waterData["distance"];
            waterTimestamps[i] = new Moment(waterData["time"]);
        }

        WatchUi.requestUpdate();
    }

    // Helper Methods

    function hourlyEntries() {
        return hours < symbols.size() ? hours : symbols.size();
    }
}