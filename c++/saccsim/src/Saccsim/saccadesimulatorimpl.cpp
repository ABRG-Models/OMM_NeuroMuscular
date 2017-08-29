#include <OpenSim/OpenSim.h>
#include <OpenSim/Simulation/InverseDynamicsSolver.h>
#include <OpenSim/Common/FunctionSet.h>
#include <OpenSim/Common/Function.h>
#include <OpenSim/Common/Sine.h>
#include <OpenSim/Common/DisplayGeometry.h>
#include <algorithm>
#include <typeinfo>

#include "saccadesimulator.h"
#include "saccadesimulatorimpl.h"
#include "osimutils.h"
#include "eyepassiveforce.h"
#include "musclegeomrecorder.h"

using namespace std;
using namespace SimTK;
using namespace OpenSim;

typedef PathActuator MuscleType;

SaccadeSimulator::SaccadeSimulatorImpl::
    SaccadeSimulatorImpl(Eye &eyeParams, bool left, string resultDir) :
    resDir(resultDir)
{
    saccadeController = new ForwardSaccadeController();
    createOsimModel(eyeModel, eyeParams, (left ? "LeftEye" : "RightEye"), left);
    //eyeModel.print(resDir + (left ? "Left" : "Right") + "Eye.osim");
}

void SaccadeSimulator::SaccadeSimulatorImpl::
    createOsimModel (Model &model, Eye &eyeParams, const string name, bool left)
{
    // Create OpenSim eye model
    model.setUseVisualizer(false);
    model.setName(name);
    addEyeToOpenSimModel(eyeParams, model, left);

    // Add passive eye force
    EyePassiveForce *pf = new EyePassiveForce();
    pf->setStiffness(eyeParams.passiveStiffness);
    pf->setViscosity(eyeParams.passiveViscosity);
    model.addForce(pf);
}

void SaccadeSimulator::SaccadeSimulatorImpl::
    createEyeMuscles (Eye &eyeParams, bool left)
{
    double R = eyeParams.R;
    const Point3D AnnulusOfZinn ( -0.5 * R,         0,  3.0 * R);
    const Point3D Maxillary     ( -1.2 * R,  -0.8 * R,  0.5 * R);
    const Point3D Trochlea      ( -1.2 * R,   0.8 * R,  0.5 * R);

    unsigned i;

    i = 0;
    eyeParams.getMuscle(i++).name = "Medial_Rectus";
    eyeParams.getMuscle(i++).name = "Lateral_Rectus";
    eyeParams.getMuscle(i++).name = "Inferior_Rectus";
    eyeParams.getMuscle(i++).name = "Superior_Rectus";
    eyeParams.getMuscle(i++).name = "Superior_Oblique";
    eyeParams.getMuscle(i++).name = "Inferior_Oblique";
    i = 0;
    eyeParams.getMuscle(i++).eyePoint = Point3D( -R * 0.9,         0,  -R * 0.45);
    eyeParams.getMuscle(i++).eyePoint = Point3D(  R * 0.9,         0,  -R * 0.45);
    eyeParams.getMuscle(i++).eyePoint = Point3D(        0,  -R * 0.9,  -R * 0.45);
    eyeParams.getMuscle(i++).eyePoint = Point3D(        0,   R * 0.9,  -R * 0.45);
    eyeParams.getMuscle(i++).eyePoint = Point3D( R * 0.45,   R * 0.9,        0.0);
    eyeParams.getMuscle(i++).eyePoint = Point3D( R * 0.45,  -R * 0.9,        0.0);
    i = 0;
    eyeParams.getMuscle(i++).pulleyPoint = Point3D( -R * 0.9,         0,  +R * 0.45);
    eyeParams.getMuscle(i++).pulleyPoint = Point3D(  R * 0.9,         0,  +R * 0.45);
    eyeParams.getMuscle(i++).pulleyPoint = Point3D(        0,  -R * 0.9,  +R * 0.45);
    eyeParams.getMuscle(i++).pulleyPoint = Point3D(        0,   R * 0.9,  +R * 0.45);
    eyeParams.getMuscle(i++).pulleyPoint = Point3D( R * 0.45,   R * 0.9,        0.0);
    eyeParams.getMuscle(i++).pulleyPoint = Point3D( R * 0.45,  -R * 0.9,        0.0);

    // Same on all extraocular muscles
    for (i=0; i<6; i++) {
        eyeParams.getMuscle(i).gndPoint = AnnulusOfZinn;
    }

    // These two muscles differentiate in ground point.
    eyeParams.sup_obliq.gndPoint = Trochlea;
    eyeParams.inf_obliq.gndPoint = Maxillary;

    // For the left eye x coords should be mirrored.
    // Above that, they are the same.
    if (left) {
        for (unsigned i=0; i<6; i++) {
            EyeMuscle &mp = eyeParams.getMuscle(i);
            mp.eyePoint.x *= -1.0;
            mp.pulleyPoint.x *= -1.0;
            mp.gndPoint.x *= -1.0;
        }
    }

}

void SaccadeSimulator::SaccadeSimulatorImpl::
    addEyeToOpenSimModel (Eye &eyeParams, Model &model, bool left)
{
    createEyeMuscles(eyeParams, left);

    Inertia inertia = eyeParams.mass * Inertia::sphere(eyeParams.R);
    OpenSim::Body *eyeBody = new OpenSim::Body("Eye", eyeParams.mass, Vec3(0), inertia);
    eyeBody->updDisplayer()->setShowAxes(false);
    BallJoint *eyeJoint = new BallJoint("eyeBallJoint", model.getGroundBody(),
    Vec3(0), Vec3(0), *eyeBody, Vec3(0), Vec3(0));
    CoordinateSet& jcs = eyeJoint->upd_CoordinateSet();
    double range_rad = convertDegreesToRadians(eyeParams.range);
    double range_arr[2] = { -range_rad, range_rad };
    jcs[0].setName("eyeBallRotX");
    jcs[1].setName("eyeBallRotY");
    jcs[2].setName("eyeBallRotZ");
    jcs[0].setRange(range_arr);
    jcs[1].setRange(range_arr);
    jcs[2].setRange(range_arr);

    model.addBody(eyeBody);

    // Create wrapping sphere
    WrapSphere *ws = new WrapSphere();
    ws->setName("EyeGlobeWrapSphere");
    (static_cast<PropertyDbl&>(ws->updPropertyByName("radius"))).setValue(eyeParams.R*0.95);
    eyeBody->addWrapObject(ws);

    for (unsigned i = 0; i < 6; i++) {
        const EyeMuscle &muscle = eyeParams.getMuscle(i);
        MuscleType *m = new MuscleType();
        model.addForce(m);
        m->setName(muscle.name);
        char str[32];
        sprintf(str, "_ground_point_%d", 0);
        m->addNewPathPoint(muscle.name + str, model.getGroundBody(), Vec3(muscle.gndPoint.data));
        m->addNewPathPoint(muscle.name + "_pulley_point", *eyeBody, Vec3(muscle.pulleyPoint.data));
        m->addNewPathPoint(muscle.name + "_eye_point", *eyeBody, Vec3(muscle.eyePoint.data));
        m->updGeometryPath().addPathWrap(*ws);
        m->setMinControl(0.01);
        m->setMaxControl(1);

        // Don't forget to convert grams to Newtons !!!
        if (m->getClassName() == "PathActuator")
        {
            m->setOptimalForce(muscle.maxForce / 100.0);
        }
        else
        {
            Thelen2003Muscle *mm = static_cast<Thelen2003Muscle*>(m);
            mm->setMaxIsometricForce(muscle.maxForce / 100.0);
            mm->setOptimalFiberLength(muscle.optimalFiberLength);
            mm->setTendonSlackLength(muscle.tendonSlackLength);
            mm->setActivationTimeConstant   (0.001);
            mm->setDeactivationTimeConstant (0.001);
        }

    }

}

void SaccadeSimulator::SaccadeSimulatorImpl::
    simulate (Saccade &saccade, bool store, SaccadeController *controller)
{
    SaccadeController *tmpCon = saccadeController;

    if (controller!= NULL)
        saccadeController = controller;

    simulate(saccade.rotFrom, saccade.rotTo, saccade.times,
        saccade.rotx, saccade.roty, saccade.rotz, saccade.vel, saccade.paths,
        saccade.activations, saccade.timesAct, store);

    saccadeController = tmpCon;

}

void SaccadeSimulator::SaccadeSimulatorImpl::
    simulate (const double rotFrom[3], const double rotTo[3],
    vector<double> &times, vector<double> &rX, vector<double> &rY, vector<double> &rZ,
    vector<double> &vel, vector<EyeMusclePaths> &musclePaths,
    vector<EyeMuscleActivations> &acts, vector<double> &actsTimes, bool store)
{
    // Make a local copy of the model.
    OpenSim::Model lmodel(eyeModel);

    // Compute activations to drive the saccade.
    const Vec2 rot_i (rotFrom);
    const Vec2 rot_f (rotTo);

    double duration = 0.5;

    vector<OpenSim::Function*> controlFuncs;

    // If the default controller is to be used, compute appropriate controll funcs.
    if (typeid(*saccadeController)==typeid(ForwardSaccadeController)) {
        computeActivations(lmodel, rot_i, rot_f, controlFuncs, duration, store);
        ((ForwardSaccadeController*) saccadeController)->setControlFunctions(controlFuncs);
    }

    // Create OpenSim controller object.
    SaccadeController_ *controller_ = new SaccadeController_(saccadeController);
    controller_->setActuators(lmodel.getActuators());
    lmodel.addController(controller_);

    // Set initial parameters.
    State &state = lmodel.initSystem();
    const BallJoint &ebj =
    static_cast<const BallJoint&>(lmodel.getJointSet().get("eyeBallJoint"));
    const CoordinateSet &jcs = ebj.get_CoordinateSet();
    jcs.get("eyeBallRotX").setValue(state, convertDegreesToRadians(rot_i[0]));
    jcs.get("eyeBallRotY").setValue(state, convertDegreesToRadians(rot_i[1]));

    lmodel.equilibrateMuscles(state);

    // Add reporters
    ForceReporter* forceReporter = new ForceReporter(&lmodel);
    MuscleGeomRecorder *muscleGeomRecorder = new MuscleGeomRecorder(&lmodel);
    lmodel.addAnalysis(forceReporter);
    lmodel.addAnalysis(muscleGeomRecorder);

    // Simulate
    RungeKuttaMersonIntegrator integrator(lmodel.getMultibodySystem());
    Manager manager(lmodel, integrator);
    manager.setInitialTime(0);
    manager.setFinalTime(duration);
    manager.integrate(state);

    // Convert rads to degs
    Storage &saccadeStates = manager.getStateStorage();
    lmodel.getSimbodyEngine().convertRadiansToDegrees(saccadeStates);

    // Write results to out data structures
    rX.clear();
    rY.clear();
    rZ.clear();
    vel.clear();
    times.resize(saccadeStates.getSize());
    musclePaths = muscleGeomRecorder->getPaths();

    for (int i = 0; i<saccadeStates.getSize(); i++) {
        double x,   y,  z;
        double vx, vy, vz;
        saccadeStates.getTime(i, times[i]);

        saccadeStates.getData(i, 0, x);
        saccadeStates.getData(i, 1, y);
        saccadeStates.getData(i, 2, z);

        saccadeStates.getData(i, 3, vx);
        saccadeStates.getData(i, 4, vy);
        saccadeStates.getData(i, 5, vz);

        rX.push_back(x);
        rY.push_back(y);
        rZ.push_back(z);
        vel.push_back(::sqrt(vx*vx + vy*vy));
    }

    // Get activation trajectory
    acts.resize(controller_->getControlLog().size());
    actsTimes.resize(controller_->getControlLog().size());

    vector<int> index(acts.size(), 0);
    for (int i = 0 ; i != index.size() ; i++) {
        index[i] = i;
    }

#ifndef NO_CPP_11_COMPILER
    sort(index.begin(), index.end(),
        [&](const int& a, const int& b) {
            return (controller_->getControlTimesLog()[a] <
                    controller_->getControlTimesLog()[b]);
        }
    );
#else // Use much uglier and hackier code to sort from low to high
    bool notsorted = true;
    while (notsorted) {
        notsorted = false;
        for (int i = 0; i < index.size()-1; i++) {
            if (controller_->getControlTimesLog()[i] > controller_->getControlTimesLog()[i+1]) {
                // swap
                int val = index[i];
                index[i] = index[i+1];
                index[i+1] = val;
                notsorted = true;
            }
        }
    }
#endif

    for (int i = 0 ; i != acts.size() ; i++) {
        acts[i] = controller_->getControlLog()[index[i]];
        actsTimes[i] = controller_->getControlTimesLog()[index[i]];
    }

    // Delete duplicates
    double ii = 0;
    for (int i=1; i<acts.size(); i++) {
        if (actsTimes[i] <= actsTimes[ii]) {
            actsTimes.erase(actsTimes.begin()+i);
            acts.erase(acts.begin()+i);
            --i;
        }
        ii = i;
    }

    // Store simulation products if requested
    if (store)
    {
        // Make file prefix
        string prfx = resDir + lmodel.getName() + "_" + rot_i.toString().substr(1, -1) +
            "-" + rot_f.toString().substr(1, -1);

        // Write files
        forceReporter->getForceStorage().print(prfx + "_Forces.mot");

        saccadeStates.print(prfx + "_States.sto");

        OsimUtils::writeFunctionsToFile(actsTimes, acts,
            prfx + "_Excitations.sto");
    }

}

void SaccadeSimulator::SaccadeSimulatorImpl::
    simulate4Brahms (Saccade &saccade, bool store, SaccadeController *controller, double timestep, string integrator_name, double duration)
{
    SaccadeController *tmpCon = saccadeController;

    if (controller!= NULL)
        saccadeController = controller;

    simulate4Brahms(saccade.rotFrom, saccade.rotTo, saccade.times,
                    saccade.rotx, saccade.roty, saccade.rotz,
                    duration, timestep, integrator_name, store);

    saccadeController = tmpCon;
}

void SaccadeSimulator::SaccadeSimulatorImpl::
    simulate4Brahms(const double rotFrom[3], const double rotTo[3],
    vector<double> &times,
    vector<double> &rX, vector<double> &rY, vector<double> &rZ,
    double& duration, const double& timestep_size, const string& simtk_integrator,
    bool store)
{
    // Make a local copy of the model.
    OpenSim::Model lmodel(eyeModel);

    // Compute activations to drive the saccade.
    const Vec2 rot_i (rotFrom);
    const Vec2 rot_f (rotTo);

    cout << "duration initially " << duration << endl;

    // If the default controller is to be used, compute appropriate controll funcs.
    if (typeid(*saccadeController)==typeid(ForwardSaccadeController)) {
        vector<OpenSim::Function*> controlFuncs;
        cout << "computeActivations..." << endl;
        computeActivations(lmodel, rot_i, rot_f, controlFuncs, duration, store);
        ((ForwardSaccadeController*) saccadeController)->setControlFunctions(controlFuncs);
    }
    cout << "duration now " << duration << endl;

    // Create OpenSim controller object.
    SaccadeController_ *controller_ = new SaccadeController_(saccadeController);
    controller_->setActuators(lmodel.getActuators());
    lmodel.addController(controller_);

    // Set initial parameters.
    State &state = lmodel.initSystem();
    const BallJoint &ebj =
    static_cast<const BallJoint&>(lmodel.getJointSet().get("eyeBallJoint"));
    const CoordinateSet &jcs = ebj.get_CoordinateSet();
    jcs.get("eyeBallRotX").setValue(state, convertDegreesToRadians(rot_i[0]));
    jcs.get("eyeBallRotY").setValue(state, convertDegreesToRadians(rot_i[1]));

    lmodel.equilibrateMuscles(state);

    // Add force reporter
    ForceReporter* forceReporter = new ForceReporter(&lmodel);
    lmodel.addAnalysis(forceReporter);

    // Simulate with a SimTk::Integrator.
    Integrator* integrator = static_cast<Integrator*>(0);

    double dtFirst = 1.0e-6; // The default for Manager::integrate's 2nd arg.
    cout << "Requested integrator: " << simtk_integrator << endl;
    if (simtk_integrator == "RungeKuttaFeldberg") {
        // sic. Should be _Fehlberg_ I think.
        integrator = new RungeKuttaFeldbergIntegrator (lmodel.getMultibodySystem());

    } else if (simtk_integrator == "RungeKutta3") {
        // 3rd order Runge Kutta.
        integrator = new RungeKutta3Integrator (lmodel.getMultibodySystem());

    } else if (simtk_integrator == "ExplicitEuler") {
        // Regular ole' Forward Euler will take a fixed timestep.
        integrator = new ExplicitEulerIntegrator (lmodel.getMultibodySystem());
        integrator->setFixedStepSize (timestep_size);
        dtFirst = timestep_size;

    } else {
        // Chris's code originally used the RungeKuttaMersonIntegrator, hence select by default
        integrator = new RungeKuttaMersonIntegrator (lmodel.getMultibodySystem());
    }

    Manager manager(lmodel, *integrator);
    manager.setInitialTime(0);
    manager.setFinalTime(duration);
    manager.integrate(state, dtFirst); // by default integrate's 2nd arg is dtFirst = 1.0e-6

    // Convert rads to degs
    Storage &saccadeStates = manager.getStateStorage();
    lmodel.getSimbodyEngine().convertRadiansToDegrees(saccadeStates);

    // Write results to out data structures
    rX.clear(); rY.clear(); rZ.clear();

    if (saccadeStates.getSize()>times.size())
        times.resize(saccadeStates.getSize());

    for (int i = 0; i<saccadeStates.getSize(); i++) {
        double x, y, z;
        saccadeStates.getTime(i, times[i]);
        saccadeStates.getData(i, 0, x);
        saccadeStates.getData(i, 1, y);
        saccadeStates.getData(i, 2, z);
        rX.push_back(x);
        rY.push_back(y);
        rZ.push_back(z);
    }

    // Get activation trajectory
    vector<EyeMuscleActivations> acts;
    vector<double> actsTimes;

    acts.resize(controller_->getControlLog().size()-1);
    actsTimes.resize(controller_->getControlLog().size()-1);

    vector<int> index(acts.size(), 0);
    for (int i = 0 ; i != index.size() ; i++) {
        index[i] = i;
    }

#ifndef NO_CPP_11_COMPILER
    sort(index.begin(), index.end(),
        [&](const int& a, const int& b) {
            return (controller_->getControlTimesLog()[a] <
                    controller_->getControlTimesLog()[b]);
        }
    );
#else // Use much uglier and hackier code to sort from low to high
    bool notsorted = true;
    while (notsorted) {
        notsorted = false;
        for (int i = 0; i < index.size()-1; i++) {
            if (controller_->getControlTimesLog()[i] > controller_->getControlTimesLog()[i+1]) {
                // swap
                int val = index[i];
                index[i] = index[i+1];
                index[i+1] = val;
                notsorted = true;
            }
        }
    }
#endif

    for (int i = 0 ; i != acts.size() ; i++) {
        acts[i] = controller_->getControlLog()[index[i]];
        actsTimes[i] = controller_->getControlTimesLog()[index[i]];
    }

    // Delete duplicates
    double ii = 0;
    for (int i=1; i<acts.size(); i++) {
        if (actsTimes[i] <= actsTimes[ii]) {
            actsTimes.erase(actsTimes.begin()+i);
            acts.erase(acts.begin()+i);
            --i;
        }
        ii = i;
    }

    // Store simulation products if requested
    if (store) {
        string prfx = resDir + "Saccade";
        forceReporter->getForceStorage().print(prfx + "_Forces.mot");
        saccadeStates.print(prfx + "_States.sto");
        OsimUtils::writeFunctionsToFile(actsTimes, acts, prfx + "_Excitations.sto");
    }

    cout << "SaccadeSimulatorImpl::simulate returning" << endl;

    // Clean up the integrator.
    delete integrator;
}

void SaccadeSimulator::SaccadeSimulatorImpl::
    inverseSimulate(Saccade &saccade, string name)
{
    // Create the state sequence corresponding to the recorded saccade.
    OpenSim::Model lmodel(eyeModel);
    State state = lmodel.initSystem();
    Storage statesRecorded;
    statesRecorded.setDescription("Recorded Saccade");
    Array<std::string> stateNames = lmodel.getStateVariableNames();
    stateNames.insert(0, "time");
    statesRecorded.setColumnLabels(stateNames);
    Array<double> stateVals;

    for(int i=0; i<saccade.rotx.size(); i++) {
        state.updQ()[0] = convertDegreesToRadians(saccade.rotx[i]);
        state.updQ()[2] = convertDegreesToRadians(saccade.rotz[i]);
        state.updQ()[1] = convertDegreesToRadians(saccade.roty[i]);

        lmodel.getStateValues(state,stateVals);
        statesRecorded.append(saccade.times[i], stateVals.size(), stateVals.get());
    }

    // Compute velocities with simple numerical diff of consecutive values
    double t2, t1;
    statesRecorded.getTime(0, t1);
    statesRecorded.getTime(1, t2);
    double dt = t2-t1;

    for(int i=1; i<saccade.rotx.size(); i++) {
        StateVector *sv2 = statesRecorded.getStateVector(i);
        StateVector *sv1 = statesRecorded.getStateVector(i-1);
        double v2, v1, u;

        // DOF: x
        sv2->getDataValue(1, v2);
        sv1->getDataValue(1, v1);
        u = (v2-v1) / dt;
        sv2->setDataValue(4, u);

        // DOF: y
        sv2->getDataValue(2, v2);
        sv1->getDataValue(2, v1);
        u = (v2-v1) / dt;
        sv2->setDataValue(5, u);

        // DOF: z
        sv2->getDataValue(3, v2);
        sv1->getDataValue(3, v1);
        u = (v2-v1) / dt;
        sv2->setDataValue(6, u);
    }

    statesRecorded.setInDegrees(false);

    // Perform the static optimization
    StaticOptimization so(&lmodel);
    so.setStatesStore(statesRecorded);
    int ns = statesRecorded.getSize();
    double ti, tf;
    statesRecorded.getTime(0, ti);
    statesRecorded.getTime(ns-1, tf);
    so.setStartTime(ti);
    so.setEndTime(tf);

    // Static optimization loop
    State s = lmodel.initSystem();
    for (int i = 0; i < ns; i++) {
        statesRecorded.getData(i, s.getNY(), &s.updY()[0]);
        Real t = 0.0;
        statesRecorded.getTime(i, t);
        s.setTime(t);
        lmodel.assemble(s);
        lmodel.getMultibodySystem().realize(s, SimTK::Stage::Velocity);

        if (i == 0 )
            so.begin(s);
        else if (i == ns)
            so.end(s);
        else
            so.step(s, i);
    }

    // Extract activations from storage object
    Storage *as = so.getActivationStorage();
    int na = lmodel.getActuators().getSize();
    saccade.activations.resize(statesRecorded.getSize());

    for (int row = 0; row<statesRecorded.getSize(); row++) {
        for (int i = 0; i<na; i++) {
            as->getData(row, i, saccade.activations[row].act[i]);
             saccade.activations[row].act[i];
        }
    }

    // Perform validating fwd simulation
    double rotFrom[3] = {saccade.rotx[0], saccade.roty[0], saccade.rotz[0]};
    double rotTo[3] = {saccade.rotx.back(), saccade.roty.back(), saccade.rotz.back()};
    vector<double> times, timesAct, rotx, roty, rotz, vel;
    vector<EyeMuscleActivations> acts;
    vector<EyeMusclePaths> paths;
    ValidationSaccadeController controller;
    controller.setControlActivations(saccade.times, saccade.activations);
    SaccadeController *tmpCon = saccadeController;
    saccadeController = &controller;
    simulate(rotFrom, rotTo, times, rotx, roty, rotz, vel, paths, acts, timesAct, 1);
    saccadeController = tmpCon;

    // Store results
    OsimUtils::writeFunctionsToFile(
        saccade.times,
        saccade.activations,
        resDir + name + ".sto"
    );

    // lmodel.getSimbodyEngine().convertRadiansToDegrees(statesRecorded);
    statesRecorded.setInDegrees(false);
    statesRecorded.print(resDir + "recorded_states.sto");
}

void SaccadeSimulator::SaccadeSimulatorImpl::
    computeActivations (Model &model, const Vec2 &rot_i, const Vec2 &rot_f,
    vector<OpenSim::Function*> &controlFuncs, double &duration, bool store)
{
    Vector ssai, ssaf;

    calcSSAct(model, rot_i[0], rot_i[1], ssai);
    calcSSAct(model, rot_f[0], rot_f[1], ssaf);

    const int N = 9;

    double angle = sqrt(pow(rot_i[0]-rot_f[0], 2) + pow(rot_i[1]-rot_f[1], 2));

    const double t_eq = 0.000;
    const double dur_xc = (25.0 + 0.95 * angle) / 1000.;
    const double t_fix  = (55.0 + 0.5 * angle) / 1000.;

    double phases[N] = {
       -t_eq,
        0,
        0,
        dur_xc,
        dur_xc * 1.05,
        t_fix,
        t_fix + 0.005,
        t_fix + 0.010,
        t_fix*2
    };
    for (int i=0; i<N; i++) phases[i]+=t_eq;

    // Construct control functions
    controlFuncs.clear();
    double values[N];

    for (int i = 0; i < ssaf.size(); i++)  {
        double dssa = ssaf[i] - ssai[i];
        int j=0;

        values[j++] = ssai[i];                  // Leading delay
        values[j] = values[j-1];
        j++;

        values[j++] = ssaf[i] + dssa * 1.15;    // Excess force
        values[j] = values[j-1];
        j++;

        values[j++] = ssai[i] + dssa * 1.000;   // Error phase
        values[j] = values[j-1];
        j++;

        values[j++] = ssai[i] + dssa * 1.000;   // Fixing phase

        values[j++] = ssaf[i];                  // Steady state phase
        values[j] = values[j-1];
        j++;

        OpenSim::Function *controlFunc = new PiecewiseLinearFunction(N, phases, values);
        controlFunc->setName(model.getActuators()[i].getName());
        controlFunc->setName("Excitation_" + model.getActuators()[i].getName());
        controlFuncs.push_back(controlFunc);
    }

    duration = t_eq + t_fix * 4;
}

void SaccadeSimulator::SaccadeSimulatorImpl::
    calcSSAct (Model &model, double rotX, double rotY, Vector &activations)
{
    Real rotx = convertDegreesToRadians(rotX);
    Real roty = convertDegreesToRadians(rotY);
    Real rotz = 0;
    State &state = model.initSystem();
    state.updQ()[0] = rotx;
    state.updQ()[1] = roty;
    state.updQ()[2] = rotz;

    // Perform a dummy forward simulation without forces,
    // just to obtain a state-series to be used by stat opt
    OsimUtils::disableAllForces(state, model);
    RungeKuttaMersonIntegrator integrator(model.getMultibodySystem());
    Manager manager(model, integrator);
    manager.setInitialTime(0);
    manager.setFinalTime(2);
    manager.integrate(state);

    // Perform a quick static optimization that will give us
    // the steady state activations needed to overcome the passive forces
    OsimUtils::enableAllForces(state, model);

    Storage &states = manager.getStateStorage();
    states.setInDegrees(false);
    StaticOptimization so(&model);

    so.setStatesStore(states);
    State &s = model.initSystem();
    states.getData(0, s.getNY(), &s.updY()[0]);
    s.setTime(0);
    so.begin(s);
    so.end(s);

    Storage *as = so.getActivationStorage();
    int na = model.getActuators().getSize();
    activations.resize(na);
    int row = as->getSize() - 1;

    // Store activations to out vector
    for (int i = 0; i<na; i++)
        as->getData(row, i, activations[i]);
}

void SaccadeSimulator::SaccadeSimulatorImpl::
    invDyn (Model &model, FunctionSet &qset,
    Array_<Real> &times, Array_<Vector> &forceTraj, double dur, double step)
{
    // Prepare time series
    InverseDynamicsSolver ids(model);
    times.resize((int)(dur / step) + 1, 0);
    for (unsigned i = 0; i < times.size(); i++)
        times[i] = step * i;

    // Solve for generalized joints forces
    State &s = model.initSystem();
    ids.solve(s, qset, times, forceTraj);
}

void SaccadeSimulator::SaccadeSimulatorImpl::
    loadSaccadeFromFile(Saccade &saccade, const string &filename_prefix)
{
    cout << "Loading states from: " << filename_prefix + "_States.sto" << endl;
    cout << "Loading activations log from: " << filename_prefix + "_Excitations.sto" << endl;

    Storage traj_sto(filename_prefix + "_States.sto");
    Storage acts_sto(filename_prefix + "_Excitations.sto");

    // Populate saccade trajectory from state storage.
    unsigned traj_size = traj_sto.getSize();
    saccade.times.resize(traj_size);

    for (int i = 0; i<traj_size; i++) {
        double x,   y,  z;
        double vx, vy, vz;
        traj_sto.getTime(i, saccade.times[i]);

        traj_sto.getData(i, 0, x);
        traj_sto.getData(i, 1, y);
        traj_sto.getData(i, 2, z);

        traj_sto.getData(i, 3, vx);
        traj_sto.getData(i, 4, vy);
        traj_sto.getData(i, 5, vz);

        saccade.rotx.push_back(x);
        saccade.roty.push_back(y);
        saccade.rotz.push_back(z);
        saccade.vel.push_back(::sqrt(vx*vx + vy*vy));
    }

    // Populate activations from storage.
    unsigned acts_size = acts_sto.getSize();
    saccade.activations.resize(acts_size);
    saccade.timesAct.resize(acts_size);

    for (int i = 0; i<acts_size; i++) {
        acts_sto.getTime(i, saccade.timesAct[i]);
        for (int mi=0; mi<6; mi++)
            acts_sto.getData(i, mi, saccade.activations[i].act[mi]);
    }

    //saccade.paths.resize(traj_size);
    double rotFrom[3] = {saccade.rotx[0], saccade.roty[0], saccade.rotz[0]};
    double rotTo[3] = {saccade.rotx.back(), saccade.roty.back(), saccade.rotz.back()};
    vector<double> times, timesAct, rotx, roty, rotz, vel;
    vector<EyeMuscleActivations> acts;
    vector<EyeMusclePaths> paths;
    ValidationSaccadeController controller;
    controller.setControlActivations(saccade.times, saccade.activations);
    SaccadeController *tmpCon = saccadeController;
    saccadeController = &controller;
    simulate(rotFrom, rotTo, times, rotx, roty, rotz, vel, paths, acts, timesAct, 1);
    saccadeController = tmpCon;

    // Copy from validating simulation
    saccade.times = times;
    saccade.rotx = rotx;
    saccade.roty = roty;
    saccade.rotz = rotz;
    saccade.vel = vel;
    saccade.paths = paths;
//    saccade.activations = acts;
//    saccade.timesAct = timesAct;
}






