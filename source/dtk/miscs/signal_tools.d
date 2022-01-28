module dtk.miscs.signal_tools;

import std.typecons;

import observable.signal;

public import observable.signal : SignalConnection, SignalConnectionContainer;

import dtk.types.Event;
import dtk.types.Position2D;

import dtk.interfaces.FormI;
import dtk.interfaces.WidgetI;


mixin template mixin_installSignal(
	string name,
	string var_name,
	bool for_interface,
	P...
	)
{
	import std.format;
	import observable.signal;
	
	static if (!for_interface)
	{
		private {
			mixin(
				q{
					Signal!(P) %1$s;
				}.format(var_name)
				);
		}
	}
	
	static if (!for_interface)
	{
		mixin(
			q{
				SignalConnection connectToSignal_%1$s( void delegate(P) nothrow cb)
				{
					SignalConnection conn;
					this.%2$s.socket.connect(conn, cb);
					return conn;
				}
				
				void emitSignal_%1$s(P...)(P args)
				{
					this.%2$s.emit(args);
				}
			}.format(name,var_name)
			);
	}
	else
	{
		mixin(
			q{
				SignalConnection connectToSignal_%1$s( void delegate(P) nothrow cb);
				void emitSignal_%1$s(P...)(P args);
			}.format(name)
			);
	}
}

// returns matched Event and checkMatch and action result
Tuple!(Event*, bool, bool) eventFilter(
	Event* e,
	FormI form,
	
	// ------- short filter start -------
	bool any_focusedWidget,
	bool any_mouseFocusedWidget,
	
	bool focusedWidgetAllowNull,
	bool mouseFocusedWidgetAllowNull,
	
	// not checked if any_focusedWidget is true,
	// if this is null, this is same as if any_focusedWidget is true
	WidgetI shortFocusedWidget,
	
	// not checked if any_mouseFocusedWidget is true
	// if this is null, this is same as if any_mouseFocusedWidget is true
	WidgetI shortMouseFocusedWidget,
	
	// if false, focus or mouseFocus success match is ok. if true - both
	// focus or mouseFocus must match to success
	bool and_evaluation,
	// ------- short filter end -------
	
	/// this is long filter
	/// if true is not returned - action will not be called.  checkMatch is not
	/// called (and it's return assumed to be false) if prefilter isn't matched
	bool delegate(
		FormI form,
		Event* e,
		WidgetI focusedWidget,
		WidgetI mouseFocusedWidget,
		ulong mouseFocusedWidget_x,
		ulong mouseFocusedWidget_y
		) checkMatch,
	
	/// this is actual action which should be started
	/// this is called then all filters successfully passed.
	bool delegate(
		FormI form,
		Event* e,
		WidgetI focusedWidget,
		WidgetI mouseFocusedWidget,
		ulong mouseFocusedWidget_x,
		ulong mouseFocusedWidget_y
		) action
	)
{
	bool focusedWidget_ok;
	bool mouseFocusedWidget_ok;
	
	WidgetI focusedWidget = form.getFocusedWidget();
	WidgetI mouseFocusedWidget;
	
	ulong mouseFocusedWidget_x = 0;
	ulong mouseFocusedWidget_y = 0;
	
	{
		if (e.eventType == EventType.mouse)
		{
			auto res = form.getWidgetAtPosition(
				Position2D(
					e.em.x, 
					e.em.y
					)				 
				);
			mouseFocusedWidget = res[0];
			auto pos = res[1];
			mouseFocusedWidget_x = pos.x;
			mouseFocusedWidget_y = pos.y;
		}
		else
		{
			// TODO: todo
		}
	}
	
	if (any_focusedWidget && any_mouseFocusedWidget)
	{
		goto short_check_passed;
	}
	
	{
		if (!focusedWidgetAllowNull && focusedWidget is null)
		{
			focusedWidget_ok = false;
			goto mouse_checks;
		}
		
		if (any_focusedWidget)
		{
			focusedWidget_ok = true;
			goto mouse_checks;
		}
		
		if (shortFocusedWidget is null)
		{
			focusedWidget_ok = true;
			goto mouse_checks;
		}
		else
		{
			focusedWidget_ok = shortFocusedWidget == focusedWidget;
		}
	}
	
	mouse_checks:
	
	{
		if (!mouseFocusedWidgetAllowNull && mouseFocusedWidget is null)
		{
			mouseFocusedWidget_ok = false;
			goto check_oks;
		}
		
		if (any_mouseFocusedWidget)
		{
			mouseFocusedWidget_ok = true;
			goto check_oks;
		}
		
		if (shortMouseFocusedWidget is null)
		{
			mouseFocusedWidget_ok = true;
			goto check_oks;
		}
		else
		{
			mouseFocusedWidget_ok = 
			shortMouseFocusedWidget == mouseFocusedWidget;
		}
	}
	
	check_oks:
	
	if (and_evaluation)
	{
		if (focusedWidget_ok && mouseFocusedWidget_ok)
			goto short_check_passed;
		else
			goto short_checks_failed;
	}
	else
	{
		if (focusedWidget_ok || mouseFocusedWidget_ok)
			goto short_check_passed;
		else
			goto short_checks_failed;
	}
	
	// goto short_check_passed;
	
	short_checks_failed:
	return tuple(cast(Event*)null, false, false);
	
	short_check_passed:
	
	// TODO: fix mouseFocusedWidget_x and mouseFocusedWidget_y
	
	bool checkMatch_res;
	bool action_res;
	
	checkMatch_res = checkMatch(
		form,
		e,
		focusedWidget,
		mouseFocusedWidget,
		mouseFocusedWidget_x,
		mouseFocusedWidget_y
		);
	
	if (checkMatch_res)
	{
		action_res = action(
			form,
			e,
			focusedWidget,
			mouseFocusedWidget,
			mouseFocusedWidget_x,
			mouseFocusedWidget_y
			);
	}
	
	return tuple(e, checkMatch_res, action_res);
}
