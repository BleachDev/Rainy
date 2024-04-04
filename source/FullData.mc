import Toybox.Communications;
import Toybox.Position;
import Toybox.Lang;
import Toybox.Application;
import Toybox.Time;
import Toybox.WatchUi;

class FullData extends BaseData {

    public var DEVICE_ID = uniqueId();
    public var blocked   = false;

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
    public var waterTimestamps     as Array<Number> = [];

    function initialize() {
        BaseData.initialize();
    }

    // Callback function for Position.enableLocationEvents
    function posCB(loc as Position.Info) as Void {
        if (loc.position != null) {
            update(loc.position.toDegrees());
        }
    }

    function load() {
        if (Storage.getValue("hints") != null) { hints = Storage.getValue("hints"); }

        if (Properties.getValue("pageOrder") != null) { pageOrder = Properties.getValue("pageOrder"); }

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
        if (Storage.getValue("waterTimestamps") != null) { waterTimestamps = Storage.getValue("waterTimestamps"); }
        
        BaseData.load();

        Position.enableLocationEvents(Position.LOCATION_ONE_SHOT, method(:posCB));
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

        Storage.setValue("hourlyClouds", hourlyClouds);
        Storage.setValue("uv", uv);
        return true;
    }

    function fetchGeoData(responseCode as Number, data as Dictionary?) as Boolean {
        if (!BaseData.fetchGeoData(responseCode, data)) {
            return false;
        }

        request("https://api.bleach.dev/rainy/license?id=" + DEVICE_ID, method(:fetchLicense));

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

        Storage.setValue("hourlyAurora", hourlyAurora);
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
        sunElevation = data["sun"]["elevation"];
        sunNextEclipse = data["sun"]["next_eclipse_time"];
        sunEclipseObsc = data["sun"]["next_eclipse_obscuration"];
        moonNextNew = data["moon"]["next_new"];
        moonNextFull = data["moon"]["next_full"];
        moonIllumination = data["moon"]["illumination_percent"];
        moonPhase = data["moon"]["phase"];

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
            waterTimestamps[i] = waterData["time"];
        }

        Storage.setValue("waterNames", waterNames);
        Storage.setValue("waterTemperatures", waterTemperatures);
        Storage.setValue("waterDistances", waterDistances);
        Storage.setValue("waterTimestamps", waterTimestamps);
        WatchUi.requestUpdate();
    }

    function fetchLicense(responseCode as Number, data as Dictionary?) as Void {
        System.println("LIC " + responseCode);
        if (responseCode == 200 && data != null) {
            if (data["demo"]) {
                blocked = data["demo"] == 0;
                WatchUi.pushView(new RegisterView(data["demo"]), new RegisterDelegate(), WatchUi.SLIDE_BLINK);
            }
        }
    }

    // Helper Methods

    function hourlyEntries() {
        return hours < symbols.size() ? hours : symbols.size();
    }

    function uniqueId() {
        var alphabet = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ".toCharArray();
        var deviceId = System.getDeviceSettings().uniqueIdentifier.toUpper().toCharArray();
        var rainyId = "";
        for (var i = 0; i < 5; i++) {
            rainyId = rainyId + alphabet[alphabet.indexOf(deviceId[i * 2]) + alphabet.indexOf(deviceId[i * 2 + 1])];
        }
        return rainyId;
    }

    function enterText(text) {
        var menu = new Menu2({:title => "Location"});
        menu.addItem(new MenuItem("Loading Locations..", "Please Wait :)", 0, {}));

        WatchUi.pushView(menu, new Menu2InputDelegate(), WatchUi.SLIDE_IMMEDIATE);
        data.request("https://api.bleach.dev/weather/search?q=" + text, method(:fetchSearch));
    }

    function fetchSearch(responseCode as Number, data as Dictionary?) as Boolean {
        if (responseCode != 200 || data == null) {
            var menu = new Menu2({:title => "Location"});
            menu.addItem(new MenuItem("Error", "Connection Error", 0, {}));
            WatchUi.switchToView(menu, new Menu2InputDelegate(), WatchUi.SLIDE_BLINK);
            return false;
        }

        var menu = new Menu2({:title => "Location" });
        for (var i = 0; i < data.size(); i++) {
            menu.addItem(new MenuItem(data[i]["name"], data[i]["region"] + " (" + data[i]["code"] + "), El. " + data[i]["elevation"] + "m", i, {}));
        }

        WatchUi.switchToView(menu, new SpellListDelegate(data), WatchUi.SLIDE_BLINK);
        return true;
    }
}