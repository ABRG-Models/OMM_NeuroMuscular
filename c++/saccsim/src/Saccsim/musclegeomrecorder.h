#ifndef MUSCLEGEOMREC_H
#define MUSCLEGEOMREC_H

#include <OpenSim/OpenSim.h>
#include <string>
#include "saccadesimulator.h"

using namespace notremor;

namespace OpenSim { 

class MuscleGeomRecorder : public Analysis 
{
    OpenSim_DECLARE_CONCRETE_OBJECT(MuscleGeomRecorder, Analysis);
    
public:
    MuscleGeomRecorder();
    MuscleGeomRecorder(Model *model);
    vector<EyeMusclePaths>& getPaths() {return musclePaths;}

private:
    vector<EyeMusclePaths> musclePaths;

protected:
    int step(const SimTK::State& s, int stepNumber);
    int record(const SimTK::State& s);
};

}

#endif
