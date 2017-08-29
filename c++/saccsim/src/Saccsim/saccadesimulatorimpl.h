#ifndef SACCADESIMULATOR_IMPL_H
#define SACCADESIMULATOR_IMPL_H

#include "saccadesimulator.h"
#include "eyepassiveforce.h"
#include "osimutils.h"

using namespace SimTK;
using namespace OpenSim;

class SaccadeController_ : public OpenSim::Controller
{
    OpenSim_DECLARE_CONCRETE_OBJECT(SaccadeController_, Controller)

    SaccadeController *controller;  // The object that all controll is delegated to.
    vector<double> timesLog;        // Log every time that the controller is invoked.
    vector<EyeMuscleActivations> activationLog; // Log the calculated activations.

public:
    SaccadeController_ (SaccadeController *con) : controller(con)
    {
        setNumControls(6);
    }

    void reset () {timesLog.clear(); activationLog.clear();}

    const vector<double> &getControlTimesLog() {return timesLog;}

    const vector<EyeMuscleActivations> &getControlLog() {return activationLog;}

    void computeControls(const State &s, Vector &controls) const OVERRIDE_11
    {
        EyeMuscleActivations activations;

        controller->control(s.getTime(),
            s.getQ()[0], s.getQ()[1], s.getQ()[2],
            s.getU()[0], s.getU()[1], s.getU()[2],
            activations);

        // Copy activations to OpenSim out vector
        for (int i=0; i<getNumControls(); ++i)
            controls[i] = activations.act[i];

        // Log activations (Need to drop const-ness)
        SaccadeController_ *this_ = const_cast<SaccadeController_*>(this);
        this_->timesLog.push_back(s.getTime());
        this_->activationLog.push_back(activations);
    }

};

class ForwardSaccadeController : public SaccadeController
{
    vector<OpenSim::Function*> cf;

public: 
    ~ForwardSaccadeController ()
    {
        for (unsigned i=0; i< cf.size(); i++)
            delete cf[i];
    }

    void setControlFunctions(vector<OpenSim::Function*> &contrFuncs) 
    {
        for (unsigned i=0; i< cf.size(); i++)
            delete cf[i];

        cf = contrFuncs;
    }

    void control ( const double time,
        const double rotX,  const double rotY,  const double rotZ,
        const double rotXu, const double rotYu, const double rotZu,
        EyeMuscleActivations &activations)
    {
        for (int i=0; i<6; i++)
            activations.act[i] = OsimUtils::evalFunc(cf[i], time);
    }

};

class ValidationSaccadeController : public SaccadeController
{
    vector<double> actTimes;
    vector<EyeMuscleActivations> acts;

public:
    void setControlActivations(vector<double> &actTimes_, 
        vector<EyeMuscleActivations> &acts_) 
    {
        actTimes = actTimes_;
        acts = acts_;
    }

    void control ( const double time,
        const double rotX,  const double rotY,  const double rotZ,
        const double rotXu, const double rotYu, const double rotZu,
        EyeMuscleActivations &activations)
    {
        // Find current time
        int ti;
        for (ti=0; ti<actTimes.size(); ti++) 
            if (actTimes[ti] >= time) 
                break;

        // If time exceeds max time, stick to the latest activation value.
        if (ti == actTimes.size()) ti--;

        // Set the activation
        activations = acts[ti];
    }

};

struct SaccadeSimulator::SaccadeSimulatorImpl
{
    // Data members
    string resDir;
    SaccadeController *saccadeController;
    OpenSim::Model eyeModel;

    SaccadeSimulatorImpl(Eye &eyeParams, bool left, string resultDir);

    SaccadeController* getController() { return saccadeController;}

    /**
     * @param eye_params
     * @param left
     */
    void createOsimModel(Model &model, Eye &eyeParams, const string name, bool left);

    /**
     * @param eye
     * @param muscleParams
     * @param left
     */
    void static createEyeMuscles(Eye &eyeParams, bool left);

    /**
     * @param eye
     * @param model
     * @param left
     */
    void static addEyeToOpenSimModel(Eye &eyeParams, Model &model, bool left);

    /**
     * @param saccade
     * @param store
     */
    void simulate(Saccade &saccade, bool store, SaccadeController *controller);

    /**
     * @brief simulate4Brahms
     * @param saccade
     * @param store
     * @param controller
     * @param timestep
     * @param integrator String Name of SimTK integrator to use.
     * @param duration
     */
    void simulate4Brahms(Saccade &saccade, bool store, SaccadeController *controller,
        double timestep, string integrator, double duration);

    void simulate4Brahms(const double rotFrom[3], const double rotTo[3],
        vector<double> &times, vector<double> &rX, vector<double> &rY, vector<double> &rZ,
        double& duration, const double& timestep_size, const string& simtk_integrator, bool store);

    void inverseSimulate(Saccade &saccade, string name);

    /**
     * @param rotFrom
     * @param rotTo
     * @param times
     * @param rotsX
     * @param rotsY
     * @param storeExcitations
     */
    void simulate(const double rotFrom[3], const double rotTo[3],
        vector<double> &times, vector<double> &rX, vector<double> &rY, vector<double> &rZ,
        vector<double> &vel, vector<EyeMusclePaths> &musclePaths,
        vector<EyeMuscleActivations> &activations, vector<double> &timesAct, bool store);

    void computeActivations(Model &model, const Vec2 &rot_i, const Vec2 &rot_f,
        vector<OpenSim::Function*> &controlFuncs, double &duration, bool store);

    /**
     * @param model
     * @param qset
     * @param times
     * @param forceTraj
     * @param dur
     * @param step
     */
    void invDyn(Model &model, FunctionSet &qset, Array_<Real> &times,
        Array_<Vector> &forceTraj, double dur, double step);

    /**
     * Find the actuator activations that keep the model in the specified orientation.
     * @param rotX          [IN]    Vertical rotation in degrees
     * @param rotY          [IN]    Horizontal rotation in degrees
     * @param activations   [OUT]   Muscle activation
     */
    void calcSSAct(Model &model, double rotX, double rotY, Vector &activations);

    void loadSaccadeFromFile(Saccade &saccade, const std::string &filename_prefix);
};

#endif
