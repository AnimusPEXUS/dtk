module dtk.miscs.formEventFilter;

import std.stdio;
import std.typecons;

import dtk.types.EventForm;
import dtk.types.Event;

import dtk.interfaces.WidgetI;

import dtk.widgets.Form;

// TODO: I think this function is overhead

// returns matched Event and checkMatch and action result
Tuple!(EventForm*, bool, bool) formEventFilter(
	EventForm* fe,
	Form form,
	
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
	
	/// this is for custom long filter
	/// if true is not returned - action will not be called.  checkMatch is not
	/// called (and it's return assumed to be false) if short filter didn't
	/// matched
	bool delegate(
		Form form,
		EventForm* fe,
		) checkMatch,
	
	/// this is actual action which should be started
	/// this is called then all filters successfully passed.
	bool delegate(
		Form form,
		EventForm* fe,
		) action
	)
{
	assert(form !is null);
	assert(fe !is null);
	
	debug writeln("formEventFilter fe.focusedWidget      ",fe.focusedWidget);
	debug writeln("formEventFilter fe.mouseFocusedWidget ",fe.mouseFocusedWidget);
	
	bool focusedWidget_ok;
	bool mouseFocusedWidget_ok;
	
	if (any_focusedWidget && any_mouseFocusedWidget)
	{
		goto short_check_passed;
	}
	
	{
		if (!focusedWidgetAllowNull && fe.focusedWidget is null)
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
			focusedWidget_ok = shortFocusedWidget == fe.focusedWidget;
		}
	}
	
	mouse_checks:
	
	{
		if (!mouseFocusedWidgetAllowNull && fe.mouseFocusedWidget is null)
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
			shortMouseFocusedWidget == fe.mouseFocusedWidget;
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
	return tuple(cast(EventForm*)null, false, false);
	
	short_check_passed:
	
	// TODO: fix mouseFocusedWidget_x and mouseFocusedWidget_y
	
	bool checkMatch_res;
	bool action_res;
	
	if (checkMatch !is null)
	{
		checkMatch_res = checkMatch(
			form,
			fe
			);
	}
	
	if ((checkMatch !is null && checkMatch_res) || (checkMatch is null))
	{
		action_res = action(
			form,
			fe
			);
	}
	
	return tuple(fe, checkMatch_res, action_res);
}

bool thisWidgetMouseBtnPressed(
	EventForm* event,
	Form form,
	WidgetI thisWidget
	)
{
	bool ret = event.mouseFocusedWidget == thisWidget
	&& event.event.type == EventType.mouse
	&& event.event.em.type == EventMouseType.button
	&& event.event.em.buttonState == EnumMouseButtonState.pressed;
	return ret;
}

Tuple!(bool, EnumMouseButton) thisWidgetMouseBtnPressedRegisterClickStart(
	EventForm* event,
	Form form,
	WidgetI thisWidget,
	ubyte max_clicks
	)
{
	if (thisWidgetMouseBtnPressed(event, form, thisWidget))
	{
		return form.clickSequencePress(
			thisWidget,
			event.event.em.button,
			max_clicks
			);
	}
	return tuple(false, EnumMouseButton.bl);
}

bool thisWidgetMouseBtnReleased(
	EventForm* event,
	Form form,
	WidgetI thisWidget
	)
{
	bool ret = event.mouseFocusedWidget == thisWidget
	&& event.event.type == EventType.mouse
	&& event.event.em.type == EventMouseType.button
	&& event.event.em.buttonState == EnumMouseButtonState.released;
	return ret;
}

Tuple!(bool, EnumMouseButton, ubyte) thisWidgetMouseBtnReleasedCheckClickSuccess(
	EventForm* event,
	Form form,
	WidgetI thisWidget
	)
{
	const auto ret_fail = tuple(false, EnumMouseButton.bl, cast(ubyte)0);
	if (thisWidgetMouseBtnReleased(event, form, thisWidget))
	{
		return form.clickSequenceRelease(thisWidget,event.event.em.button);
	}
	return ret_fail;
}

void thisWidgetMouseBtnClickSuccess(
	EventForm* event,
	Form form,
	WidgetI thisWidget,
	ubyte max_clicks,
	void delegate(
		EventForm* event,
		Form form,
		WidgetI thisWidget,
		) onpress,
	void delegate(
		EventForm* event,
		Form form,
		WidgetI thisWidget,
		) onrelease,
	)
{
	// const auto ret_fail = tuple(false, EnumMouseButton.bl, cast(ubyte)0);
	auto res = thisWidgetMouseBtnPressedRegisterClickStart(
		event,
		form,
		thisWidget,
		max_clicks,
		);
	//debug writeln("thisWidgetMouseBtnPressedRegisterClickStart ", res);
	if (res[0]) 
	{
		if (onpress !is null)
		{
			onpress(event, form, thisWidget);
		}
	}

	auto res2 = thisWidgetMouseBtnReleasedCheckClickSuccess(
		event, form, thisWidget,
		);
	{
		if (onrelease !is null)
		{
			onrelease(event, form, thisWidget);
		}
	}
	
	return;
}