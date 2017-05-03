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

#include <json/json.h>

using namespace wdm;
using namespace std;

std::ofstream DBGSTREAM;

void readLuminanceFile (WorldFrame& wf)
{
    Json::Value root;
    Json::Reader reader;
    std::ifstream jsonfile ("luminances.json", std::ifstream::binary);

    bool parsingSuccessful = reader.parse (jsonfile, root);
    if (!parsingSuccessful) {
        // report to the user the failure and their locations in the document.
        cerr << "Failed to parse JSON luminances: " << reader.getFormattedErrorMessages();
        return;
    }
    const Json::Value plugins = root["luminances"];
    for (int index = 0; index < plugins.size(); ++index) {  // Iterates over the sequence elements.
        Json::Value v = plugins[index];
        // args for Luminance are: (thX, thY, crosswidth, barthickness, brightness, timeOn, timeOff)
        if (v.get ("shape", "cross").asString() == "cross") {
            CrossLuminance cross_lum (v.get ("thetaX", 0.0).asInt(),
                                      v.get ("thetaY", 0.0).asInt(),
                                      v.get ("widthThetaX", 0.0).asInt(),
                                      v.get ("widthThetaY", 0.0).asInt(),
                                      v.get ("luminance", 0.0).asFloat(),
                                      v.get ("timeOn", 0.0).asFloat(),
                                      v.get ("timeOff", 0.0).asFloat());
            wf.luminanceSeries.push_back (cross_lum);
        } else {
            Luminance rect_lum (v.get ("thetaX", 0.0).asInt(),
                                v.get ("thetaY", 0.0).asInt(),
                                v.get ("widthThetaX", 0.0).asInt(),
                                v.get ("widthThetaY", 0.0).asInt(),
                                v.get ("luminance", 0.0).asFloat(),
                                v.get ("timeOn", 0.0).asFloat(),
                                v.get ("timeOff", 0.0).asFloat());
            wf.luminanceSeries.push_back (rect_lum);
        }
        cout << "Added " << v.get ("shape", 0.0).asString()
             << "luminance with params: thetaX:" << v.get ("thetaX", 0.0).asInt()
             << " thetaY:" << v.get ("thetaY", 0.0).asInt()
             << " widthThetaX:" << v.get ("widthThetaX", 0.0).asInt()
             << " widthThetaY:" << v.get ("widthThetaY", 0.0).asInt()
             << " luminance:" << v.get ("luminance", 0.0).asFloat()
             << " timeOn:" << v.get ("timeOn", 0.0).asFloat()
             << " timeOff:" << v.get ("timeOff", 0.0).asFloat() << endl;
    }
}

int main()
{
    { // Showing the use of readLuminanceFile:
        WorldFrame wf0;
        readLuminanceFile (wf0);
    }

    WorldFrame wf;

    // Straight ahead: thetax=0, thetay=0.
    // Luminance (thetax, thetay, widthThX, widthThY, luminosity, time_on, time_off)
    CrossLuminance l1 (0, 0, 6, 2, 2, 0.0, 0.05);
    wf.luminanceSeries.push_back (l1);
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


    wf.setLuminanceThetaMap (0.07); // Set up the map for time=0.07s.
    wf.saveLuminanceThetaMap("worldframe_lum_map_off.dat");
    //wf.saveLuminanceCoords("");
    ef.setEyeField (wf.luminanceCoords);
    // Save things which are visualised with show_data.m
    ef.saveLuminanceMap("eyeframe_lum_map_off.dat");
    ef.saveLuminanceCartesianCoords("eyeframe_lum_cart_off.dat");
    ef.saveNeuronPixels("neuron_pixels_w_lum_off.dat");
    ef.saveNeuronPrecise("neuron_precise_w_lum_off.dat");
    ef.saveCorticalSheet("cortical_sheet_off.dat");

    return 0;
}
