#ifndef SACCADESIMULATOR_H
#define SACCADESIMULATOR_H

#include "saccadesimulatordll.h"

#include <string>
#include <vector>

using namespace std;

namespace notremor {

struct Point3D 
{
    union
    {
        struct { double x,y,z; };
        double data[3];
    };
    Point3D():x(0), y(0), z(0){}
    Point3D(double x, double y, double z):x(x), y(y), z(z){}
};

struct EyeMuscle
{
    string  name;
    Point3D gndPoint;
    Point3D pulleyPoint;
    Point3D eyePoint;
    double  maxForce;
    double  resetingLength;
    double  optimalFiberLength;
    double  tendonSlackLength;
};

struct Eye
{
    // Anatomy
    double R;
    double mass;
    double range;
    double eyesDist;

    // Muscle params
    EyeMuscle med_rect;
    EyeMuscle lat_rect;
    EyeMuscle inf_rect;
    EyeMuscle sup_rect;
    EyeMuscle sup_obliq;
    EyeMuscle inf_obliq;

    // Passive dynamic
    double passiveViscosity;
    double passiveStiffness;

    EyeMuscle& getMuscle(int index) {
        if (index==0) return med_rect;
        if (index==1) return lat_rect;
        if (index==2) return inf_rect;
        if (index==3) return sup_rect;
        if (index==4) return sup_obliq;
        if (index==5) return inf_obliq;
    }

};

struct EyeMusclePaths 
{
    vector<Point3D> paths[6];
};

struct EyeMuscleActivations
{
    union
    {
        double act[6];
        struct
        {
            double act_med_rect;
            double act_lat_rect;
            double act_inf_rect;
            double act_sup_rect;
            double act_sup_obliq;
            double act_inf_obliq;
        };
    };
};

struct Saccade
{
    // [IN] Desired rotations (from, to)
    double rotFrom[3], rotTo[3];

    // [OUT] Simulation results - trajectory
    vector<double> times, rotx, roty, rotz, vel;
    vector<EyeMusclePaths> paths;
  
    // [OUT/IN] Muscle activations
    vector<EyeMuscleActivations> activations;
    vector<double> timesAct;
};

struct SaccadeController
{
    /**
     * Called before every simulation step.
     * You get the current state of the simulation.
     * You can edit the activation.
     * @param time        [IN]  Elapsed time of simulation.
     * @param angles      [IN]  Vector with eyeball angles. (Euler X-Y-Z)
     * @param speeds      [IN]  Vector with eyeball angles' rate of change.
     * @param activations [OUT] Updatable vector of the 6 activations.
     */
    virtual void control (const double time,
        const double rotX,  const double rotY,  const double rotZ,
        const double rotXu, const double rotYu, const double rotZu,
        EyeMuscleActivations &activations) = 0;
};

class ConstActSaccadeController : public SaccadeController
{
    EyeMuscleActivations acts;

public:
  ConstActSaccadeController()
  {
    for (int i = 0; i < 6; i++)
      acts.act[i] = 0;
  }
    void control(const double time,
        const double rotX, const double rotY, const double rotZ,
        const double rotXu, const double rotYu, const double rotZu,
        EyeMuscleActivations &activations)
    {
        activations = acts;
    }

    void setActivation (int mi, double a) { acts.act[mi] = a; }

    void setActivations (EyeMuscleActivations &acts_) { acts = acts_; }

    void getActivations(EyeMuscleActivations &acts_) {acts_ = acts;}
};

class saccsim_API SaccadeSimulator
{
public:
    SaccadeSimulator(Eye &eyeParams, bool left, string resDir);
    ~SaccadeSimulator();

    void simulate(Saccade &saccade, bool store, SaccadeController *controller=NULL);
    void simulate4Brahms(Saccade &saccade, bool store, SaccadeController *controller,
                         double timestep, string integrator_name, double duration);
    void inverseSimulate(Saccade &saccade, string name);

    SaccadeController* getController();

    void loadSaccadeFromFile(Saccade &saccade, const std::string &filename_prefix);

private:
    struct SaccadeSimulatorImpl;
    SaccadeSimulatorImpl *impl;
};

} // End of namespace notremor

#endif // SACCADESIMULATOR_H
