module dtk.types.Image;

import std.stdio;

import dtk.interfaces.DrawingSurfaceI;

import dtk.types.Color;

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

class Image // : DrawingSurfaceI // TODO: enable DrawingSurfaceI
{
    ulong width;
    ulong height;
    ImageDot[] data;

    this(ulong width, ulong height)
    {
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
            throw new Exception("invalid x");
        if (y > height)
            throw new Exception("invalid y");
        this.data[y * width + x] = new_value;
        return this;
    }

    ImageDot getDot(ulong x, ulong y)
    {
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

}
