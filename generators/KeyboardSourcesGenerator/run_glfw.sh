#!/bin/bash

./generate_glfw_keyconversion.d
dfmt keyconversion.d > keyconversion.d2
mv keyconversion.d2 keyconversion.d
