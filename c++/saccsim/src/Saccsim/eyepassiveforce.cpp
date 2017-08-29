#include "eyepassiveforce.h"
#include <OpenSim/Common/PropertyDbl.h>
#include <iostream>

OpenSim::EyePassiveForce::EyePassiveForce()
{
    constructProperties();
}

OpenSim::EyePassiveForce::EyePassiveForce(double stiffness, double viscosity)
{
    constructProperties();
    setStiffness(stiffness);
    setViscosity(viscosity);
}

void OpenSim::EyePassiveForce::constructProperties()
{
    setName("EyePassiveForce");
    setAuthors("Chris Papapavlou");
    constructProperty_stiffness(0);
    constructProperty_viscosity(0);
}

void OpenSim::EyePassiveForce::computeForce(const SimTK::State& state,
    SimTK::Vector_<SimTK::SpatialVec>& bodyForces,
    SimTK::Vector& generalizedForces) const
{
    double K = getStiffness();
    double C = getViscosity();
    SimTK::Vec3 R(state.getQ()[0], state.getQ()[1], state.getQ()[2]);
    SimTK::Vec3 U(state.getU()[0], state.getU()[1], state.getU()[2]);
    
    SimTK::Vec3 torque = -K*R -C*U;

    applyTorque(state, getModel().getBodySet().get("Eye"), torque, bodyForces);
}
