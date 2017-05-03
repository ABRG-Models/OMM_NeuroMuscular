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
    // Luminance (thetax, thetay, widthThX, widthThY, luminosity, time_on, time_off)

    Luminance l0 (  0,   0,  2,   2, 1,  0.0, 0.01);
    Luminance l1 ( 10,   0,  2,   2, 1,  0.01, 0.05);
    Luminance l2 (-10,   0,  2,   2, 1,  0.05, 0.1);
    Luminance l3 (  0,  10,  2,   2, 1,  0.1, 0.15);
    Luminance l4 (  0, -10,  2,   2, 1,  0.15, 0.2);

    wf.luminanceSeries.push_back (l0);
    wf.luminanceSeries.push_back (l1);
    wf.luminanceSeries.push_back (l2);
    wf.luminanceSeries.push_back (l3);
    wf.luminanceSeries.push_back (l4);

    wf.setLuminanceThetaMap (0.005);

    // Save maps/coords
    wf.saveLuminanceThetaMap ("wf_lum_theta_origin.dat");
    wf.saveLuminanceCoords ("wf_lum_coords_origin.dat");

    EyeFrame ef;
    ef.setDistanceToScreen (wf.distanceToScreen);
    ef.setOffset (0, 0, 0);

    ef.setEyeField (wf.luminanceCoords);

    // Save things which are visualised with show_data.m
    ef.saveLuminanceMap();
    ef.saveLuminanceCartesianCoords();
    ef.saveNeuronPixels();
    ef.saveNeuronPrecise();
    ef.saveCorticalSheet("ef_cort_sheet_origin.dat");

    wf.setLuminanceThetaMap (0.04);
    wf.saveLuminanceThetaMap ("wf_lum_theta_posX.dat");
    wf.saveLuminanceCoords ("wf_lum_coords_posX.dat");
    ef.setEyeField (wf.luminanceCoords);
    ef.saveLuminanceMap();
    ef.saveLuminanceCartesianCoords();
    ef.saveCorticalSheet("ef_cort_sheet_posX.dat");

    wf.setLuminanceThetaMap (0.09);
    wf.saveLuminanceThetaMap ("wf_lum_theta_negX.dat");
    wf.saveLuminanceCoords ("wf_lum_coords_negX.dat");
    ef.setEyeField (wf.luminanceCoords);
    ef.saveLuminanceMap();
    ef.saveLuminanceCartesianCoords();
    ef.saveCorticalSheet("ef_cort_sheet_negX.dat");

    wf.setLuminanceThetaMap (0.14);
    wf.saveLuminanceThetaMap ("wf_lum_theta_posY.dat");
    wf.saveLuminanceCoords ("wf_lum_coords_posY.dat");
    ef.setEyeField (wf.luminanceCoords);
    ef.saveLuminanceMap();
    ef.saveLuminanceCartesianCoords();
    ef.saveCorticalSheet("ef_cort_sheet_posY.dat");

    wf.setLuminanceThetaMap (0.19);
    wf.saveLuminanceThetaMap ("wf_lum_theta_negY.dat");
    wf.saveLuminanceCoords ("wf_lum_coords_negY.dat");
    ef.setEyeField (wf.luminanceCoords);
    ef.saveLuminanceMap();
    ef.saveLuminanceCartesianCoords();
    ef.saveCorticalSheet("ef_cort_sheet_negY.dat");

    return 0;
}
