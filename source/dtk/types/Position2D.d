module dtk.types.Position2D;

struct Position2D
{
    int x;
    int y;
    /* int z; */

    Position2D sub(Position2D pos)
    {
        return Position2D(x - pos.x, y - pos.y);
    }

    Position2D sub(int x, int y)
    {
        return Position2D(this.x - x, this.y - y);
    }

    Position2D add(Position2D pos)
    {
        return Position2D(x + pos.x, y + pos.y);
    }

    Position2D add(int x, int y)
    {
        return Position2D(this.x + x, this.y + y);
    }

}
