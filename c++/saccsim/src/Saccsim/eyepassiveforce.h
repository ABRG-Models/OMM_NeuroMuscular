#ifndef EYEPASSIVEFORCE_H
#define EYEPASSIVEFORCE_H

#include <OpenSim/Simulation/Model/Force.h>
#include <OpenSim/Simulation/Model/Model.h>
#include <OpenSim/Simulation/Model/BodySet.h>

//#include "osimPluginDLL.h"

namespace OpenSim {

class EyePassiveForce : public OpenSim::Force {
OpenSim_DECLARE_CONCRETE_OBJECT(EyePassiveForce, Force)
    
    OpenSim_DECLARE_PROPERTY(stiffness, double, "Stiffnes of the passive force")
    OpenSim_DECLARE_PROPERTY(viscosity, double, "Viscosity of the passive force")

    void constructProperties();

public:
    EyePassiveForce();
    EyePassiveForce(double stiffness, double viscosity);

    double getStiffness() const { return get_stiffness(); }
    void setStiffness(double aStiffness) { set_stiffness(aStiffness); }

    double getViscosity() const { return get_viscosity(); }
    void setViscosity(double aViscosity) { set_viscosity(aViscosity); }

    void computeForce(const SimTK::State& state,
        SimTK::Vector_<SimTK::SpatialVec>& bodyForces,
        SimTK::Vector& generalizedForces) const OVERRIDE_11;
};

}

#endif
