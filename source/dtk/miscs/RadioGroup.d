// for radio button switch automatization

module dtk.miscs.RadioGroup;

import std.stdio;
import std.typecons;

import dtk.widgets.ButtonCheck;

class RadioGroup
{
    public
    {
        ButtonCheck[] buttons;
    }

    void add(ButtonCheck b)
    {
        if (!isIn(b))
            buttons ~= b;

        auto old_rg = b.getRadioGroup();
        if (old_rg != this)
        {
            b.setRadioGroup(this);
        }
    }

    void remove(ButtonCheck b)
    {
        for (int i = cast(int) buttons.length - 1; i != -1; i += -1)
            if (buttons[i] == b)
                buttons = buttons[0 .. i] ~ buttons[i + 1 .. $];

        if (b.getRadioGroup() == this)
            b.unsetRadioGroup();
    }

    bool isIn(ButtonCheck b)
    {
        foreach (v; buttons)
        {
            if (v == b)
                return true;
        }
        return false;
    }

    void selectButton(ButtonCheck b)
    {
        foreach (v; buttons)
        {
            auto x = v == b;

            v.setToggledOn(x);
            v.redraw();
        }
    }

    ButtonCheck getSelectedButton()
    {
        foreach (v; buttons)
        {
            if (v.getToggledOn())
                return v;
        }
        return cast(ButtonCheck) null;
    }

}
