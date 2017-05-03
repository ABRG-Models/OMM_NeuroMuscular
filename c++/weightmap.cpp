/*
 * A program to map a region of input for which weights will be set
 * for SC_deep to LLBN. Outside this range (i.e. for large
 * eccentricity saccades) the weights will be artificially attenuated,
 * due to the problems with intrinsic noise triggering saccades when
 * weights become large.
 */

#include "luminance.h"
#include "worldframe.h"
#include "eyeframe.h"
#include <vector>
#include <iostream>
#include <fstream>
#include <math.h>

#include "common.h"
#include "debug.h"

using namespace wdm;
using namespace std;

std::ofstream DBGSTREAM;

#define SEMICIRC_RAD 19
#define DOT_WIDTH 6
#define DOT_HEIGHT 2
#define DOT_LUM 0.5
int main()
{
    WorldFrame wf;

    // Set up the semi-circle of the region for which thetaY is
    // positive, up to 25 degrees:
    // thetaX^2 + thetaY^2 = 25^2 = 625; 0 <= thetaY <= 25
    int thetaXmax = 0;
    float fThetaXmax;
    for (int thetaY = 0; thetaY<=SEMICIRC_RAD; ++thetaY) {

        fThetaXmax = rint (sqrt (static_cast<float>(SEMICIRC_RAD*SEMICIRC_RAD - thetaY*thetaY)));

        // Positive quadrant
        thetaXmax = static_cast<int>(fThetaXmax);
        for (int thetaX = 0; thetaX <= thetaXmax; ++thetaX) {
            CrossLuminance lum (thetaX, thetaY, DOT_WIDTH, DOT_HEIGHT, DOT_LUM, 0.0, 0.05);
            wf.luminanceSeries.push_back (lum);
        }

        // Negative quadrant
        thetaXmax = thetaXmax * -1;
        for (int thetaX = -1; thetaX >= thetaXmax; --thetaX) {
            CrossLuminance lum (thetaX, thetaY, DOT_WIDTH, DOT_HEIGHT, DOT_LUM, 0.0, 0.05);
            wf.luminanceSeries.push_back (lum);
        }
    }

    wf.setLuminanceThetaMap (0.01); // Set up the map for time=0.01s.
    // Save maps/coords
    wf.saveLuminanceThetaMap();
    wf.saveLuminanceCoords();
    EyeFrame ef;
    ef.setDistanceToScreen (wf.distanceToScreen);
    ef.setOffset (0, 0, 0);
    ef.setEyeField (wf.luminanceCoords);
    // Save things which are visualised with show_data.m
    ef.saveLuminanceMap();
    ef.saveLuminanceCartesianCoords();
    ef.saveNeuronPixels();
    ef.saveNeuronPrecise();
    ef.saveCorticalSheet();

    return 0;
}
