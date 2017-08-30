#include "osimutils.h"
#include "saccadesimulator.h"

template <class charT, charT sep> class punct_facet : public std::numpunct<charT> {
protected:
    charT do_decimal_point() const { return sep; }
};

Real OsimUtils::evalFunc(OpenSim::Function *f, Real x)
{
    Vector xv(1); xv[0] = x;
    return f->calcValue(xv);
}

void OsimUtils::disableAllForces(State &state, Model &model)
{
    for (int i = 0; i < model.getForceSet().getSize(); i++)
        model.updForceSet().get(i).setDisabled(state, true);
}

void OsimUtils::disableAllNonMuscleForces(State &state, Model &model)
{
    for (int i = 0; i < model.getForceSet().getSize(); i++) {
        if ( !dynamic_cast<Muscle*>(&model.updForceSet().get(i)))
            continue;
        model.updForceSet().get(i).setDisabled(state, true);
    }
}

void OsimUtils::disableAllMuscles(State &state, Model &model)
{
    for (int i = 0; i < model.getMuscles().getSize(); i++)
        model.getMuscles().get(i).setDisabled(state, true);
}

void OsimUtils::enableAllForces(State &state, Model &model)
{
    for (int i = 0; i < model.getForceSet().getSize(); i++)
        model.updForceSet().get(i).setDisabled(state, false);
}

void OsimUtils::enableAllNonMuscleForces(State &state, Model &model)
{
    for (int i = 0; i < model.getForceSet().getSize(); i++) {
        if ( !dynamic_cast<Muscle*>(&model.updForceSet().get(i)))
            continue;
        model.updForceSet().get(i).setDisabled(state, false);
    }
}

void OsimUtils::enableAllMuscles(State &state, Model &model)
{
    for (int i = 0; i < model.getMuscles().getSize(); i++)
        model.getMuscles().get(i).setDisabled(state, false);
}

void OsimUtils::writeFunctionsToFile(const vector<OpenSim::Function*>fs,
    const string filename, double dur, double step)
{
    ofstream file(filename.c_str());

    // Set decimal separator character
    file.imbue(std::locale(file.getloc(), new punct_facet<char, '.'>));

    file << "nRows=" << (int)(dur/step+1) << "\n";
    file << "nColumns=" << (1+fs.size()) << "\n";
    file << "endheader" << "\n\n";
    file << "time" << " ";
    for (int i=0; i< fs.size(); i++) file << fs[i]->getName() << ' ';
    file << "\n";

    Vector xv(1);
    for (double t = 0; t <= dur; t += step) {
        xv[0] = t;
        file << t << "\t";
        for (int i=0; i< fs.size(); i++) file << fs[i]->calcValue(xv) << '\t';
        file << "\n";
    }

    file << endl;
}

void OsimUtils::writeFunctionsToFile(const vector<double> &times, 
    const vector<EyeMuscleActivations> &acts, const string filename)
{
    ofstream file(filename.c_str());

    // Set decimal separator character
    file.imbue(std::locale(file.getloc(), new punct_facet<char, '.'>));

    file << "nRows=" << times.size() << "\n";
    file << "nColumns=" << (1+6) << "\n";
    file << "endheader" << "\n\n";
    file << "time" << " ";
    for (int i=0; i< 6; i++) file << "Act_" << i << ' ';
    file << "\n";

    Vector xv(1);
    for (double t = 0; t<times.size(); t++) {
        file << times[t] << "\t";
        for (int i=0; i<6; i++) 
            file << acts[t].act[i] << '\t';
        file << "\n";
    }

    file << endl;
}

void OsimUtils::writeForcesToFile(Model &model,const string filename,
    const Array<Vector> &forces, const Vector &times)
{
    // Write result forces to file
    ofstream file(filename.c_str());

    // Labels
    file << "times ";
    for (int i = 0; i < model.getCoordinateSet().getSize(); i++) {
        bool r = model.getCoordinateSet()[i].getMotionType() == Coordinate::Rotational;
        file << model.getCoordinateSet().get(i).getName()+(r?"_moment":"_force")<<" ";
    }
    file << endl;

    // Data
    for (unsigned l = 0; l < forces.size(); l++) {
        file << times[l] << "\t";
        for (int f = 0; f < forces[l].size(); f++)
            file << forces[l][f] << "\t";
        file << endl;
    }

    file.close();
}
