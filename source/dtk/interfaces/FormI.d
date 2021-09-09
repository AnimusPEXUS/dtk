module dtk.interfaces.FormI;

import dtk.interfaces.WindowI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.LafI;
import dtk.interfaces.WidgetI;

import dtk.types.Size2D;
import dtk.types.Position2D;

interface FormI
{
    typeof(this) setWindow(WindowI window);
    typeof(this) unsetWindow();

    DrawingSurfaceI getDrawingSurface();

    LafI getLaf();
    typeof(this) setLaf(LafI theme);
    typeof(this) unsetLaf();

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
