module dtk.types.Image;

import std.stdio;
import std.typecons;
import std.math;


import dtk.interfaces.DrawingSurfaceI;

import dtk.types.Color;
import dtk.types.Position2D;
import dtk.types.Size2D;
import dtk.types.LineStyle;
import dtk.types.FillStyle;


struct ImageDot
{
    bool enabled;
    real intensivity;
    Color color;

    invariant
    {
        assert(intensivity >= 0 && intensivity <= 1);
    }
}

class Image : DrawingSurfaceI // TODO: enable DrawingSurfaceI
{
    ulong width;
    ulong height;
    ImageDot[] data;

    bool baseColorEnabled;
    Color baseColor;

    this(ulong width, ulong height)
    {
    	assert(width < 10000, "image width suspitiously big");
        this.width = width;
        this.height = height;
        this.data = new ImageDot[](width * height);
    }

    typeof(this) setEach(ImageDot new_value)
    {
        for (uint i = 0; i != data.length; i++)
        {
            data[i] = new_value;
        }
        return this;
    }

    typeof(this) setDot(ulong x, ulong y, ImageDot new_value)
    {
        if (x > width)
            /* throw new Exception("invalid x"); */
            return this;
        if (y > height)
            /* throw new Exception("invalid y"); */
            return this;
        auto z = y * width + x;
        if (z < 0 || z >= this.data.length)
            return this;
        this.data[z] = new_value;
        return this;
    }

    ImageDot getDot(ulong x, ulong y)
    {
    	import std.format;
    	// debug writeln(
    	// q{
    	// width:  %d
    	// height: %d
    	// x:      %d
    	// y:      %d
    	// }.format(width, height, x, y)
    	// );
        return this.data[y * width + x];
    }

    ref ImageDot getDotRef(ulong x, ulong y)
    {
        return this.data[y * width + x];
    }

    void resize(ulong width, ulong height)
    {
        auto new_data = new ImageDot[](width * height);

        auto this_width = this.width;
        auto this_height = this.height;

        ulong copy_width = (this_width > width ? width : this_width);
        ulong copy_height = (this_height > height ? height : this_height);

        for (ulong y = 0; y != copy_height; y++)
        {
            for (ulong x = 0; x != copy_width; x++)
            {
                new_data[y * width + x] = this.data[y * this_width + x];
            }
        }

        this.data = new_data;
        this.width = width;
        this.height = height;
    }

    void putImage(ulong x, ulong y, Image new_image)
    {
        if (x > width)
            return;
        if (y > height)
            return;

        ulong horizontal_copy_count = new_image.width;
        ulong vertical_copy_count = new_image.height;

        if ((x + horizontal_copy_count) > width)
            horizontal_copy_count -= width - x;

        if ((y + vertical_copy_count) > height)
            vertical_copy_count -= height - y;

        for (ulong y2 = 0; y2 != vertical_copy_count; y2++)
        {
            for (ulong x2 = 0; x2 != horizontal_copy_count; x2++)
            {
                auto dot = new_image.getDot(x2, y2);
                setDot(x + x2, y + y2, dot);
            }
        }
    }

    Image getImage(ulong x, ulong y, ulong width, ulong height)
    {
        Image ret = new Image(width, height);

        if (x > this.width || y > this.height)
            return ret;

        ulong actual_width = (x + width > this.width ? this.width - x : width);
        ulong actual_height = (y + height > this.height ? this.height - y : height);

        for (ulong x2 = 0; x2 != actual_width; x2++)
        {
            for (ulong y2 = 0; y2 != actual_height; y2++)
            {
                auto dot = getDot(x + x2, y + y2);
                ret.setDot(x2, y2, dot);
            }
        }

        return ret;
    }

    void printImage()
    {
        for (ulong y = 0; y != height; y++)
        {
            for (ulong x = 0; x != width; x++)
            {
                if (getDot(x, y).intensivity == 0)
                {
                    write(" ");
                }
                else
                {
                    write("*");
                }
            }
            writeln();
        }
        writeln();
    }

    // ------------------ DrawingSurface

    void drawDot(Position2D pos, ImageDot dot)
    {
        setDot(pos.x, pos.y, dot);
    }

    bool canGetDot()
    {
        return true;
    }

    ImageDot getDot(Position2D pos)
    {
        return getDot(pos.x, pos.y);
    }

    void drawLine(Position2D pos, Position2D pos2, LineStyle style)
    {
        try { throw new Exception("todo") ;} catch (Exception e) {debug writeln(e);}
    }

    void drawRectangle(
        Position2D pos,
        Size2D size,
        LineStyle top_style,
        LineStyle left_style,
        LineStyle bottom_style,
        LineStyle right_style,
        Nullable!(FillStyle) fill_style
        )
    {
        try { throw new Exception("todo") ;} catch (Exception e) {debug writeln(e);}
    }

    void drawArc(
        Position2D pos,
        uint radius,
        real start_angle,
        real stop_angle,
        real turn_step,
        Color color)
    {
        try { throw new Exception("todo") ;} catch (Exception e) {debug writeln(e);}
    }

    void drawCircle(Position2D pos, uint radius, real turn_step, Color color)
    {
        try { throw new Exception("todo") ;} catch (Exception e) {debug writeln(e);}
    }

    void drawImage(Position2D pos, Image image)
    {
        putImage(pos.x, pos.y, image);
    }

    bool canGetImage()
    {
        return true;
    }

    Image getImage(Position2D pos, Size2D size)
    {
        return getImage(pos.x, pos.y, size.width, size.height);
    }

    bool canPresent()
    {
        return false;
    }

    void present()
    {
        throw new Exception("present() not supported");
    }

}

Position2D[] calculateDotsInLine(Position2D pos, Position2D pos2)
{

    int calc_y(int x_high, int x_low, int y_high, int y_low, int x)
    {
        auto x_razn = x_high - x_high;
        auto a = x_high - x;
        auto b = x_razn - a;
        auto c = (b != 0 ? x_razn / b : 0);
        auto d = y_high - y_low;
        auto e = (c != 0 ? d / c : 0);
        auto f = d - e;
        auto y = cast(int) lround(y_high - f);
        return y;
    }

    Position2D[] ret;
    bool is_x = ((pos2.x - pos.x) > (pos2.y - pos.y));
    if (is_x)
    {
        for (int x = pos.x; x != pos2.x + 1; x++)
        {
            auto y = calc_y(pos2.x, pos.x, pos2.y, pos.y, x);
            ret ~= Position2D(x, y);
        }
    }
    else
    {
        for (int y = pos.y; y != pos2.y + 1; y++)
        {
            auto x = calc_y(pos2.y, pos.y, pos2.x, pos.x, y);
            ret ~= Position2D(x, y);
        }
    }
    return ret;
}
