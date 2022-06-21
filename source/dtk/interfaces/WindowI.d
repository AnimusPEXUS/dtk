module dtk.interfaces.WindowI;

import std.typecons;

import dtk.types.Position2D;
import dtk.types.Size2D;

import dtk.types.Event;
import dtk.types.EventWindow;
import dtk.types.EventKeyboard;
import dtk.types.EventMouse;
import dtk.types.EventTextInput;
import dtk.types.Widget;
import dtk.types.WindowBorderSizes;
// import dtk.types.EnumMouseCursor;

import dtk.wm.WindowDecoration;

import dtk.interfaces.PlatformI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.LaFI;

// import dtk.signal_mixins.Window;

import dtk.widgets.Form;

interface WindowI
{
    // mixin(mixin_WindowSignals(true));
    // mixin(mixin_ContainerSignals(true));

    PlatformI getPlatform();

    LaFI getLaf();

    WindowI setDebugName(dstring value);
    void printParams();

    LaFI getForcedLaf();
    WindowI setForcedLaf(LaFI);
    WindowI unsetForcedLaf();

    WindowI setForm(Form form);
    WindowI unsetForm();
    Form getForm();

    WindowI setArtificalWD(WindowDecoration wd);
    WindowI unsetArtificalWD();
    WindowDecoration getArtificalWD();

    DrawingSurfaceI getDrawingSurface();
    DrawingSurfaceI getFormDrawingSurface();

    int getX();
    int getY();
    int getWidth();
    int getHeight();
    int getFormX();
    int getFormY();
    int getFormWidth();
    int getFormHeight();

    // Setting values to this variables - does not actually changes window's
    // position or size. Use setPosition() and/or setSize() function to change
    // window's position and/or size.
    WindowI setX(int v);
    WindowI setY(int v);
    WindowI setWidth(int v);
    WindowI setHeight(int v);
    WindowI setFormX(int v);
    WindowI setFormY(int v);
    WindowI setFormWidth(int v);
    WindowI setFormHeight(int v);

    dstring getTitle();
    WindowI setTitle(dstring value);

    Tuple!(bool, Position2D) getMousePosition();

    WindowBorderSizes getBorderSizes();

    void formDesiredPosSizeChanged();

    WindowI setPosition(Position2D pos);
    WindowI setSize(Size2D size);
    Position2D getPosition();
    Size2D getSize();

    WindowI setFormPosition(Position2D pos);
    WindowI setFormSize(Size2D size);
    Position2D getFormPosition();
    Size2D getFormSize();

    Size2D getArtificalWDSize();
    // WindowI setArtificalWDSize(Size2D size)

    // void setCursorByType(EnumMouseCursor type);

    void redraw();

    // void handleEvent(Event* event);
}
