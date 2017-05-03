/*
 * The EyeFrame class.
 */

#ifndef _EYEFRAME_H_
#define _EYEFRAME_H_

#include <Eigen/Dense>
#include "luminance.h"
#include "common.h"

using namespace std;
using namespace Eigen;

/*!
 * "wdm" short for "world data maker".
 */
namespace wdm
{
    /*!
     * Apparent location of objects in the eye's frame of reference.
     */
    class EyeFrame
    {
    public:
        EyeFrame () { this->init (BACKGROUND_LUMINANCE); }
        EyeFrame (const double& bglum) { this->init (bglum); }
        ~EyeFrame() {}

        /*!
         * Initialise the eye frame
         */
        void init (const double& backgroundLum) {

            IOFormat octfmt (StreamPrecision, 0, ",", "\n", "", "", "", "");
            OctaveFmt = octfmt;

            // Initialise the offset attribute as a 6x1 vector
            this->offset.setZero (6, 1);

            //this->luminanceMap.setConstant (WORLD_ANGULAR_WIDTH,
            //                                WORLD_ANGULAR_HEIGHT,
            //                                backgroundLuminance);
            //this->luminanceCartesianCoords.setConstant (WORLD_ANGULAR_WIDTH*WORLD_ANGULAR_HEIGHT,
            //                                   5, 0);

            this->backgroundLuminance = backgroundLum;

            this->neuralFieldSize = 50;
            this->E2 = 2.5;
            this->fieldOfView = 61; // Originally 151 degrees. -75 to 75. Offset is
                                    // +75 on the luminanceMap. Make
                                    // it odd.
            this->fovOffset = (this->fieldOfView - 1) / 2;
            this->distanceToScreen = 1;
            this->screenShape = SCREENSHAPE_SPHERICAL;

            // Generate/setup the locations of the 2500 neurons once only.
            this->generateNeuronThetaCoords();
        }

        /*!
         * Accessors for the offset. Note use of capital R in RotX/Y/Z
         * to denote that these are the same Euler rotations delivered
         * by the U. Patras biomechanical model. Note RotX, RotY and
         * RotZ should be passed in degrees.
         */
        //@{
        void setOffset (const double& RotX, const double& RotY, const double& RotZ);

        double getRotX (void) const
        {
            return this->offset(0);
        }

        double getRotY (void) const
        {
            return this->offset(1);
        }

        double getRotZ (void) const
        {
            return this->offset(2);
        }
        //@}

        /*!
         * Compute the eye frame locations from the passed in Matrix
         * and the member @param offset.
         */
        void setEyeField (const MatrixXd& luminanceCartesianCoords);

        /*!
         * Save the luminance cartesian coords. Load the output in
         * matlab/octave with csvread or just the load command.
         */
        void saveLuminanceCartesianCoords (const std::string& filepath = "eyeframe_lum_cart.dat");

        /*!
         * Save the eye frame luminance map.
         */
        void saveLuminanceMap (const std::string& filepath = "eyeframe_lum_map.dat");

        /*!
         * More saving - these useful only for debugging.
         */
        //@{
        void saveNeuronPixels (const std::string& filepath = "neuron_pixels_w_lum.dat");
        void saveNeuronPrecise (const std::string& filepath = "neuron_precise_w_lum.dat");
        //@}

        /*!
         * Save cortical luminances into the file provided
         */
        void saveCorticalSheet (const std::string& filepath = "cortical_sheet.dat");

        /*!
         * Simple setter for distanceToScreen.
         */
        void setDistanceToScreen (const unsigned int& d)
        {
            this->distanceToScreen = d;
        }

        /*!
         * Return a const pointer to the data array underlying the
         * corticalSheet MatrixXd object.
         */
        const double* getCorticalSheetData (void) const
        {
            return (const double*) this->corticalSheet.data();
        }

    private:
        /*!
         * Generate the neuron locations in theta coordinates, storing
         * them into this->preciseNeuronThetaCoords.
         */
        void generateNeuronThetaCoords (void);

        /*!
         * Convert preciseNeuronThetaCoords into a cartesian
         * representation.
         */
        void neuronThetaToCartesian (void);

        /*!
         * Convert cartesian coordinates of the luminances into a theta map.
         */
        void luminanceCartesianCoordsToThetaMap (void);

    private:

        /*!
         * Populate the cortical sheet with luminances determined from
         * those neurons which have been activated by the incoming
         * luminances.
         */
        void populateCorticalSheet (void);

        /*!
         * Static functions used as unaryExpr which can be applied to
         * all elements of an Eigen matrix.
         */
        //@{
        static double roundnum (double d);
        static double arctan (double d);
        //@}

    private:
        /*!
         * The current offset between the eye frame and the world
         * frame. This is the current rotation of the eye. Stored as
         * RotX, RotY and RotZ, in degrees, in that order within
         * the vector, AND THEN AS RotX, RotY and RotZ, in
         * radians. So there are 6 numbers in this vector.
         *
         * RotX is the rotation about the x axis with respect to the
         * world frame of reference, etc. The x-y-z axes are a
         * right-handed set of cartesian axes. They correspond exactly
         * to the variables RotX, RotY and RotZ which come out of the
         * U. Patras biomechanical model.
         *
         * In fact, all we have to do, is copy the incoming data from
         * the Patras model into this vector.
         */
        VectorXd offset;

        /*!
         * ([up to]360*360) by 7 matrix, where col 1 is x_world, col2
         * is y_world, col3 is z_world, col4 is Luminance, col 5 is
         * x_eye, col 6 is y_eye and col 7 is z_eye. x,y,z here are
         * Cartesian. Only neural locations where the luminance is
         * above background are stored here to reduce the amount of
         * processing which has to be carried out.
         */
        MatrixXd luminanceCartesianCoords;

        /*!
         * The background luminance level.
         */
        double backgroundLuminance;

        /*!
         * This is a map of the luminances in pixels, as seen in the
         * eye frame. These are the luminances at thetaX, thetaY in
         * the eye frame. This is fieldOfViewxfieldOfView in
         * size. Location in this matrix gives thetaX and thetaY (an
         * offset has to be applied, the most central location in this
         * matrix is the focus/fovea).
         */
        MatrixXd luminanceMap;

        /*!
         * Record whether a element of luminanceMap map was added to.
         */
        MatrixXd luminanceMapAddedTo;

        /*!
         * The shortest distance to the flat or curved screen on which
         * the luminances are appearing.
         */
        unsigned int distanceToScreen;

        /*!
         * The shape of the screen - flat or spherical for now.
         */
        ScreenShape screenShape;

        /*!
         * The size length is number of neurons of a cortical sheet.
         */
        unsigned int neuralFieldSize;

        /*!
         * The eccentricity at which the cortical magnification factor
         * has dropped to half its original value as one moves from
         * the fovea to the periphery. See Rovamu and Virsu 1979.
         */
        double E2;

        /*!
         * The field of view of vision in degrees.
         */
        unsigned int fieldOfView;

        /*!
         * The offset into a matrix of size fieldOfView * fieldOfView
         * (such as luminanceMap).
         */
        int fovOffset;

        /*!
         * The nfs*nfs sheet of cortical neurons.  values are
         * activations. Passed as output to the oculomotor model.
         */
        MatrixXd corticalSheet;

        /*!
         * The co-ordinates of the cortical sheet in a nfs^2*2 matrix.
         */
        MatrixXd R;

        /*!
         * The precise neural locations corresponding to the neurons
         * in the nfs*nfs cortical sheet, in thetaX, thetaY format
         * (like WorldFrame::luminanceThetaMap; that is, it's nfs*nfs
         * rows by 2 cols BUT it may also get a 3rd col containing the
         * luminance from this->corticalSheet).
         */
        MatrixXd preciseNeuronThetaCoords;

        /*!
         * Same size as preciseNeuronMap. each entry is the rounded ThetaX,
         * ThetaY values.
         */
        MatrixXd pixelNeuronThetaCoords;

        /*!
         * N by 3 matrix, where col 1 is x, col2 is y, col3 is z;
         * cartesian coordinates of the projection of the neurons at
         * the back of the retina on the "screen".
         */
        MatrixXd neuronCartesianCoords;

        /*!
         * Used for all saving to files.
         */
        IOFormat OctaveFmt;
    };

} // wdm

#endif // _EYEFRAME_H_
