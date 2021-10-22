module dtk.miscs.TextProcessor;

import std.conv;
import std.format;
import std.container;
import std.range.primitives;
import std.stdio;
import std.utf;

import dtk.interfaces.FontMgrI;

import dtk.types.Image;
import dtk.types.Color;
import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.fontinfo;

enum GenImageFromSubimagesLayout
{
    horizontalLeftToRightAlignTop, // russian, english chars
    verticalTopToBottomAlignLeft, // russian, english, hebrew lines
    horizontalRightToLeftAlignTop, // hebrew chars, japanese lines
    verticalTopToBottomAlignRight, // japanese chars
}

Image genImageFromSubimages(ulong max_width, ulong max_height, ulong x, ulong y, ulong width, ulong height,

        GenImageFromSubimagesLayout layout,
        ulong delegate() getSubimageCount,
        ulong delegate(ulong subimage_index) getSubimageWidth,
        ulong delegate(ulong subimage_index) getSubimageHeight,
        Image delegate(
            ulong subimage_index,
            ulong x, ulong y,
            ulong width, ulong height
        ) getSubimage,)
{
    Image ret = new Image(width, height);

    if (x > width || y > height)
        return ret;

    auto actual_width = (x + width > max_width ? max_width - x : width);
    auto actual_height = (y + height > max_height ? max_height - y : height);

    auto x2 = x + width;
    auto y2 = y + height;

    ulong first_visible_item;
    bool first_visible_item_found;
    ulong first_visible_item_offset;

    ulong last_visible_item;
    bool last_visible_item_found;
    ulong last_visible_item_offset;

    ulong subimage_count = getSubimageCount();

    {
        ulong processed_size;

        {
            ulong z;
            ulong z2;

            ulong current_size;

            switch (layout)
            {
            default:
                throw new Exception("unknown layout");
            case GenImageFromSubimagesLayout.horizontalLeftToRightAlignTop:
                z = x;
                z2 = x2;
                break;
            case GenImageFromSubimagesLayout.verticalTopToBottomAlignLeft:
                z = y;
                z2 = y2;
                break;
            }

            for (ulong i = 0; i != subimage_count; i++)
            {

                switch (layout)
                {
                default:
                    throw new Exception("unknown layout");
                case GenImageFromSubimagesLayout.horizontalLeftToRightAlignTop:
                    current_size = getSubimageWidth(i);
                    break;
                case GenImageFromSubimagesLayout.verticalTopToBottomAlignLeft:
                    current_size = getSubimageHeight(i);
                    break;
                }

                if (!first_visible_item_found && z >= processed_size
                        && z < processed_size + current_size)
                {
                    first_visible_item = i;
                    first_visible_item_found = true;
                    first_visible_item_offset = z - processed_size;
                }

                if (!last_visible_item_found && z2 >= processed_size
                        && z2 < processed_size + current_size)
                {
                    last_visible_item = i;
                    last_visible_item_found = true;
                    last_visible_item_offset = processed_size + current_size - z2;
                }

                if (first_visible_item_found && last_visible_item_found)
                    break;

                processed_size += current_size;
            }
        }
    }

    if (!first_visible_item_found)
        return ret;

    if (!last_visible_item_found)
    {
        last_visible_item = subimage_count - 1;
    }

    {
        ulong items_count = last_visible_item - first_visible_item;

        ulong delegate(ulong i) calc_loop_target_x;
        ulong delegate(ulong i) calc_loop_target_y;
        ulong delegate(ulong i) calc_loop_source_x;
        ulong delegate(ulong i) calc_loop_source_y;
        ulong delegate(ulong i) calc_loop_source_width;
        ulong delegate(ulong i) calc_loop_source_height;

        switch (layout)
        {
        default:
            throw new Exception("unknown layout");
        case GenImageFromSubimagesLayout.horizontalLeftToRightAlignTop:
            calc_loop_target_x = delegate ulong(ulong i) {
                if (i == 0)
                    return 0;
                ulong width;
                for (ulong j = 0; j <= i; j++)
                {
                    width += getSubimageWidth(first_visible_item + j);
                }
                return width - first_visible_item_offset;
            };

            calc_loop_target_y = delegate ulong(ulong i) { return 0; };

            calc_loop_source_x = delegate ulong(ulong i) {
                if (i == 0)
                    return first_visible_item_offset;
                return 0;
            };

            calc_loop_source_y = delegate ulong(ulong i) { return 0; };

            calc_loop_source_width = delegate ulong(ulong i) {
                if (i == 0)
                    return getSubimageWidth(first_visible_item + i) - first_visible_item_offset;
                return 0;
            };

            calc_loop_source_height = delegate ulong(ulong i) {
                return getSubimageHeight(first_visible_item + i);
            };
            break;
        case GenImageFromSubimagesLayout.verticalTopToBottomAlignLeft:
            calc_loop_target_x = delegate ulong(ulong i) { return 0; };

            calc_loop_target_y = delegate ulong(ulong i) {
                if (i == 0)
                    return 0;
                ulong height;
                for (ulong j = 0; j <= i; j++)
                {
                    height += getSubimageHeight(first_visible_item + j);
                }
                return height - first_visible_item_offset;
            };

            calc_loop_source_x = delegate ulong(ulong i) { return 0; };

            calc_loop_source_y = delegate ulong(ulong i) {
                if (i == 0)
                    return first_visible_item_offset;
                return 0;
            };

            calc_loop_source_width = delegate ulong(ulong i) {
                return getSubimageWidth(first_visible_item + i);
            };

            calc_loop_source_height = delegate ulong(ulong i) {
                if (i == 0)
                    return getSubimageHeight(first_visible_item + i) - first_visible_item_offset;
                return 0;
            };
            break;
        }

        for (ulong i = 0; i <= items_count; i++)
        {
            ret.putImage(
                calc_loop_target_x(i),
                calc_loop_target_y(i),
                getSubimage(
                    i,
                    calc_loop_source_x(i), calc_loop_source_y(i),
                    calc_loop_source_width(i), calc_loop_source_height(i)
                    )
                );
        }
    }

    return ret;
}

class TextChar
{
    TextLine parent_line;

    dchar chr;

    ulong width;
    ulong height;

    GlyphRenderResult* glyph;

    this(TextLine parent_line)
    {
        this.parent_line = parent_line;
    }

    void rerender(TextView text_view)
    {
        loadGlyph(text_view);
    }

    alias reprocess = rerender;

    void loadGlyph(TextView text_view)
    {
        writeln("rendering char: ", chr);

        auto font_mgr = text_view.font_mgr;
        auto face = font_mgr.loadFace("/usr/share/fonts/go/Go-Regular.ttf");

        {
            auto x = parent_line.parent_text.faceSize;
            face.setCharSize(x, x);
        }
        {
            auto x = parent_line.parent_text.faceResolution;
            face.setCharResolution(x, x);
        }

        try
        {
            glyph = face.renderGlyphByChar(chr);
            width = glyph.bitmap.width;
            height = glyph.bitmap.height;
        }
        catch (Exception e)
        {
            // TODO: replace with dummy glyph
            writeln("error: ", e);
        }
    }

    /* private bool isSelected()
    {
        return false;
    } */
}

class TextLineSublineViewState
{
    TextChar[] textchars;
    ulong width;
    ulong height;
}

// NOTE: this is needed, because each subline can have it's own perpendicular size
struct TextLineSubline
{
    TextLine parent_line;

    mixin getState!("text_view.text_line_subline_states", TextLineSublineViewState,);

    void recalculateWidthAndHeight(TextView text_view)
    {

        auto state = getState(text_view);

        state.width = 0;
        state.height = 0;

        foreach (u; state.textchars)
        {
            state.width += u.width;

            {
                auto h = u.height;
                if (h > state.height)
                    state.height = h;
            }
        }
    }

    Image genImage(
        ulong x, ulong y, ulong width, ulong height,
        TextView text_view
        )
    {

        auto state = getState(text_view);

        Image ret = genImageFromSubimages(
            state.width, state.height,

            x, y,
            width, height,

            parent_line.parent_text.chars_layout,

            delegate ulong()
            {
                return state.textchars.length;
            },

            delegate ulong(ulong subimage_index)
            {
                return state.textchars[subimage_index].width;
            },

            delegate ulong(ulong subimage_index)
            {
                return state.textchars[subimage_index].height;
            },

            delegate Image(
                ulong subimage_index,
                ulong x, ulong y,
                ulong width, ulong height
                )
            {
                return state.textchars[subimage_index].glyph.bitmap.getImage(
                    x, y,
                    width, height
                    );
            }
            );
        return ret;
    }
}

// NOTE: TextLine have it's own contextual status, because in text wrap mode
//       line size depends on context's size
class TextLineViewState
{
    TextLineSubline[] sublines;
    ulong width;
    ulong height;
}

class TextLine
{
    Text parent_text;

    TextChar[] textchars;

    this(Text parent)
    {
        this.parent_text = parent;
    }

    mixin getState!("text_view.text_line_states", TextLineViewState);

    void setText(dstring txt)
    {
        /* auto state = getState(); */

        textchars = textchars[0 .. 0];
        /* sublines = sublines[0 .. 0]; */

        foreach (c; txt)
        {
            if (c == cast(dchar) '\n')
            {
                throw new Exception(
                    "TextLine.setText() does not accepts strings with new lines"
                    );
            }
        }

        foreach (c; txt)
        {
            auto tu = new TextChar(this);
            tu.chr = c;
            textchars ~= tu;
        }
    }

    void reprocessUnits(TextView text_view)
    {
        foreach (u; textchars)
        {
            u.reprocess(text_view);
        }
    }

    void reprocessSublines(TextView text_view)
    {
        auto state = getState(text_view);

        state.sublines = state.sublines[0 .. 0];

        if (textchars.length != 0)
        {
            state.sublines ~= TextLineSubline();

            // TODO: comment this out?
            reprocessUnits(text_view);

            // TODO: optimization required
            ulong required_size;
            if (text_view.virtualwrap_allow_by_space
                    || text_view.virtualwrap_allow_by_char)
            {
                switch (parent_text.lines_layout)
                {
                default:
                    throw new Exception(
                        "parent_text.lines_layout ",
                        to!string(parent_text.lines_layout)
                        );
                case GenImageFromSubimagesLayout.horizontalLeftToRightAlignTop:
                case GenImageFromSubimagesLayout.horizontalRightToLeftAlignTop:
                    required_size = text_view.width;
                    break;
                case GenImageFromSubimagesLayout.verticalTopToBottomAlignLeft:
                case GenImageFromSubimagesLayout.verticalTopToBottomAlignRight:
                    required_size = text_view.height;
                    break;
                }

            }

            ulong current_line = 0;
            ulong current_size = 0;

            foreach (u; textchars)
            {
                ulong s;

                switch (parent_text.lines_layout)
                {
                default:
                    throw new Exception(
                        "parent_text.lines_layout ",
                        to!string(parent_text.lines_layout)
                        );
                case GenImageFromSubimagesLayout.horizontalLeftToRightAlignTop:
                case GenImageFromSubimagesLayout.horizontalRightToLeftAlignTop:
                    s = u.width;
                    break;
                case GenImageFromSubimagesLayout.verticalTopToBottomAlignLeft:
                case GenImageFromSubimagesLayout.verticalTopToBottomAlignRight:
                    s = u.height;
                    break;
                }

                if (s > required_size)
                {
                    // NOTE: not error
                    return;
                }

                if (required_size <= current_size + s)
                {
                    state.sublines ~= TextLineSubline();
                    current_size = s;
                }
                else
                {
                    current_size += s;
                }

                state.sublines[$ - 1].getState(text_view).textchars ~= u;
            }

        }

        recalculateWidthAndHeight(text_view);
    }

    void recalculateWidthAndHeight(TextView text_view)
    {
        auto state = getState(text_view);

        state.width = 0;
        state.height = 0;

        if (state.sublines.length != 0)
        {
            // TODO: add cases for different layouts

            foreach (sl; state.sublines)
            {
                sl.recalculateWidthAndHeight(text_view);
            }

            foreach (sl; state.sublines)
            {
                auto sl_state = sl.getState(text_view);
                {
                    auto w = sl_state.width;
                    if (w > state.width)
                        state.width = w;
                }

                state.height += sl_state.height;
            }
        }
    }

    dstring getText()
    {
        dstring ret;
        foreach (u; textchars)
        {
            ret ~= u.chr;
        }
        return ret;
    }

    dstring getText(ulong start, ulong stop)
    {
        dstring ret;

        for (ulong i = start; i != stop; i++)
        {
            ret ~= textchars[i].chr;
        }

        return ret;
    }

    /* Image genImage()
    {
        return genImage(0,0,width,height);
    } */

    Image genImage(ulong x, ulong y, ulong width, ulong height,

            TextView text_view)
    {

        auto state = getState(text_view);

        Image ret = genImageFromSubimages(
            state.width, state.height,

            x, y,
            width, height,

            parent_text.lines_layout,

            delegate ulong()
            {
                return textchars.length;
            },

            delegate ulong(ulong subimage_index)
            {
                return textchars[subimage_index].width;
            },

            delegate ulong(ulong subimage_index)
            {
                return textchars[subimage_index].height;
            },
            delegate Image(
                ulong subimage_index,
                ulong x, ulong y,
                ulong width, ulong height
                )
            {
                return textchars[subimage_index].glyph.bitmap.getImage(
                    x, y,
                    width, height
                    );
            }
            );
        return ret;
    }


}

enum TextMarkup
{
    none,
    plain = none,

    asciidocPlain,
    bbcodePlain,
    markdownPlain,
    markdownExtraPlain,
    podPlain,
}

class TextViewState
{
    ulong width;
    ulong height;
}

class Text
{
    TextMarkup markup;

    GenImageFromSubimagesLayout lines_layout;
    GenImageFromSubimagesLayout chars_layout;

    string faceFamily;
    uint faceSize;
    uint faceResolution;

    bool bold;
    bool italic;
    bool underline;

    bool defaultFGColorEnabled;
    Color defaultFGColor;

    bool defaultBGColorEnabled;
    Color defaultBGColor;

    TextLine[] lines;

    this()
    {

    }

    mixin getState!("text_view.text_states", TextViewState,);

    void setText(dstring txt)
    {
        lines = lines[0 .. 0];

        writeln("setText entering parsing loop");

        auto line_ended = false;

        while (!line_ended)
        {
            dstring line;

            auto txt_len = txt.length;

            foreach (i, c; txt)
            {
                writef("%d ", i);
                if (c == '\n')
                {
                    writeln(r"c == '\n'");
                    if (txt[i + 1] == '\r')
                    {
                        i++;
                    }
                    line = txt[0 .. i];
                    txt = txt[i .. $];

                    if (line[$ - 1] == '\r')
                    {
                        line = line[0 .. $ - 1];
                    }
                    break;
                }

                if (i == txt_len - 1)
                {
                    line = txt;
                    line_ended = true;
                    break;
                }
            }

            auto tl = new TextLine(this);
            tl.setText(line);
            lines ~= tl;
        }
    }

    void reprocess(TextView text_view)
    {
        reprocessUnits(text_view);
        reprocessSublines(text_view);
        /* reprocessLines(text_view); */
    }

    void reprocessUnits(TextView text_view)
    {
        foreach (l; lines)
        {
            l.reprocessUnits(text_view);
        }
    }

    void reprocessSublines(TextView text_view)
    {
        foreach (l; lines)
        {
            l.reprocessSublines(text_view);
        }
    }

    /* void reprocessLines(TextView text_view)
    {

    } */

    dstring getText()
    {
        writeln("dstring getText() ", this, " ", lines.length);
        dstring ret;

        if (lines.length == 0)
        {
            return ret;
        }

        ret = lines[0].getText();

        if (lines.length == 1)
        {
            return ret;
        }

        foreach (l; lines[1 .. $])
        {
            ret ~= "\n" ~ l.getText();
        }

        return ret;
    }

    dstring getText(ulong start, ulong stop)
    {
        bool first_found = false;
        ulong first_text_textchar;
        ulong first_text_textchar_index;

        bool last_found = false;
        ulong last_text_textchar;
        ulong last_text_textchar_index;

        bool searching_first = true;

        /* ulong prev_length = 0; */
        ulong calc_length = 0;

        {
            if (start > stop)
                throw new Exception("start is behind stop");
            auto l = getLength();
            if (start > l)
                throw new Exception("start is behind text length");
            if (stop > l)
                throw new Exception("stop is behind text length");
        }

        foreach (i, l; lines)
        {
            auto l_l = l.textchars.length;
            if (i < lines.length)
                l_l += 1; // add new line

            if (start < calc_length + l_l)
            {
                first_found = true;
                first_text_textchar = i;
                first_text_textchar_index = start - calc_length;
            }

            if (stop < calc_length + l_l)
            {
                last_found = true;
                last_text_textchar = i;
                last_text_textchar_index = stop - calc_length;
            }

            if (first_found && last_found)
                break;

            calc_length += l_l;
        }

        if (first_text_textchar == last_text_textchar)
        {
            return lines[first_text_textchar].getText(first_text_textchar_index,
                    last_text_textchar_index + 1);
        }

        dstring ret;

        ret ~= lines[first_text_textchar].getText(first_text_textchar_index,
                lines[first_text_textchar].textchars.length);

        if (last_text_textchar - first_text_textchar > 1)
        {
            for (ulong i = first_text_textchar + 1; i < last_text_textchar; i++)
            {
                ret ~= "\n" ~ lines[i].getText();
            }
        }

        ret ~= "\n" ~ lines[last_text_textchar].getText(0, last_text_textchar_index);

        return ret;
    }

    Image genImage(
        ulong x, ulong y,
        ulong width, ulong height,
        TextView text_view
        )
    {

        auto state = getState(text_view);

        Image ret = genImageFromSubimages(
            state.width, state.height,

            x, y,
            width, height,

            lines_layout,

            delegate ulong()
            {
                return lines.length;
            },
            delegate ulong(ulong subimage_index)
            {
                return lines[subimage_index].getState(text_view).width;
            },
            delegate ulong(ulong subimage_index)
            {
                return lines[subimage_index].getState(text_view).height;
            },
            delegate Image(
                ulong subimage_index,
                ulong x, ulong y,
                ulong width, ulong height
                )
            {
                return lines[subimage_index].genImage(
                    x, y,
                    width, height,
                    text_view
                    );
            }
            );
        return ret;
    }

    ulong getLength()
    {
        ulong ret;
        foreach (i, l; lines)
        {
            ret += l.textchars.length;
        }
        ret += lines.length - 1; // new line symbol count
        return ret;
    }
}

enum Mode
{
    singleLine,
    multiLine,
    codeEditor,
}

class TextView
{
    ulong x;
    ulong y;

    ulong width;
    ulong height;

    ulong text_selected;
    ulong selection_start;
    ulong selection_end;

    ulong cursor_position_line;
    ulong cursor_position_column;

    Mode mode;

    bool virtualwrap_allow_by_space;
    bool virtualwrap_allow_by_char;

    Text text;

    FontMgrI font_mgr;

    TextLineSublineViewState[TextLineSubline] text_line_subline_states;
    TextLineViewState[TextLine] text_line_states;
    TextViewState[Text] text_states;

    this()
    {
        setTextString("");
    }

    this(dstring txt)
    {
        setTextString(txt);
    }

    this(Text txt)
    {
        setText(txt);
    }

    void setTextString(dstring txt = "")
    {
        if (text is null)
        {
            text = new Text();
        }

        text.setText(txt);
    }

    dstring getTextString()
    {
        dstring ret;

        if (text !is null)
        {
            ret = text.getText();
        }

        return ret;
    }

    void setText(dstring txt)
    {
        setTextString(txt);
    }

    void setText(Text txt)
    {
        text = txt;
    }

    Text getText()
    {
        if (text is null)
            setTextString();
        return text;
    }

    Image genImage()
    {
        if (text is null)
            throw new Exception("text object is not set");

        auto ret = text.genImage(x, y, width, height, this);

        return ret;
    }

    void reprocess()
    {
        getText().reprocess(this);
    }

}

mixin template getState(string state_container, alias state_type)
{
    mixin(q{
            state_type getState(TextView text_view)
            {
                state_type state;

                if (this !in %1$s) {
                    state = new state_type();
                    %1$s[this] = state;
                } else {
                    state = %1$s[this];
                }

                return state;
            }
        }.format(state_container)
        );

}
