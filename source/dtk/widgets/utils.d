module dtk.widgets.utils;

import dtk.interfaces.FormI;
import dtk.interfaces.WidgetI;

FormI getForm(WidgetI w)
{
    ubyte failure_countdown = 200;
begin:

    if (failure_countdown == 0)
    {
        throw new Exception("parrent search failure countdown exceeded");
    }

    auto ret = cast(FormI) w;
    if (ret !is null)
    {
        return ret;
    }

    w = w.getParent();
    if (w is null)
    {
        throw new Exception("widget returned null parrent while being not FormI");
    }

    failure_countdown--;

    goto begin;
}
