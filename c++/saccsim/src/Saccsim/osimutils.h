#ifndef OSIMUTILS_H
#define OSIMUTILS_H

#include <string>
#include <OpenSim/OpenSim.h>
#include <OpenSim/Common/Function.h>
#include "saccadesimulator.h"

using namespace std;
using namespace SimTK;
using namespace OpenSim;
using namespace notremor;

#define echo(x) cout<<#x<<" = "<<x<<endl

class OsimUtils
{
public:

    Real static evalFunc(OpenSim::Function *f, Real x);

    void static disableAllForces(State &state, Model &model);

    void static disableAllNonMuscleForces(State &state, Model &model);

    void static enableAllForces(State &state, Model &model);

    void static enableAllNonMuscleForces(State &state, Model &model);

    void static disableAllMuscles(State &state, Model &model);

    void static enableAllMuscles(State &state, Model &model);

    void static writeFunctionsToFile(const vector<OpenSim::Function*>fs,
        const string filename, double dur, double step);

    void static writeFunctionsToFile(const vector<double> &times, 
        const vector<EyeMuscleActivations> &acts, const string filename);

    void static writeForcesToFile(Model &model,
        const string filename, const Array<Vector> &forces, const Vector &times);

};

#endif
