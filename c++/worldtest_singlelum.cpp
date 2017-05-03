/*
 * A program to demonstrate the mapping between the eyeframe and the
 * retinotopic map used throughout the oculomotor model.
 *
 * This one produces a single luminance, and I'm using it to review
 * debug messages.
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

// Play with these rotations to see how the mapping works
#define ROTX 0
#define ROTY 0
#define ROTZ 0

#define NUM_LUMS_PER_SPOKE 3
#define NUM_DEGREES_PER_STEP 9

#define RECT_WIDTH 1
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

    EyeFrame ef;
    ef.setDistanceToScreen (wf.distanceToScreen);
    ef.setOffset (ROTX, ROTY, ROTZ);

    // Single luminance ThetaX = 0; ThetaY = 10
    Luminance lum (0, 10, RECT_WIDTH, RECT_WIDTH, LUM_VALUE, 0, 1);
    wf.luminanceSeries.push_back (lum);

    wf.setLuminanceThetaMap (0.01); // Set up the map for time=0.01s.
    wf.saveLuminanceCoords ("worldframe_coords_single.dat");

    ef.setEyeField (wf.luminanceCoords);
    ef.saveLuminanceMap ("eyeframe_single.dat");
    ef.saveCorticalSheet ("corticalmap_single.dat");
    ef.saveNeuronPrecise ("eyeframe_neurons.dat");
    ef.saveNeuronPixels ("eyeframe_neurons_pixel.dat");

    return 0;
}
