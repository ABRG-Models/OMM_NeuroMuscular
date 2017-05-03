/*
 * A C++ Brahms component for the Oculomotor model - this one computes
 * a centroid.
 *
 * Author: Seb James.
 * Date: March 2015.
 */

#define COMPONENT_CLASS_STRING "dev/NoTremor/centroid"
#define COMPONENT_CLASS_CPP dev_notremor_centroid_0
#define COMPONENT_RELEASE 0
#define COMPONENT_REVISION 1
#define COMPONENT_ADDITIONAL "Author=Seb James\n" "URL=Not supplied\n"
#define COMPONENT_FLAGS (F_NOT_RATE_CHANGER)

#define OVERLAY_QUICKSTART_PROCESS

#include <brahms-1199.h>
#include <iostream>
#include <math.h>
#include <vector>
#include <stdlib.h>

// Marsaglia and Tsang RNG algorithm (copied in from SpineML_2_BRAHMS,
// also found in brahms itself, but not in the form I prefer)
#include "rng.h"

#ifdef __WIN__
// Windows specific includes/apologies here.
#else
// Linux specific includes here.
#endif

namespace numeric = std_2009_data_numeric_0;
using namespace std;
using namespace brahms;

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
    Symbol event (Event* event);

private:

    /*!
     * Output port. Connects to a passthrough population in the model
     * "SC_output"
     */
    numeric::Output centroid;

    /*!
     * Input - this will be the input from the SC deep population.
     */
    //@{
    numeric::Input inputSheet;

    /*!
     * A sheet of neurons, most of which will be 0, one of which will
     * be the location of the centroid, with its height the
     * value. Memory allocated at startup and deallocated at shutdown.
     */
    double* outputstate;

    /*!
     * Number of neurons in a cortical sheet. Should be the square of
     * an integer.
     */
    int neuronsPerPopulation;

    /*!
     * How much scatter to apply to the centroid position.
     */
    double scatterAmplitude;

    /*!
     * Random number generator for the centroid position scatter
     */
    RngData rd;
};

/*!
 * This is the implementation of our component class's event method
 */
Symbol COMPONENT_CLASS_CPP::event(Event* event)
{
    switch (event->type) {

    case EVENT_STATE_SET: // Get state from the node's XML.
    {
        bout << "EVENT_STATE_SET." << D_INFO;
        // extract DataML
        EventStateSet* data = (EventStateSet*) event->data;
        XMLNode xmlNode(data->state);
        DataMLNode nodeState(&xmlNode);

        // The number of neurons per population in the OM model (2500 or 50x50)
        this->neuronsPerPopulation = nodeState.getField ("neuronsPerPopulation").getINT32();

        // How much scatter to apply to the centroid position. Can be 0
        this->scatterAmplitude = nodeState.getField ("scatterAmplitude").getDOUBLE();

        this->outputstate = (double*) calloc (this->neuronsPerPopulation, sizeof(double));

        // Initialise random number generator
        rngDataInit (&this->rd);
        zigset(&this->rd, 11);
        this->rd.seed = 107; // very important - DO set seed >0!

        return C_OK;
    }

    case EVENT_INIT_CONNECT:
    {
        bout << "EVENT_INIT_CONNECT." << D_INFO;

        if (event->flags & F_FIRST_CALL)
        {
            bout << "EVENT_INIT_CONNECT, F_FIRST_CALL." << D_INFO;

            this->centroid.setName("centroid");
            this->centroid.create(hComponent);
            this->centroid.setStructure(TYPE_DOUBLE | TYPE_REAL, Dims(this->neuronsPerPopulation).cdims());

            this->inputSheet.attach (hComponent, "inputSheet");
            this->inputSheet.validateStructure (TYPE_REAL|TYPE_DOUBLE, Dims(this->neuronsPerPopulation).cdims());
        }

        // on last call
        if (event->flags & F_LAST_CALL)
        {
            bout << "EVENT_INIT_CONNECT, F_LAST_CALL." << D_INFO;
            // Do anything that has to be done on the last call.
        }

        // ok, INIT_CONNECT event serviced.
        return C_OK;
    }

    case EVENT_INIT_POSTCONNECT:
    {
        return C_OK;
    }

    case EVENT_RUN_SERVICE:
    {
        // Read the input
        double* input = (double*)this->inputSheet.getContent();

        // Implement the centroid: sum (r_i.a_i) / sum (a_i)
        double r_dot_a_x = 0.0;
        double r_dot_a_y = 0.0;
        double sigma_a = 0.0;
        int i = 1;
        int x = 1;
        int y = 1;
        unsigned int sidelen = 50;
        while (i <= this->neuronsPerPopulation) {

            if (x>sidelen) { x = 1; ++y; }

            r_dot_a_x += (double)(*input) * (double)x;
            r_dot_a_y += (double)(*input) * (double)y;
            sigma_a += *input;

            ++i; ++x; ++input;
        }

        double x_scatter = this->scatterAmplitude * (double)_randomNormal ((&this->rd));
        double y_scatter = this->scatterAmplitude * (double)_randomNormal ((&this->rd));
        // Centroid based on x/y components of r.w plus any scatter:
        unsigned int centroid_i_x = round (r_dot_a_x / sigma_a + x_scatter);
        unsigned int centroid_i_y = round (r_dot_a_y / sigma_a + y_scatter);

        // Find the index of the centroid in 1x2500 form (rather than 50x50):
        unsigned int centroid_i = sidelen * centroid_i_y + centroid_i_x;

        // Write the output
        if (centroid_i >= 0 && centroid_i < this->neuronsPerPopulation) {
            // Any thresholding of the output of this could be done in
            // the SpineCreator "receiver" population, or here, if we
            // want to save computations.
            bout << "setting   outputstate[" << centroid_i << "] to sigma_a = " << sigma_a << D_INFO;
            outputstate[centroid_i] = sigma_a;
        }
        this->centroid.setContent (outputstate, 0, this->neuronsPerPopulation * sizeof(DOUBLE));
        // Reset to 0 for next timestep.
        outputstate[centroid_i] = 0;

        // ok, RUN_SERVICE event serviced.
        return C_OK;
    }

    case EVENT_RUN_STOP:
    {
        bout << "EVENT_RUN_STOP" << D_INFO;
        // Do any cleanup necessary here.
        free (this->outputstate);
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
