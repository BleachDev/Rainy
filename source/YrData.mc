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
    // Nowcast
    public var temperature          as Float = 88.0;
    public var windSpeed            as Float = 88.0;
    public var windDirection        as Float = 88.0;
    public var humidity             as Float = 88.0;
    public var rainfall             as Array<Float>? = null; // Null or list of next 90 mins of rain
    // Forecast
    public var hourlyTemperature    as Array<Float> = [];
    public var hourlyWindSpeed      as Array<Float> = [];
    public var hourlyWindDirection  as Array<Float> = [];
    public var hourlyRainfall       as Array<Float> = [];
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
    function updateCB(loc as Position.Info) as Void {
        update(loc.position.toDegrees());
    }

    function update(coords as Array<Double>) as Void {
        System.println("Refreshing, " + coords);
        position = coords;
        var fcUrl = "https://api.met.no/weatherapi/locationforecast/2.0/compact?lat=" + coords[0] + "&lon=" + coords[1];
        var geoUrl = "https://nominatim.openstreetmap.org/reverse?format=json&lat=" + coords[0] + "&lon=" + coords[1];
        var auroraUrl = "https://www.yr.no/api/v0/locations/" + coords[0] + "," + coords[1] + "/auroraforecast";
        var waterUrl = "https://www.yr.no/api/v0/locations/" + coords[0] + "," + coords[1] + "/nearestwatertemperatures";

        // Don't bother downloading the full forecast if were low on ram
        // OOM Requests creates a ton of heap garbage that won't go away
        if (System.getSystemStats().totalMemory < 200000) {
            fetchForecastData(-403, null);
        } else {
            request(fcUrl, method(:fetchForecastData));
        }
        request(geoUrl, method(:fetchGeoData));
        request(auroraUrl, method(:fetchAuroraData));
        request(waterUrl, method(:fetchWaterData));
    }

    // Request order
    // -> Forecast -> Now
    // -> Geo
    // -> Aurora
    // -> Water
    function request(url, callback) {
        Communications.makeWebRequest(url, null, {
            :method => Communications.HTTP_REQUEST_METHOD_GET,
            :headers => { "User-Agent" => "GarminYr/Dev me@bleach.dev" },
            :responseType => Communications.HTTP_RESPONSE_CONTENT_TYPE_JSON
        }, callback);
    }

    function save() {
        Storage.setValue("hints", hints);
        Storage.setValue("fahrenheit", fahrenheit);

        Storage.setValue("geo", position);
        Storage.setValue("location", location);
        Storage.setValue("time", time.value());

        Storage.setValue("temperature", temperature);
        Storage.setValue("windSpeed", windSpeed);
        Storage.setValue("windDirection", windDirection);
        Storage.setValue("rainfall", rainfall);

        Storage.setValue("hourlyTemperature", hourlyTemperature);
        Storage.setValue("hourlyWindSpeed", hourlyWindSpeed);
        Storage.setValue("hourlyWindDirection", hourlyWindDirection);
        Storage.setValue("hourlyRainfall", hourlyRainfall);
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

        if (Storage.getValue("temperature") != null) { temperature = Storage.getValue("temperature"); }
        if (Storage.getValue("windSpeed") != null) { windSpeed = Storage.getValue("windSpeed"); }
        if (Storage.getValue("windDirection") != null) { windDirection = Storage.getValue("windDirection"); }
        if (Storage.getValue("rainfall") != null) { rainfall = Storage.getValue("rainfall"); }

        if (Storage.getValue("hourlyTemperature") != null) { hourlyTemperature = Storage.getValue("hourlyTemperature"); }
        if (Storage.getValue("hourlyWindSpeed") != null) { hourlyWindSpeed = Storage.getValue("hourlyWindSpeed"); }
        if (Storage.getValue("hourlyWindDirection") != null) { hourlyWindDirection = Storage.getValue("hourlyWindDirection"); }
        if (Storage.getValue("hourlyRainfall") != null) { hourlyRainfall = Storage.getValue("hourlyRainfall"); }
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
        if (responseCode != 200 || data == null || data["properties"] == null) {
            System.println("FC EXIT " + data);
            // If OOM use internal weather data as a backup
            if (responseCode == Communications.NETWORK_RESPONSE_OUT_OF_MEMORY || responseCode == Communications.NETWORK_RESPONSE_TOO_LARGE) {
                location += "*";

                var hourly = Weather.getHourlyForecast();
                var hours = hourly == null ? 0 : hourly.size() < 36 ? hourly.size() : 36;
                hourlyTemperature = new [hours];
                hourlyWindSpeed = new [hours];
                hourlyWindDirection = new [hours];
                hourlyRainfall = new [hours];
                hourlySymbol = new [hours];
                for (var i = 0; i < hours; i++) {
                    hourlyTemperature[i]   = hourly[i].temperature == null ? 0.0 : hourly[i].temperature.toFloat();
                    hourlyWindSpeed[i]     = hourly[i].windSpeed == null ? 0.0 : hourly[i].windSpeed;
                    hourlyWindDirection[i] = hourly[i].windBearing == null ? 0.0 : hourly[i].windBearing.toFloat();
                    hourlyRainfall[i]      = hourly[i].precipitationChance == null ? 0.0 : -hourly[i].precipitationChance.toFloat();
                    hourlySymbol[i]        = hourly[i].precipitationChance == null ? "fair_day" : (hourly[i].precipitationChance > 50 ? "rainshowers_day" : "fair_day").hashCode();
                }
                if (hours != 0) {
                    time = hourly[0].forecastTime;
                }

                var current = Weather.getCurrentConditions();
                if (current != null) {
                    if (current.temperature != null) { temperature = current.temperature.toFloat(); }
                    if (current.windSpeed != null) { windSpeed = current.windSpeed; }
                    if (current.windBearing != null) { windDirection = current.windBearing.toFloat(); }
                    if (current.relativeHumidity != null) { humidity = current.relativeHumidity.toFloat(); }
                }
            }
        } else {
            var seriesData = data["properties"]["timeseries"] as Dictionary;

            // Set instant data here first, then overwrite if nowcast succeeds
            var instantData = seriesData[0]["data"]["instant"]["details"] as Dictionary;
            temperature = instantData["air_temperature"];
            windSpeed = instantData["wind_speed"];
            windDirection = instantData["wind_from_direction"];
            humidity = instantData["relative_humidity"];
            
            var hours = seriesData.size() < 36 ? seriesData.size() : 36;
            hourlyTemperature = new [hours];
            hourlyWindSpeed = new [hours];
            hourlyWindDirection = new [hours];
            hourlyRainfall = new [hours];
            hourlySymbol = new [hours];
            for (var i = 0; i < hours; i++) {
                var data2 = seriesData[i]["data"];
                var hourData = data2["next_1_hours"];
                hourlyTemperature[i] = data2["instant"]["details"]["air_temperature"];
                hourlyWindSpeed[i] = data2["instant"]["details"]["wind_speed"];
                hourlyWindDirection[i] = data2["instant"]["details"]["wind_from_direction"];
                hourlyRainfall[i] = hourData["details"]["precipitation_amount"];
                hourlySymbol[i] = hourData["summary"]["symbol_code"].hashCode();
            }
            
            time = parseISODate(seriesData[0]["time"]);
        }

        var nowUrl = "https://api.met.no/weatherapi/nowcast/2.0/complete?lat=" + position[0] + "&lon=" + position[1];
        request(nowUrl, method(:fetchNowData));

        WatchUi.requestUpdate();
    }

    function fetchNowData(responseCode as Number, data as Dictionary?) as Void {
        System.println("NOW " + responseCode);
        if (responseCode != 200 || data == null || data["properties"] == null) {
            System.println("NOW EXIT " + data);
            return;
        }

        var seriesData = data["properties"]["timeseries"] as Dictionary;
        var instantData = seriesData[0]["data"]["instant"]["details"] as Dictionary;
        temperature = instantData["air_temperature"];
        windSpeed = instantData["wind_speed"];
        windDirection = instantData["wind_from_direction"];

        rainfall = new [seriesData.size() < 19 ? seriesData.size() : 19];
        for (var i = 0; i < rainfall.size(); i++) {
            rainfall[i] = seriesData[i]["data"]["instant"]["details"]["precipitation_rate"];
        }

        WatchUi.requestUpdate();
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
            hourlyClouds = null;
            return;
        }

        var len = data["shortIntervals"].size() > 32 ? 32 : data["shortIntervals"].size();
        hourlyAurora = new [len];
        hourlyClouds = new [len];
        for (var i = 0; i < len; i++) {
            hourlyAurora[i] = data["shortIntervals"][i]["auroraValue"];
            hourlyClouds[i] = data["shortIntervals"][i]["cloudCover"]["value"];
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