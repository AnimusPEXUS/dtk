module dtk.miscs.isPointInRegion;

import dtk.types.Position2D;
import dtk.types.Size2D;

bool isPointInRegion(Position2D pos, Size2D size, Position2D point)
{
    bool ret;

    int px;
    int py;

    int rx;
    int ry;
    int rw;
    int rh;

    px = point.x;
    py = point.y;

    rx = pos.x;
    ry = pos.y;
    rw = size.width;
    rh = size.height;

    auto rx_p_rw = rx+rw;
    auto ry_p_rh = ry+rh;

    ret = (
        px >= rx
        && px < rx_p_rw
        && py >= ry
        && py < ry_p_rh
        );

    return ret;
}
