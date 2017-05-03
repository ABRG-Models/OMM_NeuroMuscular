#ifndef _COMMON_H_
#define _COMMON_H_

/*!
 * Conversion factor to convert x degrees into y radians.
 */
#ifndef DEG_TO_RADIANS
# define DEG_TO_RADIANS 0.017453293
#endif

/*!
 * Conversion factor to convert x radians into y degrees.
 */
#ifndef RAD_TO_DEGREES
# define RAD_TO_DEGREES 57.295777937
#endif

/*!
 * Do you want debugging?
 */
//#define DEBUG 1

/*!
 * "wdm" short for "world data maker".
 */
namespace wdm
{
    /*!
     * Is the location of the luminances in this world a flat screen
     * or a spherical curved surface?
     */
    enum ScreenShape {
        SCREENSHAPE_FLAT
        , SCREENSHAPE_SPHERICAL
        , SCREENSHAPE_N
    };

} // namespace wdm

#endif // _COMMON_H_
