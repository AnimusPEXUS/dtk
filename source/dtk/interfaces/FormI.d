module dtk.interfaces.FormI;

import dtk.interfaces.WindowI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.ThemeI;
import dtk.interfaces.WidgetI;
/* import dtk.types.Theme; */
import dtk.types.Size2D;
import dtk.types.Position2D;

interface FormI
{
    typeof(this) setWindow(WindowI window);
    typeof(this) unsetWindow();

    DrawingSurfaceI getDrawingSurface();
    /* void setDrawingSurface(DrawingSurfaceI);
    void unsetDrawingSurface(); */

    ThemeI getTheme();
    typeof(this) setTheme(ThemeI theme);
    typeof(this) unsetTheme();

    void positionAndSizeRequest(Position2D, Size2D);
    void recalculateChildrenPositionsAndSizes();

    void redraw();

    WidgetI getWidgetAtVisible(Position2D point);

    WidgetI getFocusedWidget();
    bool isSetFocusedWidget();
    bool isUnsetFocusedWidget();
    WidgetI focusNextWidget();
    WidgetI focusPrevWidget();
}
