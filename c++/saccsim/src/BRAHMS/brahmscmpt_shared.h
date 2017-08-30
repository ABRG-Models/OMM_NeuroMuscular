#ifndef _BRAHMSCMPT_SHARED_H_
#define _BRAHMSCMPT_SHARED_H_

#include <vector>
#include <deque>
#include <fstream>

#ifdef __WIN__
// Windows specific includes here.
# error "A windows threading solution is required (writeme)."
#else
// Linux specific includes here.
# include <pthread.h>
#endif

/*!
 * Here's the right place to say if we want to output rotations in the
 * component as a Brahms output (in any case, the rotations will be
 * saved out into a file).
 */
#define WANT_COMPONENT_TO_OUTPUT_ROTATIONS 1

/*!
 * These are the indexes into the vectors in brahmsSide and
 * saccsimSide.
 */
//@{
#define STEP_TIME   0 // BRAHMS simulation time
#define ACT_MEDRECT 1
#define ACT_LATRECT 2
#define ACT_INFRECT 3
#define ACT_SUPRECT 4
#define ACT_SUPOBL  5
#define ACT_INFOBL  6
#define ROT_X       7
#define ROT_Y       8
#define ROT_Z       9
#define ROT_XU      10
#define ROT_YU      11
#define ROT_ZU      12
#define SACCSIM_TIME 13 // Saccsim simulation time
#define SIM_DATA_SZ 14
#define FIRST_ACT   ACT_MEDRECT
#define LAST_ACT    ACT_INFOBL
#define FIRST_ROT   ROT_X
#define LAST_ROT    ROT_ZU
//@}

/*!
 * Gain for the activations. Input signal from saccade generator is
 * normalised and multiplied by this number.
 */
#define ACT_GAIN 1

/*!
 * A radians to degrees conversion factor: 360/2pi
 */
#define RADIANS_TO_DEGREES 57.295779513

/*!
 * A Singleton class to contain the variables shared between the
 * Brahms component and the Saccade simulator.
 *
 * Note that most data elements are public, to simplify the coding.
 */
class Variables
{
public:
    static Variables* getInstance();

    ~Variables() { this->instanceFlag = false; }

    /*!
     * Data on the brahms side, map with index the brahms time(step)
     * The vector of doubles has 12 elements. 0-5 are the input
     * activations. 6-11 are the interpolated output rotations.
     */
    std::deque<std::vector<double> > brahmsSide;

    /*!
     * The current brahms data time index
     */
    std::deque<std::vector<double> >::reverse_iterator brahmsCurrData;

    /*!
     * The last brahms activations data set we worked on on the
     * saccsim side. Used to make sure we don't continuously process
     * the same activations over and over again.
     */
    std::deque<std::vector<double> >::reverse_iterator brahmsLastData;

    /*!
     * Data on the saccsim side, map with index the saccsim time(step)
     * The vector of doubles should have 12 elements. 0-5 are the
     * interpolated input activations. 6-11 are the output rotations.
     */
    std::deque<std::vector<double> > saccsimSide;

#ifdef WANT_COMPONENT_TO_OUTPUT_ROTATIONS // This only used if outputting rotations.
    /*!
     * The last saccsim data time index we worked with on the brahms
     * side. This is set on the brahms side when the rotations
     * in saccsimCurrData have been copied into brahmsCurrData.
     */
    std::deque<std::vector<double> >::reverse_iterator saccsimLastData;
#endif

    /*!
     * Saccsim sets this to the current time for the rotations it just recorded
     */
    std::deque<std::vector<double> >::reverse_iterator saccsimCurrData;

    /*!
     * Controls access to the saccsim side data.
     */
    pthread_mutex_t saccsimSideMutex;

    /*!
     * Controls access to the brahms-side data - the inputs to
     * saccsim.
     */
    pthread_mutex_t brahmsSideMutex;

    /*!
     * An fstream into which the brahms table can be written.
     */
    std::ofstream fbrahms;

    /*!
     * An fstream for the saccsim results data.
     */
    std::ofstream fsaccsim;

    /*!
     * How long we need the saccsim simulator to run for.
     */
    double duration;

    /*!
     * The fixed timestep size in use in the wrapping brahms component.
     */
    double timestep_size;

    /*!
     * Fill with a string to say which SimTk::Integrator to use. Valid
     * values: ExplicitEuler, RungeKuttaMerson, RungeKuttaFeldberg or
     * RungeKutta3. If empty, default to RungeKuttaMerson. If
     * ExplicitEuler is selected, then the fixed timestep,
     * timestep_size is used. AFAICT, E.Euler is the only integrator
     * which accepts a fixed timestep, but I'm not sure of this.
     */
    std::string simtk_integrator;

    /*!
     * Getter for state of saccsimStarted.
     */
    bool getSaccsimStarted (void);

    /*!
     * Setter for state of saccsimStarted
     */
    void setSaccsimStarted (const bool& b);

    /*!
     * Getter for state of brahmsFinished.
     */
    bool getBrahmsFinished (void);

    /*!
     * Setter for state of brahmsFinished.
     */
    void setBrahmsFinished (const bool& b);

    /*!
     * Set up brahmsCurrData etc here.
     */
    void initData (void);

private:
    Variables(){} // private constructor
    // Sets to true once instanciated
    static bool instanceFlag;
    // Set to true once saccsim thread has started and is running.
    static bool saccsimStarted;
    // Set to true once the brahms execution has finished.
    static bool brahmsFinished;
    // The single instance pointer of this class
    static Variables* single;
public:
    // A header line for csv output data files
    static std::string bss_data_header;
};

#endif // _BRAHMSCMPT_SHARED_H_
