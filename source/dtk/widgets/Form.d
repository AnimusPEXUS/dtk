// root widget fro placing into Window or other pratform-provided host

module dtk.widgets.Form;

import core.sync.mutex;

import std.format;
import std.stdio;
import std.typecons;
import std.exception;
import std.datetime;

import observable.signal;

import dtk.interfaces.WindowI;
// import dtk.interfaces.FormI;
import dtk.interfaces.LaFI;
// import dtk.interfaces.Widget;
import dtk.interfaces.DrawingSurfaceI;
//import dtk.interfaces.Widget;
// import dtk.interfaces.Widget;
// import dtk.interfaces.LayoutI;

import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.LineStyle;
import dtk.types.FillStyle;
import dtk.types.Property;
import dtk.types.Event;
import dtk.types.EventWindow;
import dtk.types.EventForm;
import dtk.types.Image;
import dtk.types.Widget;

import dtk.widgets.mixins;
import dtk.widgets.TextEntry;

import dtk.miscs.signal_tools;
import dtk.miscs.DrawingSurfaceShift;

import dtk.signal_mixins.Form;

const auto FormProperties = cast(PropSetting[]) [
// PropSetting("gsun", "WidgetChild", "mainWidget", "MainWidget", ""),
PropSetting("gsun", "WindowI", "window", "Window", ""),
// PropSetting("gsun", "LaFI", "forced_laf", "ForcedLaf", ""),
// PropSetting("gsun", "Widget", "child", "Child", ""),

PropSetting("gsun", "Widget", "focusedWidget", "FocusedWidget", ""),
PropSetting("gsun", "Widget", "defaultWidget", "DefaultWidget", ""),
];

class Form : Widget
{
    mixin(mixin_FormSignals(false));
    mixin mixin_multiple_properties_define!(FormProperties);
    mixin mixin_multiple_properties_forward!(FormProperties, false);
    mixin mixin_Widget_renderImage!("Form");
    
    bool delegate(EventForm *ef) onFormSignalBeforeProcessing;
    void delegate(EventForm *ef) onFormSignalAfterProcessing;
    
    private
    {
    	SignalConnection sc_childChange;
    	SignalConnection sc_windowChange;
    	SignalConnection sc_focusedWidgetChange;
    	
    	SignalConnection sc_windowOtherEvents;
    	SignalConnection sc_windowEvents;
    	
    	SignalConnection sc_formEventHandler;
    }
    
    this()
    {
    	mixin(mixin_multiple_properties_inst(FormProperties));
    	
    	setFocusedWidget(this);
    	
    	sc_windowChange = connectToWindow_onAfterChanged(
    		delegate void(
    			WindowI o,
    			WindowI n
    			)
    		{
    			// TODO: simplify this
    			collectException(
    				{
    					debug writeln("Form window changed from ",o," to ",n);
    					
    					if (o == n)
    						return;
    					
    					sc_windowOtherEvents.disconnect();
    					sc_windowEvents.disconnect();
    					
    					if (o !is null)
    					{
    						o.unsetForm();
    					}
    					
    					if (n !is null)
    					{
    						sc_windowOtherEvents = n.connectToSignal_OtherEvents(
    							&onWindowOtherEvent
    							);
    						sc_windowEvents = n.connectToSignal_WindowEvents(
    							&onWindowEvent
    							);
    					}
    					
    					// propagateParentChangeEmission();
    					
    				}()
    				);
    		}
    		);
    	
    	sc_focusedWidgetChange = connectToFocusedWidget_onAfterChanged(
    		delegate void(
    			Widget o,
    			Widget n
    			)
    		{
    			collectException(
    				{
    					if (o !is null)
    					{
    						o.redraw();
    					}
    					if (n !is null)
    					{
    						n.redraw();
    					}
    				}()
    				);
    		}
    		);
    	
    	sc_formEventHandler = this.connectToSignal_Event(&onFormSignal);
    }

    private
    {
    	WidgetChild mainWidget;
    }
    
    Widget getMainWidget()
    {
    	return mainWidget.child;
    }

    Form setMainWidget(Widget w)
    {
    	if (mainWidget)
    	{
    		mainWidget.child.unsetParent();
    		mainWidget = null;
    	}
    	
    	if (w)
    	{
    		mainWidget = new WidgetChild(this, w); 
    		w.setParent(this);
    	}
    	
    	return this;
    }
    
	override WidgetChild[] calcWidgetChildren()
    {
    	WidgetChild[] ret;
    	if (mainWidget)
    		ret ~= mainWidget;
    	return ret;
    }    
        
    void onWindowOtherEvent(Event* event) nothrow
    {
    	collectException(
    		{
    			EventForm* fe = new EventForm();
    			
    			Widget focusedWidget = this.getFocusedWidget();
    			Widget mouseFocusedWidget;
    			Tuple!(Widget, Position2D)[] mouseFocusedWidgetBreadCrumbs;
    			
    			int mouseFocusedWidgetX = 0;
    			int mouseFocusedWidgetY = 0;
    			
    			{
    				int form_mouse_x;
    				int form_mouse_y;
    				
    				form_mouse_x = cast(int)event.em.x;
    				form_mouse_y = cast(int)event.em.y;
    				
    				getChildAtPosition(
    					Position2D(
    						cast(int)form_mouse_x,
    						cast(int)form_mouse_y
    						),
    					mouseFocusedWidgetBreadCrumbs
    					);
    				
    				if (mouseFocusedWidgetBreadCrumbs.length == 0)
    				{
    					return;
    				}

    				auto breadCrumb = mouseFocusedWidgetBreadCrumbs[$-1];
    				mouseFocusedWidget = breadCrumb[0];    				
    				
    				if (
    					{
    						auto w = cast(TextEntry)mouseFocusedWidget;
    						// debug writeln("TextEntry under action");
    						if (w !is null)
    						{
    							return w.captionMode;
    						}
    						else
    						{
    							return false;
    						}
    					}
    					())
    				{
    					if (mouseFocusedWidgetBreadCrumbs.length < 2)
    					{
    						throw new Exception(
    							"parend breadcrumb is needed, but absend"
    							);
    					}
    					breadCrumb = mouseFocusedWidgetBreadCrumbs[$-2];
    					mouseFocusedWidget = breadCrumb[0];
    				}

    				auto pos = breadCrumb[1];
    				mouseFocusedWidgetX = pos.x;
    				mouseFocusedWidgetY = pos.y;
    				
    				// debug writeln(
    					// "onWindowOtherEvent %s %sx%s".format(
    						// mouseFocusedWidgetBreadCrumbs,
    						// mouseFocusedWidgetX,
    						// mouseFocusedWidgetY
    						// )
    					// );
    			}
    			
    			fe.event = event;
    			fe.focusedWidget = focusedWidget;
    			fe.mouseFocusedWidgetBreadCrumbs= mouseFocusedWidgetBreadCrumbs;
    			fe.mouseFocusedWidget = mouseFocusedWidget;
    			fe.mouseFocusedWidgetX = mouseFocusedWidgetX;
    			fe.mouseFocusedWidgetY = mouseFocusedWidgetY;
    			
    			this.emitSignal_Event(fe);
    		}()
    		);
    }
    
    void onWindowEvent(EventWindow* event) nothrow
    {
    	collectException(
    		{
    			auto e = collectException(
    				{
    					bool propogate_resize_and_repaint = false;
    					
    					// debug writeln("form received window event: ", event.eventId);
    					
    					switch (event.eventId)
    					{
    					default:
    						break;
    					case EnumWindowEvent.resize:
    					case EnumWindowEvent.show:
    						propogate_resize_and_repaint = true;
    					}
    					
    					if (propogate_resize_and_repaint)
    					{
    						auto ds = getDrawingSurface();
    						if (ds is null)
    						{
    							debug writeln(new Exception("drawing surface unavailable"));
    							return;
    						}
    						// debug writeln("calling propagatePerformLayout");
    						propagatePerformLayout();
    						// debug writeln("calling redraw");
    						redraw();
    					}
    				}()
    				);
    			debug if (e !is null) writeln("exception: ", e);
    		}()
    		);
    }
    
    private {
    	bool pressreleaseSequenceStarted;
    	Widget pressreleaseSequenceWidget;
    	EnumMouseButton pressreleaseSequenceBtn;
    	
    	Widget mouseFocusedWidget;
    }
    
    
    void onFormSignal(EventForm* event) nothrow
    {
    	auto err = collectException(
    		{
    			if (onFormSignalBeforeProcessing !is null)
    			{
    				auto res = onFormSignalBeforeProcessing(event);
    				if (res == true)
    				{
    					return;
    				}
    			}
    			
    			scope(exit)
    			{
    				if (onFormSignalAfterProcessing !is null)
    				{
    					onFormSignalAfterProcessing(event);
    				}
    			}
    			
    			if (event.mouseFocusedWidget != mouseFocusedWidget)
    			{
    				Widget old = mouseFocusedWidget;
    				mouseFocusedWidget = event.mouseFocusedWidget;
    				if (old !is null)
    				{
    					old.intVisuallyRelease(old, event);
    					old.intMouseLeave(old, mouseFocusedWidget, event);
    				}
    				if (this.pressreleaseSequenceStarted
    					&& this.pressreleaseSequenceWidget == mouseFocusedWidget)
    				{
    					mouseFocusedWidget.intVisuallyPress(
    						mouseFocusedWidget,
    						event
    						);
    				}
    				mouseFocusedWidget.intMouseEnter(
    					old,
    					mouseFocusedWidget,
    					event
    					);
    			}
    			
    			switch (event.event.type)
    			{
    			default:
    				return;
    			case EventType.mouse:
    				switch (event.event.em.type)
    				{
    				default:
    					return;
    				case EventMouseType.movement:
    					// debug writeln("mouse widget: ", mouseFocusedWidget);
    					event.mouseFocusedWidget.intMouseMove(
    						event.mouseFocusedWidget,
    						event
    						);
    					return;
    				case EventMouseType.button:
    					switch (event.event.em.buttonState)
    					{
    					default:
    						return;
    					case EnumMouseButtonState.pressed:
    						pressreleaseSequenceStarted = true;
    						pressreleaseSequenceWidget = event.mouseFocusedWidget;
    						pressreleaseSequenceBtn = event.event.em.button;
    						setFocusedWidget(event.mouseFocusedWidget);
    						event.mouseFocusedWidget.intMousePress(
    							event.mouseFocusedWidget,
    							event
    							);
    						event.mouseFocusedWidget.intVisuallyPress(
    							event.mouseFocusedWidget,
    							event
    							);
    						return;
    					case EnumMouseButtonState.released:
    						event.mouseFocusedWidget.intMouseRelease(
    							event.mouseFocusedWidget,
    							event
    							);
    						event.mouseFocusedWidget.intVisuallyRelease(
    							event.mouseFocusedWidget,
    							event
    							);
    						if (pressreleaseSequenceStarted
    							&& pressreleaseSequenceWidget == event.mouseFocusedWidget
    						&& pressreleaseSequenceBtn == event.event.em.button)
    						{
    							event.mouseFocusedWidget.intMousePressRelease(
    								event.mouseFocusedWidget,
    								event
    								);
    						}
    						pressreleaseSequenceStarted = false;
    						return;
    					}
    				}
    			case EventType.keyboard:
    				switch (event.event.ek.keyState)
    				{
    				default:
    					return;
    				case EnumKeyboardKeyState.pressed:
    					event.focusedWidget.intKeyboardPress(
    						event.focusedWidget,
    						event
    						);
    					return;
    				case EnumKeyboardKeyState.released:
    					event.focusedWidget.intKeyboardRelease(
    						event.focusedWidget,
    						event
    						);
    					return;
    				}
    			case EventType.textInput:
    				switch (event.event.ek.keyState)
    				{
    				default:
    					return;
    				case EnumKeyboardKeyState.pressed:
    					event.focusedWidget.intTextInput(
    						event.focusedWidget,
    						event
    						);
    					return;
    				}
    			}
    		}()
    		);
    	debug if (err !is null)
    	{
    		writeln("form exception caught: ", err);
    	}
    }
    
    // don't allow get Parent at From
    override Widget getParent()
    {
    	return null;
    }
    
    // don't allow set Parent at From
    override Form setParent(Widget v)
    {
    	throw new Exception("trying to set Parent at Form");
    	// unsetParent();
    	// return this;
    }
    
    private Widget focusXWidget(Widget delegate() getXFocusableWidget)
    {
        Widget cfw;
        
        if (isSetFocusedWidget())
        {
            cfw = getFocusedWidget();
        }
        
        auto w = getXFocusableWidget();
        setFocusedWidget(w);
        if (w is null)
        {
            unsetFocusedWidget();
        }
        
        return (isSetFocusedWidget() ? getFocusedWidget() : null);
    }
    
    Widget focusNextWidget()
    {
        return focusXWidget(&getNextFocusableWidget);
    }
    
    Widget focusPrevWidget()
    {
        return focusXWidget(&getPrevFocusableWidget);
    }
    
    Widget getNextFocusableWidget()
    {
        return null;
    }
    
    Widget getPrevFocusableWidget()
    {
        return null;
    }
    
}
