#ifndef FORCEUPDATER_H
#define FORCEUPDATER_H

#include <string>
#include <OpenSim/OpenSim.h>
#include <OpenSim/Common/Function.h>
#include <OpenSim/Common/FunctionSet.h>

using namespace std;
using namespace SimTK;
using namespace OpenSim;

class ForceUpdater : public ScheduledEventHandler
{
    const MultibodySystem               &m_system;
    const Array_<Vector>                &m_force_traj;
    const Array_<Real>                  &m_times;
    const SimTK::Force::DiscreteForces* m_df;

public:
    ForceUpdater(const MultibodySystem &system, const Array_<Real> &times,
        const Array_<Vector> &forceTraj, const SimTK::Force::DiscreteForces *df) :
        m_system(system),
        m_force_traj(forceTraj),
        m_times(times),
        m_df(df)
    {

    }

    int findTimeIndex(const Real t) const {
        unsigned i = 0;
        while (i < m_times.size() && m_times[i] < t) i++;
        return i < m_times.size() ? i : -1;
    }

    virtual Real getNextEventTime(const State &s, bool includeCurrentTime) const {
        Real t = s.getTime();
        unsigned i = findTimeIndex(s.getTime());
        if (i >= 0 && i <= m_times.size() - (includeCurrentTime ? 1 : 2))
            return m_times[i + (includeCurrentTime ? 0 : 1)];
        return -1;
    }

    virtual void handleEvent(State &s, Real accuracy, bool &shouldTerminate) const {
        unsigned i = findTimeIndex(s.getTime());

        if (i < 0 || i >= m_times.size() - 1)
            m_df->clearAllMobilityForces(s);
        else
            m_df->setAllMobilityForces(s, m_force_traj[i]);
    }
};

#endif
