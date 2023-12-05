import Toybox.Lang;
import Toybox.WatchUi;

class BaseDelegate extends BehaviorDelegate {

    public static var pageCount = 6;
    private static var page as Number = 0;
    private var startX as Number = 0;

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
        var menu = new Menu2({:title=> "Yr " + VERSION });
        menu.addItem(new MenuItem("Location", data.autoLocation ? "Automatic (GPS)" : data.location, 0, {}));
        menu.addItem(new MenuItem("Temperature Units", data.fahrenheit ? "Fahrenheit" : "Celcius", 1, {}));
        WatchUi.pushView(menu, new SettingsDelegate(), WatchUi.SLIDE_BLINK);
        return true;
    }

    function onNextPage() as Boolean {
        if (data.temperatures.size() < 1) {
            return false;
        }

        page = page == (pageCount - 1) ? 0 : page + 1;

        var view = getView(page);
        WatchUi.switchToView(view[0], view[1], WatchUi.SLIDE_UP);
        return true;
    }

    function onPreviousPage() as Boolean {
        if (data.temperatures.size() < 1) {
            return false;
        }
        
        page = page == 0 ? pageCount - 1 : page - 1;

        var view = getView(page);
        WatchUi.switchToView(view[0], view[1], WatchUi.SLIDE_DOWN);
        return true;
    }

    // Vivoactive 3/4 swipe controls
    // Note: Only supported on API 3.3.0+ so vivoactive 3 has kinda broken interactions.
    function onDrag(event as DragEvent) as Boolean {
        if (NOGLANCE_MODE >= 1) {
            if (event.getType() == 0 /* START */) {
                startX = event.getCoordinates()[0];
            } else if (event.getType() == 2 /* STOP */) {
                if (startX - event.getCoordinates()[0] > (System.getDeviceSettings().screenWidth / 4)) {
                    onSelectOrSwipe(false);
                }
            }
            return true;
        }

        return BehaviorDelegate.onDrag(event);
    }

    function onSelect() as Boolean {
        return NOGLANCE_MODE >= 2 ? (onSelectOrSwipe(true) ? true : onNextPage()) : (NOGLANCE_MODE  >= 1 ? onNextPage() : onSelectOrSwipe(false));
    }

    // If softAction then only iterate through information and don't open any menus
    // Returns whether the next page should be displayed in softAction mode
    function onSelectOrSwipe(softAction as Boolean) as Boolean {
        return false;
    }

    function getView(page as Number) as Array<View or BehaviorDelegate> {
        switch (page) {
            case 0: return  [ new SummaryView(), new SummaryDelegate() ];
            case 1: return  [ new DailyView(),   new DailyDelegate() ];
            case 2: return  [ new HourlyView(),  new HourlyDelegate() ];
            case 3: return  [ new GraphView(),   new GraphDelegate() ];
            case 4: return  [ new AuroraView(),  new BaseDelegate() ];
            default: return [ new WaterView(),   new BaseDelegate() ];
        }
    }
}