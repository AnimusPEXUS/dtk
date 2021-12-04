// for radio button switch automatization

module dtk.miscs.RadioGroup;

import std.stdio;
import std.typecons;

import dtk.widgets;

class RadioGroup
{
    public
    {
        ButtonRadio[] buttons;
    }

    void add(ButtonRadio b)
    {
        if (!isIn(b))
            buttons ~= b;

        auto old_rg = b.getRadioGroup();
        if (old_rg != this)
        {
            b.setRadioGroup(this);
        }
    }

    void remove(ButtonRadio b)
    {
        for (int i = cast(int) buttons.length - 1; i != -1; i += -1)
            if (buttons[i] == b)
                buttons = buttons[0 .. i] ~ buttons[i + 1 .. $];

        if (b.getRadioGroup() == this)
            b.unsetRadioGroup();
    }

    bool isIn(ButtonRadio b)
    {
        foreach (v; buttons)
            if (v == b)
                return true;
        return false;
    }

    void selectButton(ButtonRadio b)
    {
        foreach (v; buttons)
        {
            auto x = v == b;

            v.setChecked(x);
            v.redraw();
        }
    }

    ButtonRadio getSelectedButton()
    {
        foreach (v; buttons)
            if (v.getChecked())
                return v;
        return cast(ButtonRadio) null;
    }

}
