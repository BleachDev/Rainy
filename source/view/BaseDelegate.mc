import Toybox.Lang;
import Toybox.WatchUi;

class BaseDelegate extends BehaviorDelegate {

    public static var pageCount = 7;
    public static var page as Number = 0;
    private var startX as Number = 0;

    public static var showWater = false;

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() {
        var menu = new Menu2({:title=> "Rainy " + VERSION });
        menu.addItem(new MenuItem("Location", data.autoLocation ? "Automatic (GPS)" : data.location, 0, {}));
        menu.addItem(new MenuItem("Page Order", data.pageOrder ? "Graph First" : "Tables First", 1, {}));
        menu.addItem(new MenuItem("Wind Units", SettingsDelegate.WIND_UNITS[data.windUnits], 2, {}));
        menu.addItem(new MenuItem("Pro Info Page", data.showUpgrade ? "Show" : "Don't Show", 3, {}));
        menu.addItem(new MenuItem("Refresh Weather", "Updated " + ((Time.now().value() - data.time.value()) / 60) + " minutes ago", 4, {}));
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

    // Swipe left to go to next page in multiplage views
    function onDrag(event as DragEvent) as Boolean {
        if (event.getType() == 0 /* START */) {
            startX = event.getCoordinates()[0];
        } else if (event.getType() == 2 /* STOP */) {
            if (startX - event.getCoordinates()[0] > (System.getDeviceSettings().screenWidth / 4)) {
                onSelectOrSwipe(false);
            }
        }
        
        return BehaviorDelegate.onDrag(event);
    }

    function onSelect() as Boolean {
        return NOGLANCE_MODE >= 2 ? (onSelectOrSwipe(true) ? true : onNextPage()) : (NOGLANCE_MODE >= 1 ? onNextPage() : onSelectOrSwipe(false));
    }

    // If softAction then only iterate through information and don't open any menus
    // Returns whether the next page should be displayed in softAction mode
    function onSelectOrSwipe(softAction as Boolean) as Boolean {
        BaseView.page = (BaseView.page + 1) % BaseView.pages;
        WatchUi.requestUpdate();
        return BaseView.page != 0 || !softAction;
    }

    function getView(page as Number) as Array<View or BehaviorDelegate> {
        pageCount = 7 - (showWater ? 0 : 1) - (data.showUpgrade && !INSTINCT_MODE ? 0 : 1);
        switch (page == 5 && !showWater ? 6 : data.pageOrder ? (page == 1 ? 3 : page == 3 ? 1 : page) : page) {
            case 0: return  [ new SummaryView(), new BaseDelegate() ];
            case 1: return  [ new DailyView(),   new BaseDelegate() ];
            case 2: return  [ new HourlyView(),  new BaseDelegate() ];
            case 3: return  [ new GraphView(),   new BaseDelegate() ];
            case 4: return  [ new AuroraView(),  new BaseDelegate() ];
            case 5: return  [ new WaterView(),   new BaseDelegate() ];
            default: return [ new UpgradeView(), new BaseDelegate() ];
        }
    }
}