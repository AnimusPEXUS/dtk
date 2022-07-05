#!/bin/bash

./generate_sdl_keyconversion.d
dfmt keyconversion.d > keyconversion.d2
mv keyconversion.d2 keyconversion.d
