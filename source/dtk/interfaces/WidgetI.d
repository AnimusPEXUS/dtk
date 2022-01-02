module dtk.interfaces.WidgetI;

import std.typecons;

import dtk.interfaces.FormI;
import dtk.interfaces.LayoutI;
import dtk.interfaces.DrawingSurfaceI;
import dtk.interfaces.event_receivers;

// import dtk.types.Event;
import dtk.types.EventWindow;
import dtk.types.EventKeyboard;
import dtk.types.EventMouse;
import dtk.types.EventTextInput;
import dtk.types.Size2D;
import dtk.types.Position2D;

import dtk.widgets.Layout;

interface WidgetI : EventReceiverWidgetI
{

    typeof(this) setParentLayout(LayoutI layout);
    typeof(this) unsetParentLayout();
    bool isUnsetParentLayout();
    LayoutI getParentLayout();

    FormI getForm();

    DrawingSurfaceI getDrawingSurface();

    void positionAndSizeRequest(Position2D, Size2D);
    void recalculateChildrenPositionsAndSizes();
    void redraw();

    // typeof(this) setPosition(Position2D);
    // typeof(this) unsetPosition();
    // Position2D getPosition();
    // bool isUnsetPosition();

    // typeof(this) setSize(Size2D);
    // typeof(this) unsetSize();
    // Size2D getSize();
    // bool isUnsetSize();
    ulong getX();
    ulong getY();
    ulong getWidth();
    ulong getHeight();

    typeof(this) setX(ulong);
    typeof(this) setY(ulong);
    typeof(this) setWidth(ulong);
    typeof(this) setHeight(ulong);
    
    Tuple!(WidgetI, ulong, ulong) getWidgetAtPosition(Position2D point);

    WidgetI getNextFocusableWidget();
    WidgetI getPrevFocusableWidget();

    static foreach(v; ["Keyboard", "Mouse", "TextInput"])
    {
    	import std.format;
    	mixin(
    		q{
    			void set%1$sEvent(
    				string name, 
    				void delegate(
    					Event%1$s *e,
    					ulong mouse_widget_local_x,
    					ulong mouse_widget_local_y,
    					) handler
    				);
    			void call%1$sEvent(
    				string name, 
    				Event%1$s* e,
    				ulong mouse_widget_local_x,
    				ulong mouse_widget_local_y,
    				);
    			void unset%1$sEvent(string name);
    		}.format(v)
    		);
    }


}
