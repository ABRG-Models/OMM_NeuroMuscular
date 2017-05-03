/*
 * A program to demonstrate the mapping between the eyeframe and the
 * retinotopic map used throughout the oculomotor model.
 */

#include "luminance.h"
#include "worldframe.h"
#include "eyeframe.h"
#include <vector>
#include <iostream>
#include <fstream>

#include "common.h"
#include "debug.h"

#include <json/json.h>

using namespace wdm;
using namespace std;

std::ofstream DBGSTREAM;

#define DO_EYEFRAME 1
//#define PRECLEAN 1

// Play with these rotations to see how the mapping works
#define ROTX 0
#define ROTY 0
#define ROTZ 0

#define NUM_LUMS_PER_SPOKE 3
#define NUM_DEGREES_PER_STEP 9

#define RECT_WIDTH 4
#define LUM_VALUE 1

#define ORIGIN_RECT_WIDTH 4
#define ORIGIN_LUM_VALUE 1.5

int main()
{
    // I'll define the luminances in the world frame, and then I'll
    // transfer them to the eyeframe, but with the eye always looking
    // directly ahead, such that the world frame and the eye frame
    // have no offset between them.
    WorldFrame wf;

    // NB: Something odd happens when you try to set blurmode to false.
    //wf.setBlurMode(false);

    // Straight ahead: thetax=0, thetay=0.
    // Luminance (thetax, thetay, widthThX, widthThY, luminosity, time_on, time_off)
    Luminance lum_origin (0, 0, ORIGIN_RECT_WIDTH, ORIGIN_RECT_WIDTH, ORIGIN_LUM_VALUE, 0.0, 1);
    wf.luminanceSeries.push_back (lum_origin);

    EyeFrame ef;
    ef.setDistanceToScreen (wf.distanceToScreen);
    ef.setOffset (ROTX, ROTY, ROTZ);
    ef.setEyeField (wf.luminanceCoords);

    // Save just the eyeframe map in cartesian coords and the corresponding cortical sheet.
    ef.saveLuminanceMap ("eyeframe_origin.dat");
    ef.saveCorticalSheet ("corticalmap_origin.dat");

    // Right
    // Now create a luminance which is right of centre but on the
    // horizon. This is obtained by rotating about Y in a negative
    // dirn. Note the fairly large size of the luminances to ensure we
    // illuminate some of the widely spaced neurons towards the
    // periphery of the retina.
    for (int i=1; i<=NUM_LUMS_PER_SPOKE; ++i) {
        Luminance lum (0, (-NUM_DEGREES_PER_STEP*i), RECT_WIDTH, RECT_WIDTH, LUM_VALUE, 0.051, 0.06);
        wf.luminanceSeries.push_back (lum);
    }
    wf.setLuminanceThetaMap (0.052); // Set up the map for time=0.01s.
    wf.saveLuminanceCoords ("worldframe_coords_right.dat");

#ifdef DO_EYEFRAME
    ef.setEyeField (wf.luminanceCoords);
    ef.saveLuminanceMap ("eyeframe_right.dat");
    ef.saveCorticalSheet ("corticalmap_right.dat");
    ef.saveNeuronPrecise ("eyeframe_neurons.dat"); // Only need do this once; it's same for left, up & down.
    ef.saveNeuronPixels ("eyeframe_neurons_pixel.dat");
#endif

    // Left
#ifdef PRECLEAN
    wf.init(BACKGROUND_LUMINANCE);
    wf.luminanceSeries.push_back (lum_origin);
#endif
    for (int i=1; i<=NUM_LUMS_PER_SPOKE; ++i) {
        Luminance lum (0, (NUM_DEGREES_PER_STEP*i), RECT_WIDTH, RECT_WIDTH, LUM_VALUE, 0.061, 0.07);
        wf.luminanceSeries.push_back (lum);
    }
    wf.setLuminanceThetaMap (0.062);
#ifdef DO_EYEFRAME
    ef.setEyeField (wf.luminanceCoords);
    ef.saveLuminanceMap ("eyeframe_left.dat");
    ef.saveCorticalSheet ("corticalmap_left.dat");
#endif

    // Up
#ifdef PRECLEAN
    wf.init(BACKGROUND_LUMINANCE);
    wf.luminanceSeries.push_back (lum_origin);
#endif
    for (int i=1; i<=NUM_LUMS_PER_SPOKE; ++i) {
        Luminance lum ((NUM_DEGREES_PER_STEP*i), 0, RECT_WIDTH, RECT_WIDTH, LUM_VALUE, 0.071, 0.08);
        wf.luminanceSeries.push_back (lum);
    }
    wf.setLuminanceThetaMap (0.072);
#ifdef DO_EYEFRAME
    ef.setEyeField (wf.luminanceCoords);
    ef.saveLuminanceMap ("eyeframe_up.dat");
    ef.saveCorticalSheet ("corticalmap_up.dat");
#endif

    // Down
#ifdef PRECLEAN
    wf.init(BACKGROUND_LUMINANCE);
    wf.luminanceSeries.push_back (lum_origin);
#endif
    for (int i=1; i<=NUM_LUMS_PER_SPOKE; ++i) {
        Luminance lum ((-NUM_DEGREES_PER_STEP*i), 0, RECT_WIDTH, RECT_WIDTH, LUM_VALUE, 0.081, 0.09);
        wf.luminanceSeries.push_back (lum);
    }
    wf.setLuminanceThetaMap (0.082);
#ifdef DO_EYEFRAME
    ef.setEyeField (wf.luminanceCoords);
    ef.saveLuminanceMap ("eyeframe_down.dat");
    ef.saveCorticalSheet ("corticalmap_down.dat");
#endif

    return 0;
}
