module dtk.interfaces.FontMgrI;

import std.typecons;

import dtk.interfaces.FaceI;

import dtk.types.fontinfo;

interface FontMgrI
{
    FaceInfo*[] getFaceInfoList();
    FaceI loadFace(FaceInfo* face_info);
    FaceI loadFace(string faceFamily, string faceStyle);
    FaceI loadFace(string filename, ulong index);
}
