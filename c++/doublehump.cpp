/*
 * This one creates a double hump in cortical map from a single
 * luminance, but it's all down to numerical effects in the Euler
 * rotation and subsequent rounding of luminances into the eye frame's
 * "grid" of luminanceMap locations.
 *
 * View output using show_data.m
 */

#include "luminance.h"
#include "worldframe.h"
#include "eyeframe.h"
#include <vector>
#include <iostream>
#include <fstream>

#include "common.h"
#include "debug.h"

using namespace wdm;
using namespace std;

std::ofstream DBGSTREAM;

int main()
{
    WorldFrame wf;
    // Luminance (thetax, thetay, luminosity, time_on, time_off)
    Luminance l1 (0, 10, 1, 0.0, 0.05);
    wf.luminanceSeries.push_back (l1);
    wf.setLuminanceThetaMap (0.01); // Set up the map for time=0.01s.

    EyeFrame ef;
    ef.setDistanceToScreen (wf.distanceToScreen);
    ef.setOffset (0, 1.5, 0); // y rotn 1.5 causes the double hump
    ef.setEyeField (wf.luminanceCoords);

    return 0;
}
