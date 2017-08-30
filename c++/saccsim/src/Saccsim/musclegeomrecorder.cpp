#include "musclegeomrecorder.h"

#include <OpenSim/OpenSim.h>
#include "osimutils.h"

using namespace OpenSim;
using namespace SimTK;
using namespace std;
using namespace notremor;

MuscleGeomRecorder::MuscleGeomRecorder() {}

MuscleGeomRecorder::MuscleGeomRecorder(Model *model) : Analysis(model) 
{

}

int MuscleGeomRecorder::step(const SimTK::State& s, int stepNumber)
{
    if(!proceed(stepNumber)) return 0;
    record(s);
    return 0;
}

int MuscleGeomRecorder::record(const SimTK::State& s)
{
    _model->getMultibodySystem().realize(s, SimTK::Stage::Dynamics);

    const SimbodyMatterSubsystem& matter = _model->getMatterSubsystem();

    const ForceSet &fs = _model->getForceSet();

    musclePaths.resize(musclePaths.size() + 1);

    int i_eye_m=0;

    for (int i_m=0; i_m < fs.getSize(); i_m++) {
        PathActuator *m = dynamic_cast<PathActuator*>(&fs.get(i_m));
        if (!m) continue;

        const GeometryPath &geom_path = m->getGeometryPath();
        const Array<PathPoint*> &path = geom_path.getCurrentPath(s);

        for (int i_p=0; i_p < path.getSize(); i_p++) {
            MobilizedBodyIndex body_i = path.get(i_p)->getBody().getIndex();
            Vec3 pos_local = path.get(i_p)->getLocation();
            Vec3 pos_glob = matter.getMobilizedBody(body_i).getBodyTransform(s)*pos_local;
            Point3D p(pos_glob[0], pos_glob[1], pos_glob[2]);
            musclePaths.back().paths[i_eye_m].push_back(p);
        }

        i_eye_m++;
    }

    return 0;
}
