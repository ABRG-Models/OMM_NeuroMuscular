/*
 * A tester for WorldFrame, EyeFrame etc.
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
    // Straight ahead: thetax=0, thetay=0.

    // A moving luminance - moves around in thetaY
    for (int i = 0; i<100; i++) {
        // Luminance (thetax, thetay, luminosity, time_on, time_off)
        Luminance l (0, i, 1, 10.0*i, 10.0*i+9.999);
        wf.luminanceSeries.push_back (l);
    }

    EyeFrame ef;
    ef.setDistanceToScreen (wf.distanceToScreen);
    ef.setOffset (0, 0, 0);

    for (unsigned int i = 0; i<100; i++) {

        wf.setLuminanceThetaMap (10.0*i); // Set up the map for time=0.01s.
        //stringstream wfss;
        //wfss << "worldframe" << i << ".dat";
        //wf.saveLuminanceThetaMap (wfss.str());

        ef.setEyeField (wf.luminanceCoords);

#if SAVE
        stringstream cmss;
        cmss << "cortmap" << i << ".dat";
        ef.saveCorticalSheet (cmss.str());
#endif
    }

    return 0;
}
