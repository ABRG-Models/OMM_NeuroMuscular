/*
 * A C++ Brahms component for the Oculomotor model - this one computes
 * a power centroid.
 *
 * Author: Seb James.
 * Date: May 2015.
 */

#define COMPONENT_CLASS_STRING "dev/NoTremor/powercentroid"
#define COMPONENT_CLASS_CPP dev_notremor_powercentroid_0
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
#include <Eigen/Dense>

#ifdef __WIN__
// Windows specific includes/apologies here.
#else
// Linux specific includes here.
#endif

/*!
 * What power to use in the power centroid.
 */
#define POWER_DEGREE 2

/*!
 * Assume a square neural field. This is the side length. Make sure to
 * update all of these together.
 */
//@{
#define NFS         50
#define NFS_SQUARED 2500
#define NFS_MINUS_1 49
#define NFS_MINUS_2 48
//@}

namespace numeric = std_2009_data_numeric_0;
using namespace std;
using namespace brahms;
using namespace Eigen;

// Use a shorthand for unsigned int in this code file.
typedef unsigned int uint;

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
     * Apply the power centroid
     */
    void apply_centroid (double* input, double power_degree);

    /*!
     * Used in apply_centroid
     */
    //@{
    Array<double, NFS, NFS> X;
    Array<double, NFS, NFS> Y;
    double sigma_r_dot_a_x;
    double sigma_r_dot_a_y;
    double sigma_a;
    uint centroid_x;
    uint centroid_y;
    //@}
};

/*!
 * Eigen based method for centroiding.
 */
void
COMPONENT_CLASS_CPP::apply_centroid (double* input, double power_degree)
{
    // Wrap the output in an array, ready for output
    Map<Array<double, NFS, NFS> > the_centroid((double*)this->centroid.getContent(),NFS,NFS);
    // Zero out the result of the last timestep:
    the_centroid.setZero();

    // Get input as an array without copying the data:
    Map<Array<double, NFS, NFS> > sheet(input,NFS,NFS);

    sigma_r_dot_a_x = (this->X*sheet).pow(power_degree).sum();
    sigma_r_dot_a_y = (this->Y*sheet).pow(power_degree).sum();
    sigma_a = sheet.pow(power_degree).sum();
    centroid_x = (uint)round(pow(sigma_r_dot_a_x/sigma_a, 1.0/power_degree));
    centroid_y = (uint)round(pow(sigma_r_dot_a_y/sigma_a, 1.0/power_degree));
    // Decrement ops here as Eigen arrays count from 0.
    the_centroid (--centroid_x, --centroid_y) = sigma_a;

#ifdef DEBUG_MAPS
    ofstream f;
    stringstream fname;
    fname << "powercentroid" << this->time->now << ".dat";
    f.open (fname.str().c_str(), ios::out|ios::trunc);
    f << the_centroid << endl;
    f.close();
#endif
}

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

        // Generate X, Y and ones
        VectorXd x = VectorXd::LinSpaced(NFS,1,NFS);
        this->X = x.rowwise().replicate(NFS).array();
        this->Y = x.transpose().colwise().replicate(NFS).array();

        // The number of neurons per population in the OM model (2500 or 50x50)
        this->neuronsPerPopulation = NFS * NFS;

        this->outputstate = (double*) calloc (this->neuronsPerPopulation, sizeof(double));

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
        // Apply the power centroid:
        this->apply_centroid ((double*)this->inputSheet.getContent(), POWER_DEGREE);
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
