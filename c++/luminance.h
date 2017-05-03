/*
 * Data structures for the worldDataMaker.
 *
 * A luminance pixel class.
 */

#ifndef _LUMINANCE_H_
#define _LUMINANCE_H_

#include <Eigen/Dense>

/*!
 * The background lighting level.
 */
#define BACKGROUND_LUMINANCE 0.00 // FIXME should be input arg

/*!
 * "wdm" short for "world data maker".
 */
namespace wdm
{
    enum LUM_SHAPE {
        LUM_SHAPE_RECT,
        LUM_SHAPE_CROSS,
        NUM_LUM_SHAPE
    };

    /*!
     * Information about a single luminance. Where it appears in the
     * world frame, how bright it will be, when it turns on and when
     * it turns off, and what the background should be restored to
     * afterwards.
     *
     * Theta X is a rotation about the cartesian x axis with the y and
     * z axes in an unrotated position. Theta Y is a rotation about
     * the cartesian y axis with x and z axes unrotated.
     *
     * Note this is a single (set of) pixel(s). The world class will
     * include any transformations used to blur or spread out this
     * luminance.
     */
    class Luminance
    {
    public:
        Luminance (const int& thX, const int& thY,
                   const double& bright, const double& tOn, const double& tOff)
            : thetaX (thX)
            , thetaY (thY)
            , widthThetaX (1)
            , widthThetaY (1)
            , brightness (bright)
            , background (BACKGROUND_LUMINANCE)
            , timeOn (tOn)
            , timeOff (tOff)
            , bi (0)
            , shape (LUM_SHAPE_RECT)
            { this->blurLocations.setConstant (0, 2, 0); }
        Luminance (const int& thX, const int& thY,
                   const int& wThX, const int& wThY,
                   const double& bright, const double& tOn, const double& tOff)
            : thetaX (thX)
            , thetaY (thY)
            , widthThetaX (wThX)
            , widthThetaY (wThY)
            , brightness (bright)
            , background (BACKGROUND_LUMINANCE)
            , timeOn (tOn)
            , timeOff (tOff)
            , bi (0)
            , shape (LUM_SHAPE_RECT)
            { this->blurLocations.setConstant (0, 2, 0); }
        Luminance()
            : bi(0)
            , shape (LUM_SHAPE_RECT)
            { this->blurLocations.setConstant (0, 2, 0); }
        ~Luminance() {}

    public:
        /*!
         * The angular location of this luminance. "Straight ahead" is
         * 0,0.
         */
        //@{
        int thetaX;
        int thetaY;
        //@}

        /*!
         * The width of this luminance, in "pixels".
         */
        //@{
        int widthThetaX;
        int widthThetaY;
        //@}

        /*!
         * The brightness of this luminance.
         */
        double brightness;

        /*!
         * The brightness to which the space should return after the
         * luminance has turned off.
         *
         * NB: The idea of having the background in the luminance
         * object is now obsolete and should be got rid of.
         */
        double background;

        /*!
         * The time, in seconds, when this luminance switches on, and
         * then off.
         */
        //@{
        double timeOn;
        double timeOff;
        //@}

        /*!
         * If this luminance has been blurred; record the locations
         * that the blur extended to so that these can be reset when
         * the luminance switches off.
         */
        Eigen::MatrixXd blurLocations;

        /*!
         * blur location iterator.
         */
        int bi;

        /*!
         * The shape of this luminance. rectangle or cross.
         */
        wdm::LUM_SHAPE shape;

        /*!
         * The thickness of the bar of a cross if it's a cross. Alex
         * C's original cross was 6 in length and 2 in the width of
         * the bar. Length of the bar is given by widthThetaX or
         * widthThetaY.
         */
        int thicknessBar;
    };

    class CrossLuminance : public Luminance
    {
    public:
        CrossLuminance (const int& thX, const int& thY,
                        const double& bright, const double& tOn, const double& tOff)
            : Luminance (thX, thY, bright, tOn, tOff)
            {
                this->shape = LUM_SHAPE_CROSS;
                this->blurLocations.setConstant (0, 2, 0);
            }
        CrossLuminance (const int& thX, const int& thY,
                        const int& lBar, const int& tBar,
                        const double& bright, const double& tOn, const double& tOff)
            : Luminance (thX, thY, lBar, lBar, bright, tOn, tOff)
            {
                this->shape = LUM_SHAPE_CROSS;
                this->bi = 0;
                this->thicknessBar = tBar;
                this->blurLocations.setConstant (0, 2, 0);
            }
        CrossLuminance() : Luminance()
            {
                this->shape = LUM_SHAPE_CROSS;
            }
        ~CrossLuminance() {}
    };

} // wdm

#endif // _LUMINANCE_H_
