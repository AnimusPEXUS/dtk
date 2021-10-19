module dtk.miscs.TextProcessor;

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

Image genImageFromSubimages(
    ulong max_width,
    ulong max_height,

    ulong x, ulong y,
    ulong width, ulong height,

    GenImageFromSubimagesLayout layout,

    ulong delegate () getSubimageCount,
    ulong delegate (ulong subimage_index) getSubimageWidth,
    ulong delegate (ulong subimage_index) getSubimageHeight,
    Image delegate (
        ulong subimage_index,
        ulong x, ulong y,
        ulong width, ulong height,
        ) getSubimage,
    )
    {
        Image ret = new Image(width, height);

        if (x > width || y > height)
            return ret;

        auto actual_width = (x + width > max_width ? max_width - x : width);
        auto actual_height = (y + height > max_height ? max_height - y : height);

        auto x2 = x+width;
        auto y2 = y+height;

        ulong first_visible_item;
        bool first_visible_item_found;
        ulong first_visible_item_offset;

        ulong last_visible_item;
        bool last_visible_item_found;
        ulong last_visible_item_offset;

        {
            ulong processed_size;

            ulong count = getSubimageCount();

            {
                ulong z;
                ulong z2;

                ulong current_size;

                switch (layout){
                    default:
                        throw new Exception("unknown layout");
                    case horizontalLeftToRightAlignTop:
                        z = x;
                        z2 = x2;
                        break;
                    case verticalTopToBottomAlignLeft:
                        z = y;
                        z2 = y2;
                        break;
                }

                for ( ulong i = 0; i != count ; i++)
                {

                    switch (layout){
                        default:
                            throw new Exception("unknown layout");
                        case horizontalLeftToRightAlignTop:
                            current_size = getSubimageWidth(i)
                            break;
                        case verticalTopToBottomAlignLeft:
                            current_size = getSubimageHeight(i)
                            break;
                    }

                    if (!first_visible_item_found && z>=processed_size && z< processed_size+current_size) {
                        first_visible_item = i;
                        first_visible_item_found = true;
                        first_visible_item_offset = z - processed_size;
                    }

                    if (!last_visible_item_found && z2>=processed_size && z2 < processed_size+current_size) {
                        last_visible_item = i;
                        last_visible_item_found = true;
                        last_visible_item_offset = processed_size+current_size-z2
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
            last_visible_item = count-1;
        }

        {
            ulong items_count = last_visible_item-first_visible_item;

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
                case horizontalLeftToRightAlignTop:
                    calc_loop_target_x = delegate ulong(ulong i) {
                        if (i == 0)
                            return 0;
                        ulong width;
                        for (ulong i = 0; i <= i; i++)
                        {
                            width += getSubimageWidth(first_visible_item+i);
                        }
                        return width-first_visible_item_offset;
                    };

                    calc_loop_target_y= delegate ulong(ulong i) {
                        return 0;
                    };

                    calc_loop_source_x = delegate ulong(ulong i) {
                        if (i == 0)
                            return first_visible_item_offset;
                        return 0;
                    };

                    calc_loop_source_y = delegate ulong(ulong i) {
                        return 0;
                    };

                    calc_loop_source_width = delegate ulong(ulong i) {
                        if (i == 0)
                            return getSubimageWidth(first_visible_item+i) - first_visible_item_offset;
                        return 0;
                    };

                    calc_loop_source_height = delegate ulong(ulong i) {
                        return getSubimageHeight(first_visible_item+i);
                    };
                    break;
                case verticalTopToBottomAlignLeft:
                    calc_loop_target_x = delegate ulong(ulong i) {
                        return 0;
                    };

                    calc_loop_target_y= delegate ulong(ulong i) {
                        if (i == 0)
                            return 0;
                        ulong height;
                        for (ulong i = 0; i <= i; i++)
                        {
                            height += getSubimageHeight(first_visible_item+i);
                        }
                        return height-first_visible_item_offset;
                    };

                    calc_loop_source_x = delegate ulong(ulong i) {
                        return 0;
                    };

                    calc_loop_source_y = delegate ulong(ulong i) {
                        if (i == 0)
                            return first_visible_item_offset;
                        return 0;
                    };

                    calc_loop_source_width = delegate ulong(ulong i) {
                        return getSubimageWidth(first_visible_item+i);
                    };

                    calc_loop_source_height = delegate ulong(ulong i) {
                        if (i == 0)
                            return getSubimageHeight(first_visible_item+i) - first_visible_item_offset;
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
                        calc_loop_source_x(i),
                        calc_loop_source_y(i),
                        calc_loop_source_width(i),
                        calc_loop_source_height(i)
                        )
                    );
                processed_size += calc_loop_processed_size_advance(i);
            }
        }

        return ret;
    }

class TextUnit
{
    TextLine parent_line;

    dchar chr;

    ulong width;
    ulong height;

    GlyphRenderResult *glyph;

    this(TextLine parent_line)
    {
        this.parent_line = parent_line;
    }

    void rerender(TextProcessorContext processor_context)
    {
        loadGlyph(processor_context);
    }

    void loadGlyph(TextProcessorContext processor_context)
    {
        writeln("rendering char: ", chr);

        auto font_mgr = processor_context.font_mgr;
        auto face = font_mgr.loadFace("/usr/share/fonts/go/Go-Regular.ttf");

        {
            auto x = processor_context.defaultFaceSize;
            face.setCharSize(x,x);
        }
        {
            auto x = processor_context.defaultFaceResolution;
            face.setCharResolution(x,x);
        }

        try
        {
            glyph = face.renderGlyphByChar(chr);
            width = glyph.bitmap.width;
            height = glyph.bitmap.height;
        }
        catch(Exception e)
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

class ContextTextLineSublineState
{
    TextUnit[] units;
    ulong width;
    ulong height;
}


// NOTE: this is needed, because each subline can have it's own perpendicular size
struct TextLineSubline
{
    TextLine parent_line;

    void recalculateWidthAndHeight(TextProcessorContext processor_context)
    {
        width = 0;
        height = 0;

        foreach (u; units)
        {
            width += u.getWidth();

            {
                auto h = u.getHeight();
                if (h > height)
                    height = h;
            }
        }
    }

    Image genImage()
    {
        return genImage(0,0,width,height);
    }

    Image genImage(
        ulong x, ulong y,
        ulong width, ulong height
        )
    {
        Image ret = genImageFromSubimages(
            this.width,
            this.height,

            x,y,
            width,height,

            parent_line.parent_text.chars_layout,

            delegate ulong()
                {
                    return units.length;
                },
            delegate Size2D  (ulong subimage_index)
                {
                    return units[subimage_index].width;
                },
            delegate Size2D  (ulong subimage_index)
                {
                    return units[subimage_index].height;
                },
            delegate Image(
                ulong subimage_index,
                ulong x, ulong y,
                ulong width, ulong height,
                )
                {
                    return units[subimage_index].genImage(
                    x,y,
                    width, height,
                    );
                },
            );
        return ret;
    }
}

// NOTE: TextLine have it's own contextual status, because in text wrap mode
//       line size depends on context's size
class ContextTextLineState
{
    TextLineSubline[] sublines;
    ulong width;
    ulong height;
}

class TextLine
{
    Text parent_text;

    TextUnit[] units;

    this(Text parent)
    {
        this.parent_text=parent;
    }

    void setText(dstring txt)
    {
        units = units[0 .. 0];
        sublines = sublines[0 .. 0];

        foreach(c;txt)
        {
            if (c == cast(dchar)'\n')
            {
                throw new Exception("TextLine.setText() does not accepts strings with new lines");
            }
        }

        foreach(c;txt)
        {
            auto tu = new TextUnit(this);
            tu.setChar(c);
            units ~= tu;
        }
    }

    void reprocessUnits(TextProcessorContext processor_context)
    {
        foreach (u;units)
        {
            u.reporcess(processor_context);
        }
    }

    void reprocessSublines(TextProcessorContext processor_context)
    {
        foreach (l;lines)
        {
            l.reprocessSublines();
        }
    }


    void rerenderUnits(TextProcessorContext processor_context)
    {
        foreach (u;units)
        {
            l.rerender(TextProcessorContext processor_context);
        }
    }

    void recalculateSublines(TextProcessorContext processor_context)
    {
        sublines = sublines[0 .. 0];

        if (units.length != 0)
        {
            sublines ~= TextLineSubline();

            foreach (u;units)
            {
                u.reprocess();
            }

            // TODO: optimization required
            auto required_size = required_length();

            ulong current_line = 0;
            ulong current_width = 0;

            foreach(u;units)
            {
                auto s = u.width;

                if (s > required_size)
                {
                    // NOTE: not error
                    return;
                }

                if (required_size <= current_width + s)
                {
                    sublines ~= TextLineSubline();
                    current_width = s;
                } else {
                    current_width+=s;
                }

                sublines[$-1].units ~= u;
            }

        }

        recalculateWidthAndHeight(processor_context);
    }

    void recalculateWidthAndHeight(TextProcessorContext processor_context)
    {
        width = 0;
        height = 0;

        if (sublines.length != 0)
        {
            foreach (sl;sublines)
            {
                sl.recalculateWidthAndHeight();
            }

            foreach (sl; sublines)
            {
                {
                    auto w = sl.getWidth();
                    if (w > width)
                        width = w;
                }

                height += sl.getHeight();
            }
        }
    }


    dstring getText()
    {
        dstring ret;
        foreach(u;units)
        {
            ret ~= u.getChar();
        }
        return ret;
    }

    dstring getText(ulong start, ulong stop)
    {
        dstring ret;

        for (ulong i = start; i != stop; i++)
        {
            ret ~= units[i].getChar();
        }

        return ret;
    }

    Image genImage()
    {
        return genImage(0,0,width,height);
    }

    Image genImage(
        ulong x, ulong y,
        ulong width, ulong height,

        TextProcessorContext processor_context
        )
    {
        ContextTextLineState state;
        if (this !in processor_context.text_line_state) {
            state = new ContextTextLineState();
            processor_context.text_line_state ~= state;
        }

        Image ret = genImageFromSubimages(
            this.width,
            this.height,

            x,y,
            width,height,

            parent_line.parent_text.lines_layout,

            delegate ulong()
                {
                    return units.length;
                },
            delegate Size2D  (ulong subimage_index)
                {
                    return units[subimage_index].width;
                },
            delegate Size2D  (ulong subimage_index)
                {
                    return units[subimage_index].height;
                },
            delegate Image(
                ulong subimage_index,
                ulong x, ulong y,
                ulong width, ulong height,
                )
                {
                    return units[subimage_index].genImage(
                    x,y,
                    width, height,
                    );
                },
            );
        return ret;
    }

    ulong getWidth()
    {
        return width;
    }

    ulong getHeight()
    {
        return height;
    }

    ulong getLength()
    {
        return units.length;
    }
    // implement more handy methods

}

enum Mode
{
    singleLine,
    multiLine,
    codeEditor,
}

/* enum OnLineOverflow
{
    cutoff,
    wrapByWord,
    wrapByChar,
} */

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


class Text
{
    TextMarkup markup;

    Mode mode;

    bool wrap_allow_by_space;
    bool wrap_allow_by_char;

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

    FontMgrI font_mgr;

    TextLine[] lines;

    this()
    {

    }

    void setText(dstring txt)
    {
        lines = lines[0 .. 0];

        writeln("setText entering parsing loop");

        auto line_ended = false;

        while (!line_ended){
            dstring line;

            auto txt_len = txt.length;

            foreach (i, c;txt)
            {
                writef("%d ",i);
                if (c == '\n')
                {
                    writeln(r"c == '\n'");
                    if (txt[i+1] == '\r')
                    {
                        i++;
                    }
                    line = txt[0 .. i];
                    txt = txt[i .. $];

                    if (line[$-1] == '\r')
                    {
                        line = line[0 .. $-1];
                    }
                    break;
                }

                if (i == txt_len-1)
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

    void reprocess(TextProcessorContext processor_context)
    {
        reprocessUnits(processor_context);
        reprocessSublines(processor_context);
        reprocessLines(processor_context);
    }

    void reprocessUnits(TextProcessorContext processor_context)
    {
        foreach (l;lines)
        {
            l.reprocessUnits();
        }
    }

    void reprocessSublines(TextProcessorContext processor_context)
    {
        foreach (l;lines)
        {
            l.reprocessSublines();
        }
    }

    void reprocessLines(TextProcessorContext processor_context)
    {

    }

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

        foreach (l;lines[1 .. $])
        {
            ret ~= "\n" ~ l.getText();
        }

        return ret;
    }

    dstring getText(ulong start, ulong stop)
    {
        bool first_found = false;
        ulong first_text_unit;
        ulong first_text_unit_unit_index;

        bool last_found = false;
        ulong last_text_unit;
        ulong last_text_unit_unit_index;

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


        foreach (i, l;lines)
        {
            auto l_l = l.getLength();
            if (i < lines.length)
                l_l += 1; // add new line

            if (start < calc_length + l_l)
            {
                first_found = true;
                first_text_unit = i;
                first_text_unit_unit_index = start - calc_length;
            }

            if (stop < calc_length + l_l)
            {
                last_found = true;
                last_text_unit = i;
                last_text_unit_unit_index = stop - calc_length;
            }

            if (first_found && last_found)
                break;

            calc_length += l_l;
        }

        if (first_text_unit == last_text_unit)
        {
            return lines[first_text_unit].getText(first_text_unit_unit_index, last_text_unit_unit_index+1);
        }

        dstring ret;

        ret ~= lines[first_text_unit].getText(first_text_unit_unit_index, lines[first_text_unit].getLength());

        if (last_text_unit - first_text_unit > 1)
        {
            for (ulong i = first_text_unit+1; i < last_text_unit; i++)
            {
                ret ~= "\n" ~ lines[i].getText();
            }
        }

        ret ~= "\n" ~ lines[last_text_unit].getText(0, last_text_unit_unit_index);

        return ret;
    }

    Image genImage()
    {
        ulong width;
        ulong height;

        foreach (l;lines)
        {
            auto w = l.getWidth();
            auto h = l.getHeight();

            if (w > width)
            {
                width = w;
            }

            height += h;
        }

        Image ret = new Image(width, height);

        {
            ulong current_line_height=0;

            foreach (l;lines)
            {
                auto img = l.genImage();
                ret.putImage(0UL, current_line_height, img);
                current_line_height += img.height;
            }
        }

        return ret;
    }

    ulong getLength()
    {
        ulong ret;
        foreach(i,l;lines)
        {
            ret += l.getLength();
        }
        ret += lines.length - 1; // new line symbol count
        return ret;
    }
}


class TextProcessorContext
{
    ulong x;
    ulong y;

    // if text wraping, width is used to wrap. else width or height is used for
    // scroll, depending on text direction settings
    ulong width;
    ulong height;

    ulong text_selected;
    ulong selection_start;
    ulong selection_end;

    ulong cursor_position_line;
    ulong cursor_position_column;

    Text text;

    (TextSubline[])[TextLine] sublines_memory;

    ContextTextLineSublineState[TextLineSubline] text_line_subline_state;
    ContextTextLineState[TextLine] text_line_state;
}
