module dtk.signal_mixins.Form;

import std.format;

import dtk.miscs.signal_tools;

string mixin_FormSignals(bool for_interface)
{
    string ret = q{
        mixin mixin_installSignal!(
            "Event", 
            "signal_event",
            %1$s,
            EventForm*
            );
    }.format(for_interface);
    return ret;
}