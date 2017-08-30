/*
 * BRAHMS process for University of Patras Saccade Simulator/NoTremor project
 * Author: Seb James <seb.james@sheffield.ac.uk> 2014.
 * Node name: saccsim
 */

#include "brahmscmpt_shared.h"

#define COMPONENT_CLASS_STRING "dev/NoTremor/saccsim"
#define COMPONENT_CLASS_CPP dev_notremor_saccsim_0
#define COMPONENT_RELEASE 0
#define COMPONENT_REVISION 1
#define COMPONENT_ADDITIONAL "Author=Seb James\n" "URL=Not supplied\n"
#define COMPONENT_FLAGS 0 // Allowed to join to component with diff rate.

#define OVERLAY_QUICKSTART_PROCESS

#include <brahms-1199.h>

#include <iostream>

// Saccsim includes:
#include "saccadesimulator.h"
#include "brahmssaccadecontroller.h"
#include "utils.h"
#include "settings.h"

#ifdef __WIN__
// Windows specific includes here.
# error "A windows threading solution is required (writeme)."
# error "A windows usleep-like solution is required (writeme)."
# error "A windows errno-like solution is required (writeme)."
#else
// Linux specific includes here.
# include <pthread.h>
# include <unistd.h>
# include <errno.h>
#endif

namespace numeric = std_2009_data_numeric_0;
using namespace std;
using namespace brahms;
using namespace notremor;
using namespace vvr;

//*******************************************************************
// globals. See BRAHMS/CMakeLists.txt for these definitions.
const string configFile (__CONF__);
const string baseDir (__BASE_DIR__);
//*******************************************************************

/*
 * If you want the component to output rotations *to another brahms
 * component* then you probably want to define
 * WANT_COMPONENT_TO_OUTPUT_ROTATIONS. This will then pull the output
 * from the saccsim simulator over to the brahms side and send an
 * output number on each Brahms timestep. However, there are inherent
 * race conditions possible with this approach, because of saccsim's
 * variable timestep integration and so it's much easier if we simply
 * output saccsim's rotation outputs directly to a file.
 *
 * NB: #define WANT_COMPONENT_TO_OUTPUT_ROTATIONS in
 * brahmscmpt_shared.h
 */
#ifdef WANT_COMPONENT_TO_OUTPUT_ROTATIONS
# define NUM_ROTATIONS 6
# define NUM_ACTIVATIONS 6 // For 6 muscles in the eye
#endif

/*!
 * A global debug stream, used only by the Saccade simulator code.
 */
std::ofstream DBGSTREAM;

/*!
 * #defines for some true/false arguments for clarity.
 */
//@
#define NO_STORE false         // false for "don't store data" in SaccadeSimulatorImpl::simulate call
#define DO_STORE true          // true for "do store data"
#define LEFT_EYE_TRUE true     // true for "do simulate left eye" in SaccadeSimulatorImpl::simulate call
#define LEFT_EYE_FALSE false   // false for "don't simulate left"
#define RIGHT_EYE_TRUE true
#define RIGHT_EYE_FALSE false
//@}

//function prototypes
void loadEyeParams(Eye &eyeParams, const Settings &conf);

/*!
 * The Saccade Simulator thread code. This is somewhat equivalent to
 * the code found in saccsimgui.cpp, and indeed was copied and
 * modified from there.
 */
void* saccsimThreadCode (void* dummy)
{
    cout << "SS saccsimThreadCode called." << endl;

    // Open the Saccsim debug file (as we can't use bout here).
    //SSDBGOPEN ("/tmp/ss.log");

    // A pointer to our singleton Variables object.
    Variables* vars;
    vars = Variables::getInstance();

    // Load settings.
    cout << "SS set up configFile." << endl;
    cout << "SS Got configFile path: " << configFile << endl;
    const Settings conf(configFile);

    cout << "SS Created Settings object." << endl;

    // Create eye param object.
    Eye eyeParams;
    loadEyeParams(eyeParams, conf);

    string resultDir = baseDir + conf.getStr("result_dir");

    // Read initial conditions and construct saccade object
    // (This is redundant when we're driving with activations)
    Saccade saccade;
    // saccade.rotFrom = (0,10,0) or something like this.

    // Perform simulation
    cout << "SS instantiate saccadeSimulator." << endl;
    BrahmsSaccadeController* controller = new BrahmsSaccadeController();
    SaccadeSimulator saccadeSimulator(eyeParams, LEFT_EYE_TRUE, resultDir);
    cout << "SS saccadeSimulator.simulate..." << endl;
    // State that this thread has started:
    vars->setSaccsimStarted (true);
    cout << "SS getSaccsimStarted: " << vars->getSaccsimStarted() << endl;
    cout << "SS call saccadeSimulator.simulate..." << endl;
    saccadeSimulator.simulate4Brahms (saccade, DO_STORE, controller, vars->timestep_size, vars->simtk_integrator, vars->duration);
    cout << "SS saccadeSimulator.simulate finished." << endl;

    //SSDBGCLOSE();
    cout << "SS returning" << endl;
    return NULL;
}

/**
 * Loads eye parameters from config file
 *
 * @brief loadEyeParams
 * @param eyeParams
 * @param conf
 */
/**
 * Populate `Eye` object from configuration file
 */
void loadEyeParams(Eye &eyeParams, const vvr::Settings &conf)
{
    // Basic Params
    eyeParams.R = conf.getDbl("eye_radius");
    eyeParams.mass = conf.getDbl("eye_mass");
    eyeParams.range = conf.getDbl("eye_range");
    eyeParams.eyesDist = conf.getDbl("eye_dist");

    // Muscle Force Params
    eyeParams.med_rect.maxForce = conf.getDbl("force_med_rect");
    eyeParams.lat_rect.maxForce = conf.getDbl("force_lat_rect");
    eyeParams.inf_rect.maxForce = conf.getDbl("force_inf_rect");
    eyeParams.sup_rect.maxForce = conf.getDbl("force_sup_rect");
    eyeParams.sup_obliq.maxForce = conf.getDbl("force_sup_obl");
    eyeParams.inf_obliq.maxForce = conf.getDbl("force_inf_obl");

    // Muscle Length Params
    eyeParams.med_rect.optimalFiberLength = conf.getDbl("optimal_fiber_length");
    eyeParams.lat_rect.optimalFiberLength = conf.getDbl("optimal_fiber_length");
    eyeParams.inf_rect.optimalFiberLength = conf.getDbl("optimal_fiber_length");
    eyeParams.sup_rect.optimalFiberLength = conf.getDbl("optimal_fiber_length");
    eyeParams.sup_obliq.optimalFiberLength = conf.getDbl("optimal_fiber_length");
    eyeParams.inf_obliq.optimalFiberLength = conf.getDbl("optimal_fiber_length");

    // Passive Params
    eyeParams.passiveStiffness = conf.getDbl("stiffness");
    eyeParams.passiveViscosity = conf.getDbl("viscosity");
}

/*!
 * This is our Brahms component class declaration.
 */
class COMPONENT_CLASS_CPP : public Process
{
public:
    COMPONENT_CLASS_CPP() {}
    ~COMPONENT_CLASS_CPP() {}

    /*!
     * The framework event function
     */
    Symbol event(Event* event);

private:

#ifdef WANT_COMPONENT_TO_OUTPUT_ROTATIONS
    /*!
     * Check saccsim data in Variables::saccsimSide to see if there
     * are any rotations present which can be transferred to the
     * brahms component output.
     *
     * Return true if there are suitable rotations present (for the
     * current timestep), false otherwise.
     */
    bool checkForRotations (void);

    /*!
     * If the rotations in vars->saccsimCurData are from an earlier
     * time than the data in brahmsCurrData, copy the rotations into
     * brahmsCurrData and update vars->saccsimLastData.
     *
     * If we get into a deadlock where the saccsim side is waiting on
     * an activation, but the brahms side is waiting on a rotation
     * from the saccsim side before being able to supply the
     * activation, then we copy the "closest" later rotation data from
     * teh saccsim side into the brahms side. This will be the
     * rotation data out of the brahms component. The more accurate
     * data will come from the file output from the saccsim model.
     *
     * All this complication could be avoided if we passed the
     * activations over to the saccsim model independently of trying
     * to obtain rotation outputs, but the point of this exercise is
     * to integrate the saccsim model, as it stands, into the Brahms
     * model.
     */
    bool copyRotationsIf (void);

    /*!
     * Sub-called by copyRotationsIf(). Copy the rotations in the data
     * "line" pointed to by iter into this->vars->brahmsCurrData.
     */
    void copyRotationsAt (std::deque<std::vector<double> >::reverse_iterator& iter);

    /*!
     * Output port(s). rotationsOut is 6 rotations:
     * rotX,rotY,rotZ,rotXu,rotYu,rotZu. See saccsim for descriptions
     * of what these are. These are the rotations for one eye, we'll
     * add a parameter to this component to say which eye it should
     * model (i.e. which simulation to choose from saccsim).
     */
    numeric::Output rotationsOut;

#endif // WANT_COMPONENT_TO_OUTPUT_ROTATIONS

    /*!
     * Open the file stream f using the passed in path. Throw berr
     * exception on failure.
     */
    void openFile (const std::string& path, std::ofstream& f);

    /*!
     * Input ports. see brahms-x.x.x/components/std.h/data_numeric.h
     * for the declaration of the struct Input.
     */
    //@{
    numeric::Input actSupRect;
    numeric::Input actInfRect;
    numeric::Input actMedRect;
    numeric::Input actLatRect;
    numeric::Input actSupObl;
    numeric::Input actInfObl;
    //@}

    /*!
     * Put pointers to rotations/activiations input/output data
     * objects and their mutexes are in a singleton Variables
     * object. Wanted ideally to place numeric::Input and
     * numeric::Outputs into this, but the #including was too
     * spaghetti-like and I didn't want to have to modify the Brahms
     * code.
     */
    Variables* vars;

    /*!
     * We run the Saccade Simulator in a thread, as it is designed to
     * run continuously, calling a control method at each of its
     * (variable) timesteps. This is the thread it'll run in.
     */
    pthread_t saccsimThread;

    /*!
     * The current fixed, BRAHMS timestep. This is obtained at
     * runtime, as it is defined in the BRAHMS system xml file.
     */
    float dt;

    /*!
     * One line of the brahms data table. This is a temporary
     * variable; it is populated, then pushed onto a deque in shared
     * memory (Variables::brahmsSide).
     */
    vector<double> brahmsdata;
};

#ifdef WANT_COMPONENT_TO_OUTPUT_ROTATIONS
void COMPONENT_CLASS_CPP::copyRotationsAt (std::deque<std::vector<double> >::reverse_iterator& iter)
{
    //bout << "CRA: Set rotations into brahmsdata." << D_INFO;

    // Then saccsim rotns can be copied into brahms table. (Could
    // use memcpy to be faster here).
    for (int j = FIRST_ROT; j<=LAST_ROT; ++j) {
        (*this->vars->brahmsCurrData)[j] = (*iter)[j];
    }

    // Make a record of the saccsim time for the rotations in the brahms data:
    (*this->vars->brahmsCurrData)[SACCSIM_TIME] = (*iter)[SACCSIM_TIME];

    // Record that we took the rotations into brahmsCurrData:
    this->vars->saccsimLastData = iter;
}

bool COMPONENT_CLASS_CPP::copyRotationsIf (void)
{
    bool rtn (false);

    pthread_mutex_lock (&this->vars->brahmsSideMutex);

#ifdef DEBUG___
    if (this->vars->brahmsCurrData != this->vars->brahmsSide.rend()) {
        bout << "CRI: Considering saccsimCurrData[SACCSIM_TIME]="
             << (*this->vars->saccsimCurrData)[SACCSIM_TIME]
             << " vs. brahmsCurrData[STEP_TIME]=" << (*this->vars->brahmsCurrData)[STEP_TIME]
             << D_INFO;
    }
#endif

    // delta is +ve if saccsim time is later than brahms time, -ve if earlier than brahms.
    double delta = -100000.0;
    if (this->vars->brahmsCurrData != this->vars->brahmsSide.rend()) {
        delta = (*this->vars->saccsimCurrData)[SACCSIM_TIME] - (*this->vars->brahmsCurrData)[STEP_TIME];
    } else {
        // There's no brahmsCurrData.
        pthread_mutex_unlock (&this->vars->brahmsSideMutex);
        return rtn;
    }

    if (delta >= 0.0) { // +ve delta, saccsim time later than brahms time.

        //bout << "CRI: saccsimCurrData is later than brahmsCurrData." << D_INFO;
        std::deque<std::vector<double> >::reverse_iterator sd = this->vars->saccsimCurrData;

        //bout << "CRI: Step back through saccsimCurrData in case there's a better match." << D_INFO;
        while (sd != this->vars->saccsimSide.rend() /* && (*sd)[STEP_TIME] > time */) {
            if ((*sd)[SACCSIM_TIME] >= (*this->vars->brahmsCurrData)[STEP_TIME]) {
                // continue stepping back.
            } else {
                // The saccsim time is now earlier than the brahms time, so step forward again.
                if (sd != this->vars->saccsimCurrData) {
                    //bout << "CRI: Step forward once to get back to the best, later time." << D_INFO;
                    --sd;
                }
                break;
            }
            ++sd;
        }

        // If saccsimCurrData was later than brahms step time and it
        // was the only member of saccsimSide, then we'll have stepped
        // back off the rend of saccsimSide, so step back:
        if (sd == this->vars->saccsimSide.rend()) {
            --sd;
        }

        if (sd == this->vars->saccsimSide.rend()) {
            berr << "CRI: sd == saccsimSide.rend().";
        }

        this->copyRotationsAt (sd);
        rtn = true;

    } else if (delta < 0.0 && delta > -1*this->dt) {

        // saccsimCurrTime is earlier than brahmsCurrTime by less than
        // a brahms timestep, so we can add these rotations
        // anyway, as the "best rotations" for the Brahms timestep of
        // interest, even though at a later saccsim timestep, there
        // may be better-fitting rotations for this timestep.

#ifdef DEBUG__
        bout << "CRI: Adding rotations for brahms t ("
             << (*this->vars->brahmsCurrData)[STEP_TIME] << ") although later than saccsim t ("
             << (*this->vars->saccsimCurrData)[SACCSIM_TIME] << ")." << D_INFO;
#endif
        this->copyRotationsAt (this->vars->saccsimCurrData);
        rtn = true;
#ifdef DEBUG__
    } else {
        bout << "CRI: NOT adding rotations for brahms t ("
             << (*this->vars->brahmsCurrData)[STEP_TIME] << ") - too much later than saccsim t ("
             << (*this->vars->saccsimCurrData)[SACCSIM_TIME] << ")." << D_INFO;
#endif
    }

    pthread_mutex_unlock (&this->vars->brahmsSideMutex);

    return rtn;
}

bool COMPONENT_CLASS_CPP::checkForRotations (void)
{
    bool rtn (false);
    pthread_mutex_lock (&this->vars->saccsimSideMutex);

    if (this->vars->saccsimCurrData != this->vars->saccsimSide.rend()) {

        //bout << "checkForRotations: We have at least one data row on saccsim side" << D_INFO;

        if (this->vars->saccsimLastData != this->vars->saccsimSide.rend()
            &&
            (*this->vars->saccsimCurrData)[SACCSIM_TIME] > (*this->vars->saccsimLastData)[SACCSIM_TIME]
            ) {

            // Then the saccsim simulator has moved on a step, so we
            // need to test if the saccsim time is later than or
            // similar to the current brahms step time.
            rtn = this->copyRotationsIf();

        } else if (this->vars->saccsimLastData != this->vars->saccsimSide.rend()
            &&
            (*this->vars->saccsimCurrData)[SACCSIM_TIME] <= (*this->vars->saccsimLastData)[SACCSIM_TIME]
            ) {

//            bout << "checkForRotations: Current saccsim rotation data for saccsim time "
//                 << (*this->vars->saccsimCurrData)[SACCSIM_TIME]
//                 << " is earlier than or at the same time as last data ("
//                 << (*this->vars->saccsimLastData)[SACCSIM_TIME] << ")" << D_INFO;

        } else if (this->vars->saccsimLastData == this->vars->saccsimSide.rend()) {
            // We have CurrData, but not LastData. Curr data is:
            bout << "checkForRotations: We have current saccsim rotation data for saccsim time "
                 << (*this->vars->saccsimCurrData)[SACCSIM_TIME] << D_INFO;
            rtn = this->copyRotationsIf();

        } else {
            berr << "checkForRotations: Unexpected state.";
        }

    } else {
        // We have neither CurrData nor LastData.
        bout << "checkForRotations: We have neither CurrData nor LastData at this time." << D_INFO;
    }
    pthread_mutex_unlock (&this->vars->saccsimSideMutex);

    //bout << "checkForRotations: return: "
    //     << (rtn ? "got rotations":"NOT got rotations") << D_INFO;
    return rtn;
}
#endif

void COMPONENT_CLASS_CPP::openFile (const std::string& path, std::ofstream& f)
{
    f.open (path.c_str(), ios::out|ios::trunc);
    if (!f.is_open()) {
        berr << "Failed to open " << path;
    }
    f << this->vars->bss_data_header << endl;
}

/*!
 * This is the implementation of our component class's event method
 */
Symbol COMPONENT_CLASS_CPP::event(Event* event)
{
    // Could do with a macro to show what event is caught:
    //bout << "Brahms event caught: " << event->type << D_INFO;

    switch (event->type) {

    case EVENT_STATE_SET: // Get state from the node's XML.
    {
        bout << "EVENT_STATE_SET." << D_INFO;
        // extract DataML
        EventStateSet* data = (EventStateSet*) event->data;
        XMLNode xmlNode(data->state);
        DataMLNode nodeState(&xmlNode);

        /*
         * Here, we obtain the parameters from the Brahms
         * configuration file, in which parameters are encoded in
         * "DataML". You can test if a field is available:
         *  if (nodeState.hasField("host")) { }
         *
         * State XML looks like this (from sys.xml):
         *
         * <State c="z" a="port;type;host;skip;name;logAll;logfileNameForComponent;"
         *      Format="DataML" Version="5"
         *      AuthTool="SpineML to BRAHMS XSLT translator" AuthToolVersion="0">
         *   <m c="f">50091</m>
         *   <m c="f">0</m>
         *   <m>127.0.0.1</m>
         *   <m c="f">0</m>
         *   <m>netout</m>
         *   <m b="1" c="f">1</m>
         *   <m>Population</m>
         * </State>
         *
         * size = nodeState.getField("size").getINT32(); // also .getSTRING(), .getDOUBLE() are available
         *
         */

        // Initialise our pointer to the singleton variables instance.
        this->vars = Variables::getInstance();

        // Our brahmsdata container needs 12 spaces (1 time, 6 acts, 6 rotns).
        this->brahmsdata.resize(SIM_DATA_SZ);
        this->brahmsdata.assign(SIM_DATA_SZ, 0.0);
#ifdef NEED_SS_DATA_HERE
        this->saccsimdata.resize(SIM_DATA_SZ);
        this->saccsimdata.assign(SIM_DATA_SZ, 0.0);
#endif
        this->vars->initData();

        // Get size of our fixed timestep IN SECONDS (to match saccsim time)
        this->dt = static_cast<float> (this->time->sampleRate.den) / static_cast<float> (this->time->sampleRate.num);

        // The path for storing the output data csv.
        string bsd = nodeState.getField ("output_data_path").getSTRING() + "/brahms_side.log";
        string ssd = nodeState.getField ("output_data_path").getSTRING() + "/saccsim_side.log";

        // Which integrator to use?
        this->vars->simtk_integrator = nodeState.getField ("simtk_integrator").getSTRING();

        // Open filestreams (brahmsdata.log is not very useful)
        this->openFile (bsd, this->vars->fbrahms);
        this->openFile (ssd, this->vars->fsaccsim);

        return C_OK;
    }

    case EVENT_INIT_CONNECT:
    {
        bout << "EVENT_INIT_CONNECT." << D_INFO;

        if (event->flags & F_FIRST_CALL)
        {
            bout << "EVENT_INIT_CONNECT, F_FIRST_CALL." << D_INFO;

#ifdef WANT_COMPONENT_TO_OUTPUT_ROTATIONS
            this->rotationsOut.setName("out");
            this->rotationsOut.create(hComponent);
            this->rotationsOut.setStructure(TYPE_DOUBLE | TYPE_REAL, Dims(NUM_ACTIVATIONS).cdims());
#endif

            // Attaching the six inputs (NB! We're attaching the same input to each one here!)
            // How does system know to attach sup. rect input to this? Is it by order?
            if (this->actSupRect.tryAttach (hComponent, "suprect")) {
                bout << "attached the input for the Superior Rectus component." << D_INFO;
            } else {
                berr << "Failed to attach the input for the Superior Rectus component.";
            }
            // could validateStructure (TYPE_DOUBLE) here.
            if (this->actInfRect.tryAttach (hComponent, "infrect")) {
                bout << "attached the input for the Inferior Rectus component." << D_INFO;
            } else {
                berr << "Failed to attach the input for the Inferior Rectus component.";
            }
            if (this->actMedRect.tryAttach (hComponent, "medrect")) {
                bout << "attached the input for the Medial Rectus component." << D_INFO;
            } else {
                berr << "Failed to attach the input for the Medial Rectus component.";
            }
            if (this->actLatRect.tryAttach (hComponent, "latrect")) {
                bout << "attached the input for the Lateral Rectus component." << D_INFO;
            } else {
                berr << "Failed to attach the input for the Lateral Rectus component.";
            }
            if (this->actSupObl.tryAttach (hComponent, "supobl")) {
                bout << "attached the input for the Superior Oblique component." << D_INFO;
            } else {
                berr << "Failed to attach the input for the Superior Oblique component.";
            }
            if (this->actInfObl.tryAttach (hComponent, "infobl")) {
                bout << "attached the input for the Inferior Oblique component." << D_INFO;
            } else {
                berr << "Failed to attach the input for the Inferior Oblique component.";
            }
        }

        // on last call
        if (event->flags & F_LAST_CALL)
        {
            bout << "EVENT_INIT_CONNECT, F_LAST_CALL." << D_INFO;

            // Initialise our mutexes.
            pthread_mutex_init (&this->vars->brahmsSideMutex, NULL);
            pthread_mutex_init (&this->vars->saccsimSideMutex, NULL);

            // Can't create saccsim thread here, because we don't yet
            // have the execution duration (executionStop). See
            // EVENT_INIT_POSTCONNECT for saccsim thread startup.
        }

        // ok, INIT_CONNECT event serviced.
        return C_OK;
    }

    case EVENT_INIT_POSTCONNECT:
    {
        if (!this->vars->getSaccsimStarted()) {

#if DEBUG___
            bout << "this->time->sampleRate.den: " << this->time->sampleRate.den << D_INFO;
            bout << "this->time->sampleRate.num: " << this->time->sampleRate.num << D_INFO;
            bout << "this->time->baseSampleRate.den: " << this->time->baseSampleRate.den << D_INFO;
            bout << "this->time->baseSampleRate.num: " << this->time->baseSampleRate.num << D_INFO;
            bout << "this->time->executionStop: " << this->time->executionStop << D_INFO;
            bout << "this->time->samplePeriod: " << this->time->samplePeriod << D_INFO;
            bout << "this->time->now: " << this->time->now << D_INFO;
#endif
            // It's time to start saccsim. In this event, we have
            // access to executionStop, so set the duration:
            this->vars->duration = this->time->executionStop * this->dt;
            bout << "Simulation duration: " << this->vars->duration << D_INFO;
            // num: numerator, den: denominator
            this->vars->timestep_size = 1.0 / static_cast<double>(this->time->sampleRate.num * this->time->sampleRate.den);
            bout << "Simulation timestep: " << this->vars->timestep_size << D_INFO;

            bout << "Create saccsim thread..." << D_INFO;
            int rtn = pthread_create (&this->saccsimThread, NULL, &saccsimThreadCode, NULL);
            if (rtn < 0) {
                berr << "Failed to create thread for Saccade Simulator code.";
            } else {
                bout << "Saccade simulator thread created successfully" << D_INFO;
                while (this->vars->getSaccsimStarted() == false) {
                    usleep (100);
                }
                bout << "Saccade simulator code has started up!" << D_INFO;
            }
        }
        return C_OK;
    }

    case EVENT_RUN_SERVICE:
    {
        // current brahms simulation time
        this->brahmsdata[0] = float(this->time->now) * this->dt;
        //bout << "Brahms sim time: " << this->brahmsdata[0] << D_INFO;

        // 1. Read our input and record the pointers in the vars singleton.
        // Write this stuff into our internal data container.
        // Copy in activations (see brahmscmpt_shared.h for ACT_GAIN):
        try {
            this->brahmsdata[ACT_MEDRECT] = *((double*)this->actMedRect.getContent()) * ACT_GAIN;
            this->brahmsdata[ACT_LATRECT] = *((double*)this->actLatRect.getContent()) * ACT_GAIN;
            this->brahmsdata[ACT_INFRECT] = *((double*)this->actInfRect.getContent()) * ACT_GAIN;
            this->brahmsdata[ACT_SUPRECT] = *((double*)this->actSupRect.getContent()) * ACT_GAIN;
            this->brahmsdata[ACT_SUPOBL] = *((double*)this->actSupObl.getContent()) * ACT_GAIN;
            this->brahmsdata[ACT_INFOBL] = *((double*)this->actInfObl.getContent()) * ACT_GAIN;

        } catch (...) {
             bout << "No activations are available for this timestep" << D_INFO;

            // Note: This case occurs if the timestep for the saccsim
            // component is shorter/faster than the timestep for the
            // rest of the sim.

            // In this case, we copy the same activations we had in
            // the last step into the current step.
            if (this->vars->brahmsCurrData != this->vars->brahmsSide.rend()) {
                this->brahmsdata[ACT_MEDRECT] = (*this->vars->brahmsCurrData)[ACT_MEDRECT];
                this->brahmsdata[ACT_LATRECT] = (*this->vars->brahmsCurrData)[ACT_LATRECT];
                this->brahmsdata[ACT_INFRECT] = (*this->vars->brahmsCurrData)[ACT_INFRECT];
                this->brahmsdata[ACT_SUPRECT] = (*this->vars->brahmsCurrData)[ACT_SUPRECT];
                this->brahmsdata[ACT_SUPOBL] = (*this->vars->brahmsCurrData)[ACT_SUPOBL];
                this->brahmsdata[ACT_INFOBL] = (*this->vars->brahmsCurrData)[ACT_INFOBL];
            } else {
                // There's no data in brahmsSide yet.
                this->brahmsdata[ACT_MEDRECT] = 0;
                this->brahmsdata[ACT_LATRECT] = 0;
                this->brahmsdata[ACT_INFRECT] = 0;
                this->brahmsdata[ACT_SUPRECT] = 0;
                this->brahmsdata[ACT_SUPOBL] = 0;
                this->brahmsdata[ACT_INFOBL] = 0;
            }
        }

        // Write to brahmsSide now, to ensure that the activations go
        // into the brahmsSide data and are available for the saccsim
        // side.
        pthread_mutex_lock (&this->vars->brahmsSideMutex);
        this->vars->brahmsSide.push_back (this->brahmsdata);
        this->vars->brahmsCurrData = this->vars->brahmsSide.rbegin();
        pthread_mutex_unlock (&this->vars->brahmsSideMutex);

#ifdef WANT_COMPONENT_TO_OUTPUT_ROTATIONS
        // Get latest rotations, and see if these give us what we need for our rotations out.
        bool gotrot(false);
        while (!gotrot) {
            usleep (100);
            gotrot = this->checkForRotations();
        }

        // Assumes we got rotations; gotrot must be true to exit from the while loop above.
        this->rotationsOut.setContent(&((*this->vars->brahmsCurrData)[FIRST_ROT]),
                                      0, NUM_ROTATIONS * sizeof(DOUBLE));
#endif

        // Output to file
        this->vars->fbrahms << (*this->vars->brahmsCurrData)[0];
        for (int k = 1; k < SIM_DATA_SZ; ++k) {
            this->vars->fbrahms << "," << (*this->vars->brahmsCurrData)[k];
        }
        this->vars->fbrahms << endl;

        // ok, RUN_SERVICE event serviced.
        //bout << "RUN_SERVICE event serviced" << D_INFO;
        return C_OK;
    }

    case EVENT_RUN_STOP:
    {
        bout << "EVENT_RUN_STOP called - allow saccsim thread to join..." << D_INFO;
        this->vars->setBrahmsFinished (true);
        pthread_join (this->saccsimThread, NULL);
        bout << "saccsim thread joined!" << D_INFO;

        // Close data filestreams.
        this->vars->fbrahms.close();
        this->vars->fsaccsim.close();

        return C_OK;
    }

    } // switch (event->type)

    //	if we serviced the event, we returned C_OK if we didn't, we
    //	should return S_NULL to indicate this.
    return S_NULL;
}

// Here at the end, include the second part of the overlay (it knows
// you've included it once already).
#include "brahms-1199.h"
