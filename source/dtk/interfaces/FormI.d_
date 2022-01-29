module dtk.interfaces.FormI;

import std.typecons;

import dtk.interfaces.WindowI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.LafI;
import dtk.interfaces.WidgetI;

import dtk.types.Size2D;
import dtk.types.Position2D;
import dtk.types.FormEvent;

import dtk.miscs.signal_tools;

import dtk.signal_mixins.Form;


interface FormI
{
    mixin(mixin_FormSignals(true));
	
    WindowI getWindow();
    FormI setWindow(WindowI window);
    FormI unsetWindow();

    DrawingSurfaceI getDrawingSurface();

    LafI getLaf();
    FormI setLaf(LafI theme);
    FormI unsetLaf();

    void propagatePosAndSizeRecalc();

    void redraw();

    Tuple!(WidgetI, Position2D) getWidgetAtPosition(Position2D point);

    WidgetI getDefaultWidget();
    FormI setDefaultWidget(WidgetI);

    void focusTo(WidgetI);

    WidgetI getFocusedWidget();
    // typeof(this) setFocusedWidget(WidgetI);
    bool isUnsetFocusedWidget();
    WidgetI focusNextWidget();
    WidgetI focusPrevWidget();
}
