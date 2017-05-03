/*
 * A C++ Brahms component for the Oculomotor model - this one computes
 * multiple centroids so that if you have two or more luminances
 * creating hills of activity in SC deep, you'll get multiple,
 * separate signals transmitted into the saccade generating circuitry.
 *
 * This is coded based on the matlab prototype in
 * multicentroid_compute.m
 *
 * Author: Seb James.
 * Date: April 2015.
 */

#define COMPONENT_CLASS_STRING "dev/NoTremor/multicentroid"
#define COMPONENT_CLASS_CPP dev_notremor_multicentroid_0
#define COMPONENT_RELEASE 0
#define COMPONENT_REVISION 1
#define COMPONENT_ADDITIONAL "Author=Seb James\n" "URL=Not supplied\n"
#define COMPONENT_FLAGS (F_NOT_RATE_CHANGER)

#define OVERLAY_QUICKSTART_PROCESS

#include <brahms-1199.h>
#include <iostream>
#include <math.h>
#include <vector>
#include <utility>
#include <stdlib.h>
#include <Eigen/Dense>

#ifdef __WIN__
// Windows specific includes/apologies here.
#else
// Linux specific includes here.
#endif

namespace numeric = std_2009_data_numeric_0;
using namespace std;
using namespace brahms;
using namespace Eigen;

// Use a shorthand for unsigned int in this code file.
typedef unsigned int uint;

// Define this to output the maps into files.
//#define DEBUG_MAPS 1

// Define this to show a START and FINISHED message for each neural
// sheet processed.
//#define PROFILE_CODE 1

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
     * The default radius over which a single hump can "connect" to other
     * humps. Within this radius, two luminances will be vector averaged
     * together. May be overridden with the brahms parameter
     * centroid_radius.
     */
    uint centroid_radius;

    /*!
     * The centroid region maps.
     */
    vector<Array<uint, NFS, NFS> > centroidmaps;

    /*!
     * These arrays are used repeatedly in
     * multicentroid_make_centroid_maps so initialise once only.
     */
    //@{
    Array<double, NFS, NFS> X;
    Array<double, NFS, NFS> Y;
    Array<uint, NFS, NFS> ones;
    Array<uint, NFS, NFS> map_i;
    Array<uint, NFS, NFS> map_j;
    Array<uint, NFS, NFS> U;
    Array<double, NFS, NFS> x_sq;
    Array<double, NFS, NFS> y_sq;
    Array<double, NFS, NFS> D;
    //@}

    /*!
     * scalars used in multicentroid_make_centroid_maps
     */
    //@{
    uint iter;
    uint sz;
    uint i;
    uint j;
    vector<pair<uint, uint> >::iterator j_iter;
    uint sum_i;
    uint sum_j;
    uint sum_both;
    //@}

    /*!
     * These used repeatedly in apply_centroids()
     */
    //@{
    double sigma_r_dot_a_x;
    double sigma_r_dot_a_y;
    double sigma_a;
    uint centroid_x;
    uint centroid_y;
    //@}

    /*!
     * Variables used in multicentroid_find_peaks
     */
    //@{
    vector<pair<uint, uint> > indices;
    Array<double, NFS_MINUS_1, NFS> first_deriv1;
    Array<double, NFS, NFS> sec_deriv1;
    double sec_deriv_max;
    double sec_deriv_min;
    double sec_deriv_thresh;
    Array<uint, NFS, NFS> min_sec_deriv1;
    Array<double, NFS, NFS_MINUS_1> first_deriv2;
    Array<double, NFS, NFS> sec_deriv2;
    Array<uint, NFS, NFS> min_sec_deriv2;
    Array<uint, NFS, NFS> peaks;
    uint peaksthresh;
    Array<uint, NFS, NFS> peaksfinal;
    uint count;
    Array<uint, NFS, 1> row;
//@}

private:

    /*!
     * Find locations of the peaks in the neural field input.
     */
    void multicentroid_find_peaks (double* input);

    /*!
     * Using the indices generated in multicentroid_find_peaks, make a
     * series of centroid region maps.
     *
     * centroid_radius is the "radius over which neurons in the SC_deep
     * communicate". If two peaks are within 10 units of each other,
     * then they are grouped together in one "centroiding map". If
     * they're further than this distance apart, they'll lead to two
     * separate centroiding maps.
     */
    void multicentroid_make_centroid_maps (void);

    /*!
     * Apply the centroids worked out by
     * multicentroid_make_centroid_maps()
     */
    void apply_centroids (double* input);
};

void
COMPONENT_CLASS_CPP::multicentroid_find_peaks (double* input)
{
#ifdef DEBUG_MAPS
    ofstream f;
#endif

    this->indices.clear();

    // Get input as an array without copying the data:
    Map<Array<double, NFS, NFS> > sheet(input,NFS,NFS);

    // First deriv in vert dirn.
    this->first_deriv1 = sheet.bottomRows(NFS_MINUS_1) - sheet.topRows(NFS_MINUS_1);
#ifdef DEBUG_MAPS
    f.open ("first_deriv1.dat", ios::out|ios::trunc);
    f << this->first_deriv1 << endl;
    f.close();
#endif
    // Second deriviative in vert. dirn.
    this->sec_deriv1 = Array<double, NFS, NFS>::Zero();
    this->sec_deriv1.block<NFS_MINUS_2,NFS>(1,0) =
        this->first_deriv1.bottomRows(NFS_MINUS_2) - this->first_deriv1.topRows(NFS_MINUS_2);
#ifdef DEBUG_MAPS
    f.open ("sec_deriv1.dat", ios::out|ios::trunc);
    f << sec_deriv1 << endl;
    f.close();
#endif
    // Threshold for finding the min regions of the second deriv map
    this->sec_deriv_max = sec_deriv1.maxCoeff();
    this->sec_deriv_min = sec_deriv1.minCoeff();
    this->sec_deriv_thresh = sec_deriv_min + (0.5*(sec_deriv_max-sec_deriv_min));

    // Finding the min. of the second derivative map
    this->min_sec_deriv1 = (this->sec_deriv1 < this->sec_deriv_thresh).select(this->ones, 0);

    // First and second derivs in horiz dirn.
    this->first_deriv2 = sheet.rightCols(NFS_MINUS_1) - sheet.leftCols(NFS_MINUS_1);
    this->sec_deriv2 = Array<double, NFS, NFS>::Zero();
    this->sec_deriv2.block<NFS,NFS_MINUS_2>(0,1) =
        this->first_deriv2.rightCols(NFS_MINUS_2) - this->first_deriv2.leftCols(NFS_MINUS_2);
#ifdef DEBUG_MAPS
    f.open ("sec_deriv2.dat", ios::out|ios::trunc);
    f << sec_deriv2 << endl;
    f.close();
#endif
    // Finding the min of the second deriv. map
    this->sec_deriv_max = this->sec_deriv2.maxCoeff();
    this->sec_deriv_min = this->sec_deriv2.minCoeff();
    this->sec_deriv_thresh = sec_deriv_min + (0.5*(sec_deriv_max-sec_deriv_min));
    this->min_sec_deriv2 = (this->sec_deriv2 < this->sec_deriv_thresh).select(this->ones, 0);

    // Add the two "minimum maps" and square to accentuate the centre of the peaks
    this->peaks = (this->min_sec_deriv1 + this->min_sec_deriv2).square();
#ifdef DEBUG_MAPS
    f.open ("peaks.dat", ios::out|ios::trunc);
    f << peaks << endl;
    f.close();
#endif
    // Find a threshold for picking off the max of the peaks map
    this->peaksthresh = this->peaks.maxCoeff() >> 1;
#ifdef DEBUG_MAPS
    bout << "peaksthresh: " << peaksthresh << D_INFO;
#endif
    // Select the peaks using peaksthresh, making a binary map of their locations.
    this->peaksfinal = (peaks > peaksthresh).select(this->ones, 0);
#ifdef DEBUG_MAPS
    f.open ("peaksfinal.dat", ios::out|ios::trunc);
    f << peaksfinal << endl;
    f.close();
#endif
    // Find the indices of peaksfinal. I don't want to bring in libigl
    // for now, so lets do some looping.
    count = 0;
    for (i = 0; i < NFS; ++i) {
        this->row = peaksfinal.row(i);
        for (j = 0; j < NFS; ++j) {
            if (this->row(j,0)>0) {
                // Using a Dynamic Array for the indices seemed
                // troublesome so I've used a good old vector of
                // pairs.
                this->indices.push_back(make_pair(i,j));
            }
        }
    }
}

void
COMPONENT_CLASS_CPP::multicentroid_make_centroid_maps (void)
{
    // NB: The majority of variables in this method are member
    // attributes but I've left the usual "this->" tags off for
    // clarity.

    centroidmaps.clear();

    iter = 0;
    sz = indices.size();
    i = 0;

    while (i < sz) {

        x_sq = (X-(indices[i].first)).abs().square();
        y_sq = (Y-(indices[i].second)).abs().square();
        D = (x_sq+y_sq).sqrt();
        map_i = (D<centroid_radius).select (ones, 0);
        sum_i = map_i.sum();

        // From this index, i, check if ANY of the other maps touch
        // this one and merge those which do. New index j to count
        // from i to the end of the indices matrix.
        j = i + 1;
        while (j < sz) {

            x_sq = (X-(indices[j].first)).abs().square();
            y_sq = (Y-(indices[j].second)).abs().square();
            D = (x_sq+y_sq).sqrt();
            map_j = (D<centroid_radius).select (ones, 0);
            sum_j = map_j.sum();

            // Work out if two maps are touching by adding them together and
            // seeing if that sums to the same as the two individual
            // maps. If so, they're separate and so treat them as two
            // separate maps. Otherwise; merge.
            U = ((map_i + map_j) > 0).select (ones, 0);
            sum_both = U.sum();

            if (sum_i>0 && sum_j>0 && (sum_i + sum_j == sum_both)) {
                // j is a separate mask from i, so move on to the next j.
                ++j;
            } else {
                // They're touching, so add map_j to map_i, remove
                // indices element j and then reset j to i+1 and
                // restart this algorithm.
                map_i = ((map_i + map_j) > 0).select (ones, 0);
                sum_i = map_i.sum();
                j_iter = indices.begin() + j;
                indices.erase(j_iter);
                sz = indices.size();
                j = i + 1; // back to i
            }
        }

        centroidmaps.push_back (map_i);
        ++iter;
        ++i;
    }
#ifdef DEBUG_MAPS
    bout << "centroidmaps has size " << centroidmaps.size() << D_INFO;
#endif
}

void
COMPONENT_CLASS_CPP::apply_centroids (double* input)
{
    // Wrap the output in an array, ready for output
    Map<Array<double, NFS, NFS> > the_centroid((double*)this->centroid.getContent(),NFS,NFS);
    // Zero out the result of the last timestep:
    the_centroid.setZero();

    // Get input as an array without copying the data:
    Map<Array<double, NFS, NFS> > sheet(input,NFS,NFS);

    vector<Array<uint, NFS, NFS> >::const_iterator iter = this->centroidmaps.begin();
    while (iter != this->centroidmaps.end()) {
        this->D = sheet * iter->cast<double>(); // D is partsheet
        sigma_r_dot_a_x = (this->X*this->D).sum();
        sigma_r_dot_a_y = (this->Y*this->D).sum();
        sigma_a = this->D.sum();
        centroid_x = (uint)round(sigma_r_dot_a_x/sigma_a);
        centroid_y = (uint)round(sigma_r_dot_a_y/sigma_a);
        // Decrement ops here as Eigen arrays count from 0.
        the_centroid (--centroid_x, --centroid_y) = sigma_a;
        ++iter;
    }

#ifdef DEBUG_MAPS
    ofstream f;
    stringstream fname;
    fname << "centroid" << this->time->now << ".dat";
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

        // Obtain centroid_radius
        this->centroid_radius = nodeState.getField ("centroid_radius").getINT32();

        // Generate X, Y and ones
        VectorXd x = VectorXd::LinSpaced(NFS,1,NFS);
        this->X = x.rowwise().replicate(NFS).array();
        this->Y = x.transpose().colwise().replicate(NFS).array();
        this->ones.fill(1);

        // More array initialisation
        this->map_i = Array<uint, NFS, NFS>::Zero();
        this->map_j = Array<uint, NFS, NFS>::Zero();
        this->U = Array<uint, NFS, NFS>::Zero();
        this->x_sq = Array<double, NFS, NFS>::Zero();
        this->y_sq = Array<double, NFS, NFS>::Zero();
        this->D = Array<double, NFS, NFS>::Zero();

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
            this->centroid.setStructure(TYPE_DOUBLE | TYPE_REAL, Dims(NFS_SQUARED).cdims());

            this->inputSheet.attach (hComponent, "inputSheet");
            this->inputSheet.validateStructure (TYPE_REAL|TYPE_DOUBLE, Dims(NFS_SQUARED).cdims());
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
#ifdef PROFILE_CODE
        bout << "START processing" << D_INFO;
#endif
        // Read the input
        double* input = (double*)this->inputSheet.getContent();
        // Find peaks
        this->multicentroid_find_peaks (input);

#ifdef DEBUG_MAPS
        vector<pair<uint, uint> >::const_iterator indices_i = indices.begin();
        while (indices_i != indices.end()) {
            bout << "Peak at (" << indices_i->first << "," << indices_i->second << ")" << D_INFO;
            ++indices_i;
        }
#endif

        // Make the localised centroid maps
        this->multicentroid_make_centroid_maps();

#ifdef DEBUG_MAPS
        vector<Array<uint, NFS, NFS> >::const_iterator cmi = this->centroidmaps.begin();
        i = 0;
        while (cmi != this->centroidmaps.end()) {
            ofstream f;
            stringstream fname;
            fname << "MAP" << i++ << ".dat";
            f.open (fname.str().c_str(), ios::out|ios::trunc);
            f << *cmi++ << endl;
            f.close();
        }
#endif

        // Apply the centroid maps and set the output in this->centroid
        this->apply_centroids (input);

#ifdef PROFILE_CODE
        bout << "FINISHED processing" << D_INFO;
#endif
        // ok, RUN_SERVICE event serviced.
        return C_OK;
    }

    case EVENT_RUN_STOP:
    {
        bout << "EVENT_RUN_STOP" << D_INFO;
        // Do any cleanup necessary here.
//        delete[] this->currentcentroid;
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
