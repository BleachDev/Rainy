import Toybox.Communications;
import Toybox.Position;
import Toybox.Lang;
import Toybox.Application;
import Toybox.Time;
import Toybox.WatchUi;

class FullData extends BaseData {

    public var hints               as Number = 0;
    public var pageOrder           as Boolean = false;
    public var showUpgrade         as Boolean = true;
    // Aurora
    public var hourlyAurora        as Array<Float>? = null;
    public var hourlyClouds        as Array<Float>? = null;
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
        if (Properties.getValue("showUpgrade") != null) { showUpgrade = Properties.getValue("showUpgrade"); }

        if (Storage.getValue("hourlyAurora") != null) { hourlyAurora = Storage.getValue("hourlyAurora"); }
        if (Storage.getValue("hourlyClouds") != null) { hourlyClouds = Storage.getValue("hourlyClouds"); }
        
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
        for (var i = 0; i < hours; i++) {
            var hour = forecastData[i];
            hourlyClouds[i] = hour["cloud_area_fraction"];
        }

        Storage.setValue("hourlyClouds", hourlyClouds);
        return true;
    }

    function fetchGeoData(responseCode as Number, data as Dictionary?) as Boolean {
        if (!BaseData.fetchGeoData(responseCode, data)) {
            return false;
        }

        var showWater = "NO".equals(data[0]["code"]);
        BaseDelegate.showWater = showWater;
        
        request("https://api.bleach.dev/weather/aurora?noclouds&limit=32&lat=" + position[0] + "&lon=" + position[1], method(:fetchAuroraData));
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

    // Helper Methods

    function hourlyEntries() {
        return hours < symbols.size() ? hours : symbols.size();
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