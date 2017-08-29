#include "saccadesimulator.h"
#include "saccadesimulatorimpl.h"

using namespace std;

SaccadeSimulator::SaccadeSimulator (Eye &eyeParams, bool left, string resultDir)
{
    impl = new SaccadeSimulatorImpl(eyeParams, left, resultDir);
}

SaccadeSimulator::~SaccadeSimulator()
{
    delete impl;
}

void SaccadeSimulator::simulate4Brahms (Saccade &saccade, bool store, SaccadeController *controller, double timestep, string integrator_name, double duration)
{
    impl->simulate4Brahms(saccade, store, controller, timestep, integrator_name, duration);
}

void SaccadeSimulator::simulate (Saccade &saccade, bool store, SaccadeController *controller)
{
    impl->simulate(saccade, store, controller);
}

void SaccadeSimulator::inverseSimulate (Saccade &saccade, string name)
{
    impl->inverseSimulate(saccade, name);
}

SaccadeController* SaccadeSimulator::getController()
{
    return impl->getController();
}

void SaccadeSimulator::loadSaccadeFromFile(Saccade &saccade, const string &filename_prefix)
{
    impl->loadSaccadeFromFile(saccade, filename_prefix);
}
