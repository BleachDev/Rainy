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
    // Forecast
    public var maxRainfall         as Array<Float> = [];
    // Aurora
    public var hourlyAurora        as Array<Float>? = null;
    public var hourlyClouds        as Array<Float>? = null;

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

        if (Storage.getValue("maxRainfall") != null) { maxRainfall = Storage.getValue("maxRainfall"); }

        if (Storage.getValue("hourlyAurora") != null) { hourlyAurora = Storage.getValue("hourlyAurora"); }
        if (Storage.getValue("hourlyClouds") != null) { hourlyClouds = Storage.getValue("hourlyClouds"); }
        
        BaseData.load();

        BaseDelegate.pageCount = showUpgrade && !INSTINCT_MODE ? 6 : 5;
        Position.enableLocationEvents(Position.LOCATION_ONE_SHOT, method(:posCB));
    }

    function removeHour() {
        BaseData.removeHour();

        if (maxRainfall.size() > 0) { maxRainfall.remove(maxRainfall[0]); }
        if (hourlyAurora.size() > 0) { hourlyAurora.remove(hourlyAurora[0]); }
        if (hourlyClouds.size() > 0) { hourlyClouds.remove(hourlyClouds[0]); }
    }

    // Fetching Methods

    function fetchForecastData(responseCode as Number, data as Dictionary?) as Boolean {
        if (!BaseData.fetchForecastData(responseCode, data)) {
            return false;
        }

        var forecastData = data["forecast"] as Dictionary;

        var hours = forecastData.size();
        maxRainfall = new [hours];
        hourlyClouds = new [hours];
        for (var i = 0; i < hours; i++) {
            var hour = forecastData[i];
            maxRainfall[i] = hour["precipitation_max"] != null ? hour["precipitation_max"] : rainfall[i];
            hourlyClouds[i] = hour["cloud_area_fraction"];
        }

        Storage.setValue("maxRainfall", maxRainfall);
        Storage.setValue("hourlyClouds", hourlyClouds);
        return true;
    }

    function fetchGeoData(responseCode as Number, data as Dictionary?) as Boolean {
        if (!BaseData.fetchGeoData(responseCode, data)) {
            return false;
        }
        
        request("https://api.bleach.dev/weather/aurora?noclouds&limit=32&lat=" + position[0] + "&lon=" + position[1], method(:fetchAuroraData));
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