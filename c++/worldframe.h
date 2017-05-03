/*
 * Data structures for the worldDataMaker.
 */

#ifndef _WORLDFRAME_H_
#define _WORLDFRAME_H_

#include <Eigen/Dense>
#include <list>
#include <map>
#include "luminance.h"
#include "common.h"

using namespace std;
using namespace Eigen;

/*!
 * The angular size of the world. 1 degree per
 * pixel. WORLD_SPAN_OFFSET has to do with indexing into a square
 * matrix representing a map of the world.
 */
//@{
#define WORLD_ANGULAR_SPAN  241 // odd number wide, so odd-width shapes can be perfectly centred.
#define WORLD_SPAN_OFFSET   120
//@}

/*!
 * definitions to make calls to oneDConvolution more comprehensible.
 */
//@{
#define CONVOLVE_ON_THETA_X true
#define CONVOLVE_ON_THETA_Y false
//@}

/*!
 * "wdm" short for "world data maker".
 */
namespace wdm
{
    /*!
     * Location of objects in the world's frame of reference at a
     * given time, plus a list of luminances which will appear during
     * the course of an experiment.
     */
    class WorldFrame
    {
    public:
        WorldFrame () { this->init (BACKGROUND_LUMINANCE); }
        WorldFrame (const double& bglum) { this->init (bglum); }
        ~WorldFrame() {}

        /*!
         * Initialise the world luminances
         */
        void init (const double& backgroundLuminance) {

            // Hardcode blur mode:
            this->blurMode = true;

            this->luminanceThetaMap.setConstant (WORLD_ANGULAR_SPAN,
                                                 WORLD_ANGULAR_SPAN,
                                                 backgroundLuminance);
            this->luminanceCoords.setConstant (40, 4, 0); // Allocate 40 rows initially.
            this->luminanceSeries.clear();
            this->distanceToScreen = 50;
            this->screenShape = SCREENSHAPE_SPHERICAL;
            this->width = 5; // must be odd
            this->halfwidth = (this->width-1)/2;
            this->sigma = 0.4;
            this->createGaussianKernel();
        }

        /*!
         * Save the luminance map out. Useful for debugging this
         * code. Load the output in matlab/octave with csvread.
         */
        void saveLuminanceThetaMap (const std::string& filepath = "worldframe_lum_map.dat");

        /*!
         * Save the luminance coords out. Load the output in
         * matlab/octave with csvread.
         */
        void saveLuminanceCoords (const std::string& filepath = "worldframe_lum_coords.dat");

        /*!
         * Set up the luminances in the WorldFrame for the experiment
         * time t (in seconds). To do this, luminanceSeries is
         * consulted, any luminances that have to be turned on/off are
         * actioned and any blurs that have to applied are applied.
         */
        void setLuminanceThetaMap (const double& t);

        /*!
         * Convolve the luminance map with a Gaussian with hard-coded
         * sigma. 2 by 2 pixels, 0.5 sigma.
         */
        void gaussianBlurMap (Luminance& l);

        /*!
         * Create a kernel for the Gaussian convolution with width pixels
         */
        void createGaussianKernel (void);

        /*!
         * Calculate a single line of the convolution of
         * luminanceThetaMap in a direction direction around position
         * indexX, indexY (which are related to thetaX/thetaY by an
         * offset of WORLD_SPAN_OFFSET). luminance is passed in so
         * that the blur locations can be recorded and so that the
         * luminance widths are available.
         */
        void oneDConvolution (const int& indexX, const int& indexY, const bool& xActive, Luminance& l);

        void setBlurMode (const bool& b) { this->blurMode = b; }

    private:
        /*!
         * Take the "image map" in theta coordinates and make up a
         * cartesian coordinate matrix. Only include those values
         * which are above the background luminance.
         */
        void luminanceThetaMapToCartesian (void);

    public:
        /*!
         * Luminance image map. split up into 360 by 360 angular
         * pixels. The rows is thetaX; rotation about the x axis _with
         * the y axis rotation at 0_. Cols is thetaY; rotation about the
         * y axis _with the x axis rotation at 0_. These are NOT Euler
         * rotations.
         *
         * A +10 degree thetaX means the point is above the horizon. A
         * +10 degree thetaY means the point is to the left of the
         * meridian.
         *
         * The Gaussian blur is applied to this map.
         */
        MatrixXd luminanceThetaMap;

        /*!
         * The shortest distance to the flat or curved screen on which
         * the luminances are appearing. Required by
         * luminanceThetaMapToCartesian().
         */
        unsigned int distanceToScreen;

        /*!
         * The shape of the screen - flat or spherical for now.
         */
        ScreenShape screenShape;

        /*!
         * (up to 360x360) by 4 matrix, where col 1 is x, col2 is y,
         * col3 is z and col4 is Luminance. "Coords" are always
         * Cartesian in the WorldFrame class. Only pixels in
         * luminanceThetaMap which are above background luminance are
         * transferred into this container.
         */
        MatrixXd luminanceCoords;

    private:
        /*!
         * Our (Gaussian) convolution kernel for blurring.
         */
        VectorXd kernel;

        /*!
         * Parameters for creating the kernel
         */
        //@{
        int width;
        int halfwidth;
        double sigma;
        //@}

        /*!
         * Whether to apply gaussian blur to pixels in this component.
         */
        bool blurMode;

    public:
        /*!
         * A pre-defined series of luminances for the current experiment.
         */
        list<Luminance> luminanceSeries;
    };

} // wdm

#endif // _WORLDFRAME_H_
