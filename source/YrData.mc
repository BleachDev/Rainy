import Toybox.Communications;
import Toybox.Position;
import Toybox.Lang;
import Toybox.Application;
import Toybox.Time;

class YrData {

    public var hints                as Number = 0;
    public var fahrenheit           as Boolean = false;

    public var position             as Array<Double>?;
    public var location             as String = "..";
    public var time                 as Moment = Time.now();
    // Forecast
    public var nowRainfall          as Array<Float>? = null; // Null or list of next 90 mins of rain
    public var hourlyTemperature    as Array<Float> = [];
    public var hourlyWindSpeed      as Array<Float> = [];
    public var hourlyWindDirection  as Array<Float> = [];
    public var hourlyRainfall       as Array<Float> = [];
    public var hourlyHumidity       as Array<Float> = [];
    public var hourlySymbol         as Array<Number> = [];
    // Aurora
    public var hourlyAurora        as Array<Float>? = null;
    public var hourlyClouds        as Array<Float>? = null;
    // Water
    public var waterNames          as Array<String> = [];
    public var waterTemperatures   as Array<Float> = [];
    public var waterDistances      as Array<Number> = [];
    public var waterTimestamps     as Array<Moment> = [];

    // Callback function for Position.enableLocationEvents
    function posCB(loc as Position.Info) as Void {
        position = loc.position.toDegrees();
    }

    function update(coords as Array<Double>) as Void {
        System.println("Refreshing, " + coords);
        position = coords;

        var limit = System.getSystemStats().totalMemory < 80000 ? 24 : 36;
        request("https://api.bleach.dev/weather/forecast?limit=" + limit + "&lat=" + position[0] + "&lon=" + position[1], method(:fetchForecastData));
        request("https://nominatim.openstreetmap.org/reverse?format=json&lat=" + position[0] + "&lon=" + position[1], method(:fetchGeoData));
    }

    // Request order
    // -> Forecast -> Aurora
    //            \-> Water
    // -> Geo
    function request(url, callback) {
        Communications.makeWebRequest(url, null, {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :headers => { "User-Agent" => "GarminYr/1.1 me@bleach.dev" },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        }, callback);
    }

    function save() {
        Storage.setValue("hints", hints);
        Storage.setValue("fahrenheit", fahrenheit);

        Storage.setValue("geo", position);
        Storage.setValue("location", location);
        Storage.setValue("time", time.value());

        Storage.setValue("nowRainfall", nowRainfall);
        Storage.setValue("hourlyTemperature", hourlyTemperature);
        Storage.setValue("hourlyWindSpeed", hourlyWindSpeed);
        Storage.setValue("hourlyWindDirection", hourlyWindDirection);
        Storage.setValue("hourlyRainfall", hourlyRainfall);
        Storage.setValue("hourlyHumidity", hourlyHumidity);
        Storage.setValue("hourlySymbol", hourlySymbol);

        Storage.setValue("hourlyAurora", hourlyAurora);
        Storage.setValue("hourlyClouds", hourlyClouds);

        Storage.setValue("waterNames", waterNames);
        Storage.setValue("waterTemperatures", waterTemperatures);
        Storage.setValue("waterDistances", waterDistances);
        saveMoments("waterTimestamps", waterTimestamps);
    }

    function saveMoments(key, moments) {
        var serialized = new Array<Number>[moments.size()];
        for (var t = 0; t < moments.size(); t++) {
            serialized[t] = moments[t].value();
        }
        Storage.setValue(key, serialized);
    }

    function load() {
        if (Storage.getValue("hints") != null) { hints = Storage.getValue("hints"); }
        if (Storage.getValue("fahrenheit") != null) { fahrenheit = Storage.getValue("fahrenheit"); }
                                               else { fahrenheit = System.getDeviceSettings().temperatureUnits == System.UNIT_STATUTE; }
        
        if (Storage.getValue("geo") != null) { position = Storage.getValue("geo"); }
        if (Storage.getValue("location") != null) { location = Storage.getValue("location"); }
        if (Storage.getValue("time") != null) { time = new Moment(Storage.getValue("time")); }

        if (Storage.getValue("nowRainfall") != null) { nowRainfall = Storage.getValue("nowRainfall"); }
        if (Storage.getValue("hourlyTemperature") != null) { hourlyTemperature = Storage.getValue("hourlyTemperature"); }
        if (Storage.getValue("hourlyWindSpeed") != null) { hourlyWindSpeed = Storage.getValue("hourlyWindSpeed"); }
        if (Storage.getValue("hourlyWindDirection") != null) { hourlyWindDirection = Storage.getValue("hourlyWindDirection"); }
        if (Storage.getValue("hourlyRainfall") != null) { hourlyRainfall = Storage.getValue("hourlyRainfall"); }
        if (Storage.getValue("hourlyHumidity") != null) { hourlyHumidity = Storage.getValue("hourlyHumidity"); }
        if (Storage.getValue("hourlySymbol") != null) { hourlySymbol = Storage.getValue("hourlySymbol"); }

        if (Storage.getValue("hourlyAurora") != null) { hourlyAurora = Storage.getValue("hourlyAurora"); }
        if (Storage.getValue("hourlyClouds") != null) { hourlyClouds = Storage.getValue("hourlyClouds"); }
        
        if (Storage.getValue("waterNames") != null) { waterNames = Storage.getValue("waterNames"); }
        if (Storage.getValue("waterTemperatures") != null) { waterTemperatures = Storage.getValue("waterTemperatures"); }
        if (Storage.getValue("waterDistances") != null) { waterDistances = Storage.getValue("waterDistances"); }
        if (Storage.getValue("waterTimestamps") != null) { waterTimestamps = loadMoments("waterTimestamps"); }
        Storage.clearValues();
        WatchUi.requestUpdate();

        // Save back sints so we're sure that its saved
        Storage.setValue("hints", hints);
    }

    function loadMoments(key) {
        var serialized = Storage.getValue(key);
        var array = new [serialized.size()];
        for (var t = 0; t < serialized.size(); t++) {
            array[t] = new Moment(serialized[t]);
        }
        return array;
    }

    // Fetching Methods

    function fetchForecastData(responseCode as Number, data as Dictionary?) as Void {
        System.println("FC " + responseCode);
        if (responseCode != 200 || data == null || data["forecast"] == null) {
            System.println("FC EXIT " + data);
        } else {
            var forecastData = data["forecast"] as Dictionary;

            var hours = forecastData.size();
            hourlyTemperature = new [hours];
            hourlyWindSpeed = new [hours];
            hourlyWindDirection = new [hours];
            hourlyRainfall = new [hours];
            hourlyHumidity = new [hours];
            hourlySymbol = new [hours];
            hourlyClouds = new [hours];
            for (var i = 0; i < hours; i++) {
                var hour = forecastData[i];
                hourlyTemperature[i] = hour["air_temperature"];
                hourlyWindSpeed[i] = hour["wind_speed"];
                hourlyWindDirection[i] = hour["wind_from_direction"];
                hourlyRainfall[i] = hour["precipitation_amount"];
                hourlyHumidity[i] = hour["relative_humidity"];
                hourlySymbol[i] = hour["symbol_code"].hashCode();
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

            WatchUi.requestUpdate();
        }

        request("https://www.yr.no/api/v0/locations/" + position[0] + "," + position[1] + "/auroraforecast", method(:fetchAuroraData));
        request("https://www.yr.no/api/v0/locations/" + position[0] + "," + position[1] + "/nearestwatertemperatures", method(:fetchWaterData));
    }

    function fetchGeoData(responseCode as Number, data as Dictionary?) as Void {
        System.println("GEO " + responseCode);
        if (responseCode != 200 || data == null || data["address"] == null) {
            System.println("GEO EXIT " + data);
            return;
        }

        var addressData = data["address"] as Dictionary;

        if (addressData["neighbourhood"] != null) {
            location = addressData["neighbourhood"];
        } else if (addressData["farm"] != null) {
            location = addressData["farm"];
        } else if (addressData["quarter"] != null) {
            location = addressData["quarter"];
        } else if (addressData["village"] != null) {
            location = addressData["village"];
        } else if (addressData["suburb"] != null) {
            location = addressData["suburb"];
        } else if (addressData["city_district"] != null) {
            location = addressData["city_district"];
        } else if (addressData["city"] != null) {
            location = addressData["city"];
        } else if (addressData["county"] != null) {
            location = addressData["county"];
        } else if (addressData["country"] != null) {
            location = addressData["country"];
        } else {
            location = "Unknown";
        }

        WatchUi.requestUpdate();
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