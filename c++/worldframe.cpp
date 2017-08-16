/*!
 * Implementation of the world frame class.
 */

#include "worldframe.h"
#include <fstream>
#include <list>
#include <iostream>
#include <math.h>
#include <stdexcept>

#include "common.h"
#include "debug.h"

using namespace wdm;

void
WorldFrame::saveLuminanceThetaMap (const std::string& filepath)
{
    ofstream f;
    f.open (filepath.c_str(), ios::out|ios::trunc);
    if (!f.is_open()) {
        cerr << "Can't open '" << filepath << "'; failed to save luminance map." << endl;
        return;
    }
    IOFormat OctaveFmt (StreamPrecision, 0, ",", "\n", "", "", "", "");
    f << this->luminanceThetaMap.format(OctaveFmt) << flush;
    f.close();
}

void
WorldFrame::saveLuminanceCoords (const std::string& filepath)
{
    ofstream f;
    f.open (filepath.c_str(), ios::out|ios::trunc);
    if (!f.is_open()) {
        cerr << "Can't open '" << filepath << "'; failed to save luminance co-ords." << endl;
        return;
    }
    IOFormat OctaveFmt (StreamPrecision, 0, ",", "\n", "", "", "", "");
    f << this->luminanceCoords.format(OctaveFmt) << flush;
    f.close();
}

void
WorldFrame::setLuminanceThetaMap (const double& t)
{
    list<Luminance>::iterator lum = this->luminanceSeries.begin();
    int changed = 0;

    DBG ("About to loop through " << this->luminanceSeries.size() << " luminances in luminanceSeries.");
    while (lum != this->luminanceSeries.end()) {

#define NEED_TO_UNAPPLY_BEFORE_APPLY 1
#ifdef NEED_TO_UNAPPLY_BEFORE_APPLY
        if (this->blurMode == true) {
            // Unapply any blur first, but WITHOUT removing the original data.
            for (int b = 0; b < lum->bi; ++b) {
                this->luminanceThetaMap (lum->blurLocations(b,0), lum->blurLocations(b,1)) = lum->background;
            }
            // can now empty lum->blurLocations:
            NoChange_t nochange;
            lum->blurLocations.conservativeResize (0, nochange);
            lum->bi = 0;
        }
#endif

        DBG ("For this lum, thetaX: "<<lum->thetaX<<", thetaY: "<<lum->thetaY<<", timeOn: " << lum->timeOn << " and timeOff: " << lum->timeOff);
        if (t >= lum->timeOn && t < lum->timeOff) {
            // This one needs to be on.
            DBG ("Switching ON luminanceThetaMap(" << lum->thetaX+WORLD_SPAN_OFFSET << ","
                 << lum->thetaY+WORLD_SPAN_OFFSET
                 << ") to value " << lum->brightness);

            // The transform from theta to index in the map is +180,
            // so that -180,-180 degrees is index 0,0 and index 180,180 is 0,0
            // NB: ThetaX is rows ("down" the matrix) Theta Y is cols ("across").
            if (lum->shape == LUM_SHAPE_RECT) {
                // rectangle shape.
                DBG ("rectangle. thetaX:" << lum->thetaX << " WORLD_SPAN_OFFSET:" << WORLD_SPAN_OFFSET
                     << "lum->widthThetaX/2:" << (lum->widthThetaX/2));
                this->luminanceThetaMap.block (lum->thetaX+WORLD_SPAN_OFFSET-(lum->widthThetaX/2),
                                               lum->thetaY+WORLD_SPAN_OFFSET-(lum->widthThetaY/2),
                                               lum->widthThetaX, lum->widthThetaY) = MatrixXd::Constant (lum->widthThetaX,
                                                                                                         lum->widthThetaY,
                                                                                                         lum->brightness);
            } else {
                // Cross shape.
                int a = lum->thetaX+WORLD_SPAN_OFFSET-(lum->widthThetaX/2);
                int b = lum->thetaY+WORLD_SPAN_OFFSET-(lum->thicknessBar/2);
                DBG ("a=" << a << " b=" << b << " widthThetaX:" << lum->widthThetaX << " thickness:" << lum->thicknessBar);
                this->luminanceThetaMap.block (a, b, lum->widthThetaX, lum->thicknessBar) = MatrixXd::Constant (lum->widthThetaX,
                                                                                                                lum->thicknessBar,
                                                                                                                lum->brightness);
                a = lum->thetaX+WORLD_SPAN_OFFSET-(lum->thicknessBar/2);
                b = lum->thetaY+WORLD_SPAN_OFFSET-(lum->widthThetaY/2);
                DBG ("a=" << a << " b=" << b  << " thickness:" << lum->thicknessBar << " widthThetaY:" << lum->widthThetaY);
                this->luminanceThetaMap.block (a, b, lum->thicknessBar, lum->widthThetaY) = MatrixXd::Constant (lum->thicknessBar,
                                                                                                                lum->widthThetaY,
                                                                                                                lum->brightness);
            }
            ++changed;

            // Now apply gaussian at this location only
            if (this->blurMode == true) {
                this->gaussianBlurMap (*lum);
            }

        } else if (t >= lum->timeOff) {
            // This one needs to be turned off.
            DBG ("Switching OFF luminanceThetaMap (" << lum->thetaX+WORLD_SPAN_OFFSET << ","
                 << lum->thetaY+WORLD_SPAN_OFFSET
                 << ") to BG value " << lum->background);

            if (lum->shape == LUM_SHAPE_RECT) {
                this->luminanceThetaMap (lum->thetaX+WORLD_SPAN_OFFSET-(lum->widthThetaX/2),
                                         lum->thetaY+WORLD_SPAN_OFFSET-(lum->widthThetaY/2)) = lum->background;
            } else { // cross
                int a = lum->thetaX+WORLD_SPAN_OFFSET-(lum->widthThetaX/2);
                int b = lum->thetaY+WORLD_SPAN_OFFSET-(lum->thicknessBar/2);
                this->luminanceThetaMap (a, b) = lum->background;
                a = lum->thetaX+WORLD_SPAN_OFFSET-(lum->thicknessBar/2);
                b = lum->thetaY+WORLD_SPAN_OFFSET-(lum->widthThetaY/2);
                this->luminanceThetaMap (a, b) = lum->background;
            }

            if (this->blurMode == true) {
                // unapply gaussian here
                DBG ("Unapply gaussian blur for luminance [x:"<<lum->thetaX<<",y:"<<lum->thetaY<<",Ton:"<<lum->timeOn<<",Toff:"<<lum->timeOff<<"]");
                DBG2 ("lum->blurLocations.rows(): " << lum->blurLocations.rows() << " lum->bi: " << lum->bi);
                for (int b = 0; b < lum->bi /*unreliable: lum->blurLocations.rows()*/; ++b) {
                    DBG2 ("Unapply luminanceThetaMap for blurLocations b="<<b<<" ("
                          << lum->blurLocations(b,0) << "," << lum->blurLocations(b,1) << ")");
                    this->luminanceThetaMap (lum->blurLocations(b,0),
                                             lum->blurLocations(b,1)) = lum->background;
                }
                // Having unapplied these blur locations, can now empty lum->blurLocations:
                NoChange_t nochange;
                lum->blurLocations.conservativeResize (0, nochange);
                lum->bi = 0;
            }
            ++changed;

        } // else no action required.
        ++lum;
    }

    if (changed) {
        // Transform luminanceThetaMap to cartesian coordinates of
        // only those which are not background luminance.
        this->luminanceThetaMapToCartesian();
    }
}

void
WorldFrame::luminanceThetaMapToCartesian (void)
{
    int nrows = this->luminanceThetaMap.rows();
    int ncols = this->luminanceThetaMap.cols();
    int iter = 0;

    // Used with conservativeResize.
    NoChange_t nochange;

    double dist = static_cast<double>(this->distanceToScreen);
    double negdist = -1 * dist;

    double dtanrotxrad = 0.0;
    double dsinrotxrad = 0.0;
    double thetaXrad = 0.0;
    double thetaYrad = 0.0;

    int lumCoordsRows = this->luminanceCoords.rows();

    for (int thetaX = -WORLD_SPAN_OFFSET; thetaX <= WORLD_SPAN_OFFSET; ++thetaX) {

        thetaXrad = static_cast<double>(thetaX) * DEG_TO_RADIANS;

        // Compute some things once only per thetaX value:
        if (this->screenShape == SCREENSHAPE_FLAT) {
            dtanrotxrad = dist * tan (thetaXrad);
        } else if (this->screenShape == SCREENSHAPE_SPHERICAL) {
            dsinrotxrad = dist * sin (thetaXrad);
        }

        for (int thetaY = -WORLD_SPAN_OFFSET; thetaY <= WORLD_SPAN_OFFSET; ++thetaY) {

            DBG2 ("For thetaX, thetaY = " << thetaX
                  << "," << thetaY
                  << ", check map(" << thetaX+WORLD_SPAN_OFFSET
                  << "," << thetaY+WORLD_SPAN_OFFSET);

            if (this->luminanceThetaMap (thetaX+WORLD_SPAN_OFFSET,
                                         thetaY+WORLD_SPAN_OFFSET) <= BACKGROUND_LUMINANCE) {
                continue;
            } // else carry on and add the luminance to the matrix of luminances.
            else {
                DBG2 ("This luminance is above BG: " << this->luminanceThetaMap (thetaX+WORLD_SPAN_OFFSET,
                                                                                 thetaY+WORLD_SPAN_OFFSET));
            }

            thetaYrad = static_cast<double>(thetaY) * DEG_TO_RADIANS;

            if (iter >= lumCoordsRows) {
                // Non-destructive resize and do it just one by one OR
                // find a solution to lumCoordsRows being too big when
                // done.
                DBG ("Resize as iter ("<<iter<<")>=lumCoordsRows ("<<lumCoordsRows<<") luminanceCoords to " << iter+1 << " rows");
                this->luminanceCoords.conservativeResize (iter+1, nochange);
                lumCoordsRows = iter+1;
            }

            if (this->screenShape == SCREENSHAPE_FLAT) {
                this->luminanceCoords (iter, 0) = dist * tan (thetaYrad);
                this->luminanceCoords (iter, 1) = dtanrotxrad; // dist * tan (thetaXrad);
                this->luminanceCoords (iter, 2) = negdist;

            } else if (this->screenShape == SCREENSHAPE_SPHERICAL) {

                // Aug 2017: There's a sign error HERE! should be//
                // -1 * dist * sin (thetaYrad). I belive this is
                // compensated for in the slightly "wrong" Euler
                // rotation matrices in eyeframe.cpp.
                this->luminanceCoords (iter, 0) = dist * sin (thetaYrad);

                this->luminanceCoords (iter, 1) = dsinrotxrad; // dist * sin (thetaXrad);
                this->luminanceCoords (iter, 2) = negdist * cos (sqrt (thetaXrad * thetaXrad + thetaYrad * thetaYrad));
                DBG2 ("x=" << this->luminanceCoords (iter, 0)
                      << " y=" << this->luminanceCoords (iter, 1)
                      << " z=" << this->luminanceCoords (iter, 2)
                      << " For thetaX=" << thetaX << " thetaY=" << thetaY << " dist="
                      << this->distanceToScreen);

            } else {
                throw runtime_error ("Unknown screen shape");
            }

            DBG2 ("Setting luminance value for ("
                  << thetaX+WORLD_SPAN_OFFSET << "," << thetaY+WORLD_SPAN_OFFSET << ") to "
                  << this->luminanceThetaMap (thetaX+WORLD_SPAN_OFFSET,
                                              thetaY+WORLD_SPAN_OFFSET));
            this->luminanceCoords (iter, 3) = this->luminanceThetaMap (thetaX+WORLD_SPAN_OFFSET,
                                                                       thetaY+WORLD_SPAN_OFFSET);
            ++iter;
        }
    }

    this->luminanceCoords.conservativeResize (iter, nochange);

#ifdef DEBUG2
    DBG ("Resulting luminances:");
    for (int j=0; j<this->luminanceCoords.rows(); ++j) {
        DBG ("lum at ("
             << this->luminanceCoords(j,0)
             << "," << this->luminanceCoords(j,1)
             << "," << this->luminanceCoords(j,2) << "): " << this->luminanceCoords(j,3));
    }
#endif
}

void
WorldFrame::gaussianBlurMap (Luminance& l)
{
    // In this version, record which pixels were activated by the
    // luminance when the luminance was blurred.

    DBG2 ("oneDConv along thetaX(" << l.thetaX << ") for thetaY = " << l.thetaY);
    int yi = -(l.widthThetaY/2);
    while (yi <= (l.widthThetaY/2)) {
        this->oneDConvolution (l.thetaX+WORLD_SPAN_OFFSET-(l.widthThetaX/2), l.thetaY+WORLD_SPAN_OFFSET + yi, CONVOLVE_ON_THETA_X, l);
        ++yi;
    }

    int x = l.thetaX - this->halfwidth - (l.widthThetaX/2);
    DBG2 ("thetaX=" << l.thetaX << ", x=" << x);
    while (x <= l.thetaX + this->halfwidth + (l.widthThetaX/2)) {
        if (x+WORLD_SPAN_OFFSET >= 0) { // Only convolve along x's which exist in luminanceThetaMap
            DBG2 ("oneDConv along thetaY for thetaX = " << x);
            this->oneDConvolution (x+WORLD_SPAN_OFFSET,
                                   l.thetaY+WORLD_SPAN_OFFSET-(l.widthThetaY/2), CONVOLVE_ON_THETA_Y, l);
        } else {
            DBG2 ("x+WORLD_SPAN_OFFSET is not >= 0");
        }
        ++x;
    }
}

void
WorldFrame::createGaussianKernel (void)
{
    if (!this->width%2) {
        // error, width should be odd.
        throw runtime_error ("This function needs even width kernels.");
    }

    this->kernel.setZero (this->width);

    // k is our variable for calculating gauss[k]
    int k = -this->halfwidth;
    // j is an iterator into the kernel Vector.
    int j = 0;

    // Once-only parts of the calculation of the Gaussian.
    double root_2_pi = 2.506628275;
    double one_over_sigma_root_2_pi = 1 / this->sigma * root_2_pi;
    double two_sigma_sq = 2 * this->sigma * this->sigma;

    // Gaussian dist. result, and a running sum of the results:
    double gauss = 0;
    double sum = 0;

    // Calculate each element of the kernel:
    while (k <= this->halfwidth) {
        gauss = (one_over_sigma_root_2_pi
                 * exp ( static_cast<double>(-(k*k))
                         / two_sigma_sq ));
        this->kernel(j++) = gauss;
        sum += gauss;
        ++k;
    }

    // Normalise the kernel to 1 by dividing by the sum:
    while (j > 0) {
        --j;
        this->kernel(j) = this->kernel(j) / sum;
    }
}

void
WorldFrame::oneDConvolution (const int& indexX, const int& indexY, const bool& xActive, Luminance& l)
{
    if (!this->width%2) {
        // error, width should be odd.
        throw runtime_error ("This function requires (symmetric and) even width kernels.");
    }

    DBG2 ("At start. Initial l.bi: " << l.bi << "l.blurLocations.rows: " << l.blurLocations.rows());

    // Which axis are we active on? Along which axis shall we compute the convolution?
    int indexActive = 0;
    int indexFixed = 0;
    int activeWidth = 0;
    if (xActive) {
        DBG ("Convolution along thetaX with fixed indexY=" << indexY);
        indexActive = indexX;
        activeWidth = l.widthThetaX;
        indexFixed = indexY;
    } else {
        DBG ("Convolution along thetaY with fixed indexX=" << indexX);
        indexActive = indexY;
        activeWidth = l.widthThetaY;
        indexFixed = indexX;
    }

    // iterate over all indexActive at position indexFixed.
    int n = indexActive - this->halfwidth;
    DBG2 ("indexActive=" << indexActive << " so n=" << n);
    int k = 0;

    // Find the size of the complete row or column we're convolving along.
    int linelength = 0;
    if (xActive) {
        linelength = this->luminanceThetaMap.rows();
    } else {
        // If we're convolving in Y direction, the distance we
        // have to go is actually num of cols in the matrix.
        linelength = this->luminanceThetaMap.cols();
    }

    // Create and initialise a vector for our convolution result
    VectorXd CR;
    CR.setZero (linelength);

    while (n < linelength && n < indexActive + this->halfwidth + activeWidth) {

        // Only compute convolutions for positions which exist in luminanceThetaMap
        if (n < 0) {
            ++n;
            continue;
        }

        // Here's the convolution for CR[n]
        k = n - this->halfwidth;
        int l = 0; // k - n + this->halfwidth;
        while (k < linelength && k <= n + this->halfwidth) {

            // Have we fallen off the start of the matrix?
            if (k<0) {
                DBG ("Increment k, l");
                ++k; ++l;
                continue;
            }
            DBG2 ("l is " << l);
#ifdef DEBUG2
            if (xActive) {
                cout << " this->luminanceThetaMap (k="
                     << k << ", " << indexFixed << ") = ";
                cout << this->luminanceThetaMap (k, indexFixed);
            } else {
                cout << " this->luminanceThetaMap ("
                     << indexFixed << ", k=" << k << ") = ";
                cout << this->luminanceThetaMap (indexFixed, k);
            }
            cout << "\t### k="<<k<<" n="<<n<<" kernel[" << l << "] = " << this->kernel(l) << endl;
#endif
            // Add to the convolution result for n.
            if (xActive) {
                CR(n) += this->luminanceThetaMap (k, indexFixed) * this->kernel(l);
            } else {
                CR(n) += this->luminanceThetaMap (indexFixed, k) * this->kernel(l);
            }

            ++k; ++l;
        }
        ++n;
    }

    // Now we can update the row/col in luminanceThetaMap with the values in CR.
    n = indexActive - this->halfwidth;

#ifdef DEBUG2
    if (xActive) {
        DBG ("Result for X dirn convolution at indexY = " << indexFixed);
    } else {
        DBG ("Result for Y dirn convolution at indexX = " << indexFixed);
    }
#endif

    int m = indexFixed;

    NoChange_t nochange;
    l.blurLocations.conservativeResize (l.bi+this->width+activeWidth, nochange);

    // In this loop, set the newly convolved numbers into
    // luminanceThetaMap and update the blurLocations (for future
    // switching off of the luminance).
    while (n < this->luminanceThetaMap.cols() && n < indexActive + this->halfwidth + activeWidth) {
        if (n < 0) {
            ++n;
            DBG ("n was < 0; continuing!");
            continue;
        }
#ifdef DEBUG2
        cout << "CR(" << n << "): " << CR(n) << endl;
#endif
        if (xActive) {
            // NB: This may not be the most efficient way to copy the result into the luminanceMap.
            this->luminanceThetaMap (n, m) = CR(n);
            DBG ("xActive add to luminance [x:"<<l.thetaX<<",y:"<<l.thetaY<<",Ton:"<<l.timeOn<<",Toff:"<<l.timeOff<<"] blurLocations("<<l.bi<<",0=n="<<n<<"/1=m="<<m<<")");
            l.blurLocations (l.bi,0) = n;
            l.blurLocations (l.bi,1) = m;
        } else {
            this->luminanceThetaMap (m, n) = CR(n);
            DBG ("yActive add to [x:"<<l.thetaX<<",y:"<<l.thetaY<<",Ton:"<<l.timeOn<<",Toff:"<<l.timeOff<<"] blurLocations("<<l.bi<<",0=m="<<m<<"/1=n="<<n<<")");
            l.blurLocations (l.bi,0) = m;
            l.blurLocations (l.bi,1) = n;
        }
        ++n; ++l.bi;
    }
    DBG ("Final l.bi for this luminance at ("<<l.thetaX<< ","<< l.thetaY << ") is " << l.bi << " l.blurLocations.rows(): " << l.blurLocations.rows());
}
