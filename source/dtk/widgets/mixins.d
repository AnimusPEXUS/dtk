module dtk.widgets.mixins;

enum GetterSetterBothOrNone
{
    none = 0,
    getter = 0b1,
    setter = 0b10,
    getterAndSetter = getter | setter,
    nullable = 0b100,
    getterSetterAndNullable = getterAndSetter | nullable,
}

mixin template mixin_variable(GetterSetterBothOrNone settings, string public_or_private,
        string internal_name, string external_name, string type_, string call_on_set)
{
    mixin(function string() {

        string ret;
        assert(public_or_private == "private" || public_or_private == "public");

        auto getter_ = (settings & GetterSetterBothOrNone.getter) != 0;
        auto setter_ = (settings & GetterSetterBothOrNone.setter) != 0;
        auto nullable_ = (settings & GetterSetterBothOrNone.nullable) != 0;
        string nullable_type_ = "Nullable!(" ~ type_ ~ ")";
        string type_nullable_if_nullable = (nullable_ ? nullable_type_ : type_);

        if (internal_name != "")
        {
            ret ~= public_or_private ~ "{";
            ret ~= type_nullable_if_nullable ~ " " ~ internal_name ~ ";";
            ret ~= "}";
        }

        if (getter_)
        {
            ret ~= type_ ~ " get" ~ external_name ~ "() {";
            if (internal_name != "")
            {
                if (nullable_)
                {
                    ret ~= "return " ~ internal_name ~ ".get();";
                }
                else
                {
                    ret ~= "return " ~ internal_name ~ ";";
                }
            }
            else
            {
                ret ~= "static assert(false, \"this variable mixin template were used without internal_name\"); return " ~ type_ ~ ".init;";
            }

            ret ~= "}";
        }

        if (setter_)
        {
            ret ~= "void set" ~ external_name ~ "(" ~ type_ ~ " value) {";
            if (internal_name != "")
            {
                if (!nullable_)
                {
                    ret ~= internal_name ~ "= value;";
                }
                else
                {
                    ret ~= internal_name ~ "= nullable(value);";
                }
            }

            if (call_on_set != "")
            {
                ret ~= call_on_set ~ "();";
            }
            ret ~= "}";
            // this comment is to avoid dfmt from squishing this empty line
            ret ~= "void set" ~ external_name ~ "(" ~ nullable_type_ ~ " value) {";
            if (internal_name != "")
            {
                ret ~= internal_name ~ "= value.get();";
            }
            if (call_on_set != "")
            {
                ret ~= call_on_set ~ "();";
            }
            ret ~= "}";
        }

        if (nullable_ && internal_name)
        {
            ret ~= "bool isnull" ~ external_name ~ "() {";
            ret ~= "return " ~ internal_name ~ ".isNull();";
            ret ~= "}";
            // this comment is to avoid dfmt from squishing this empty line
            ret ~= "void nullify" ~ external_name ~ "() {";
            ret ~= internal_name ~ ".nullify();";
            if (call_on_set != "")
            {
                ret ~= call_on_set ~ "();";
            }
            ret ~= "}";
        }

        return ret;
    }());
}

mixin template mixin_getForm_from_WidgetI()
{
    import dtk.widgets.utils;

    FormI getForm()
    {
        return dtk.widgets.utils.getForm(this);
    }
}

mixin template mixin_widgetPositionsAndSizes()
{
    private
    {
        Point positionOnParent;

        // set -1 if unset;
        Size _minimumSize;
        Size _maximumSize;

        // minimum size, which is summ of minimum sizes of all
        // non-scrollable/non-clipped children + own minimum size
        Size _calculatedMinimumSize;

        // this value is for redrawing widgets and to route pointer
        // events
        Size _calculatedSize;
    }

    Size getMinimumSize()
    {
        return _minimumSize;
    }

    Size getMaximumSize()
    {
        return _maximumSize;
    }

}

mixin template mixin_getWidgetType(string value)
{
    string getWidgetType()
    {
        return value;
    }
}
