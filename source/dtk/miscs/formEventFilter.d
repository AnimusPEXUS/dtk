module dtk.miscs.formEventFilter;

import std.typecons;

import dtk.types.FormEvent;

import dtk.interfaces.WidgetI;

import dtk.widgets.Form;

// returns matched Event and checkMatch and action result
Tuple!(FormEvent*, bool, bool) formEventFilter(
	FormEvent* fe,
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
	
	/// this is long filter
	/// if true is not returned - action will not be called.  checkMatch is not
	/// called (and it's return assumed to be false) if prefilter isn't matched
	bool delegate(
		Form form,
		FormEvent* fe,
		) checkMatch,
	
	/// this is actual action which should be started
	/// this is called then all filters successfully passed.
	bool delegate(
		Form form,
		FormEvent* fe,
		) action
	)
{
	assert(form !is null);
	assert(fe !is null);
	
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
	return tuple(cast(FormEvent*)null, false, false);
	
	short_check_passed:
	
	// TODO: fix mouseFocusedWidget_x and mouseFocusedWidget_y
	
	bool checkMatch_res;
	bool action_res;
	
	checkMatch_res = checkMatch(
		form,
		fe
		);
	
	if (checkMatch_res)
	{
		action_res = action(
			form,
			fe
			);
	}
	
	return tuple(fe, checkMatch_res, action_res);
}