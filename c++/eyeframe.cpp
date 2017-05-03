/*!
 * Implementation of eye frame class.
 */

#include "eyeframe.h"
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <math.h>

// #define DEBUG_PIXEL_NEURONS 1
#ifdef DEBUG_PIXEL_NEURONS
#include <map>
#include <utility>
#endif

#include "common.h"
#include "debug.h"

using namespace wdm;

void
EyeFrame::setOffset (const double& RotX, const double& RotY, const double& RotZ)
{
    this->offset(0) = RotX;
    this->offset(1) = RotY;
    this->offset(2) = RotZ;
    this->offset(3) = RotX * DEG_TO_RADIANS;
    this->offset(4) = RotY * DEG_TO_RADIANS;
    this->offset(5) = RotZ * DEG_TO_RADIANS;
}

#define ROTX this->offset(3)
#define ROTY this->offset(4)
#define ROTZ this->offset(5)
void
EyeFrame::setEyeField (const MatrixXd& worldCoords)
{
    // 1. copy worldCoords onto luminanceCartesianCoords
    this->luminanceCartesianCoords = worldCoords;
    // We need to add some columns for use in EyeFrame (as eye_x, eye_y, eye_z):
    NoChange_t nochange;
    this->luminanceCartesianCoords.conservativeResize(nochange, 7);

#ifdef DEBUG2
    int nrows = worldCoords.rows();
    DBG ("worldCoords nrows: " << nrows);
    DBG ("worldCoords ncols: " << worldCoords.cols());
    for (int i = 0; i < nrows; ++i) {
        if (worldCoords (i, 3) > BACKGROUND_LUMINANCE) {
            DBG("worldCoords luminance for row " << i << " is " << worldCoords (i, 3));
        } else {
            DBG("worldCoords luminance for row " << i << " is " << worldCoords (i, 3));
        }
    }
#endif

    // 2. Apply transform

    // Construct rotation matrices
    Matrix3d RMx, RMy, RMz;
    RMx << 1, 0,         0,
           0, cos(ROTX), sin(ROTX),
           0, -sin(ROTX), cos(ROTX);

    RMy << cos(ROTY), 0, sin(ROTY),
           0,         1, 0,
          -sin(ROTY), 0, cos(ROTY);

    RMz << cos(ROTZ), sin(ROTZ), 0,
          -sin(ROTZ), cos(ROTZ),  0,
           0,         0,          1;

    // Create one combined rotation matrix
    Matrix3d RM = RMx * (RMy * RMz);

#ifdef DEBUG
    IOFormat VecFmt (StreamPrecision, 0, ",", ",", "", "", "(", ")");
#endif
    Vector3d vec, transvec;
    vec(2) = 0;

    for (int i = 0; i < this->luminanceCartesianCoords.rows(); ++i) {
        vec = this->luminanceCartesianCoords.row(i).head(3);
        transvec = RM * vec;
        // Here's where the additional columns are added to luminanceCartesianCoords:
        this->luminanceCartesianCoords.row(i).tail(3) = transvec;
        DBG ("++ "<< vec.format (VecFmt) << " --to--> " << transvec.format (VecFmt));
    }

    DBG ("Completed Euler rotation; now convert to theta map.");
    this->luminanceCartesianCoordsToThetaMap();

    // Last, populate the corticalSheet with the newly "lit up" positions.
    this->populateCorticalSheet();
}

void
EyeFrame::saveLuminanceCartesianCoords (const std::string& filepath)
{
    ofstream f;
    f.open (filepath.c_str(), ios::out|ios::trunc);
    if (!f.is_open()) {
        cerr << "Can't open " << filepath << "; failed to save eyeframe luminance cart coords." << endl;
        return;
    }
    f << this->luminanceCartesianCoords.format (this->OctaveFmt) << flush;
    f.close();
}

void
EyeFrame::luminanceCartesianCoordsToThetaMap (void)
{
    if (this->screenShape == SCREENSHAPE_FLAT) {
        throw runtime_error ("flat screen not implemented yet in EyeFrame::luminanceCartesianCoordsToMap");
    } else if (this->screenShape == SCREENSHAPE_SPHERICAL) {

        // This is the transformation from Cartesian to thetas: tan thetaY = x/-z; tan thetaX = y/-z.
        VectorXd thetaX, thetaY;
        try {
            thetaX = (luminanceCartesianCoords.col(5).array()/(-1 * luminanceCartesianCoords.col(6).array())).array().unaryExpr (ptr_fun (EyeFrame::arctan));
            thetaY = (luminanceCartesianCoords.col(4).array()/(-1 * luminanceCartesianCoords.col(6).array())).array().unaryExpr (ptr_fun (EyeFrame::arctan));
        } catch (std::exception& e) {
            // This doesn't seem to catch an exception when something goes wrong in the matrix ops above.
            DBG("Exception generating thetaX,thetaY: " << e.what());
        }

#ifdef DEBUG
        ofstream f1;
        f1.open ("eyeframe_thetaX.dat", ios::out|ios::trunc);
        if (!f1.is_open()) {
            cerr << "Can't open file." << endl;
            return;
        }
        f1 << thetaX.format (this->OctaveFmt) << flush;
        f1.close();
        f1.open ("eyeframe_thetaY.dat", ios::out|ios::trunc);
        if (!f1.is_open()) {
            cerr << "Can't open file." << endl;
            return;
        }
        f1 << thetaY.format (this->OctaveFmt) << flush;
        f1.close();
#endif
        try {
            // NB: setConstant resizes.
            DBG ("Resize (" << this->fieldOfView << "x" << this->fieldOfView
                 << ") and setConstant (" << this->backgroundLuminance << ") for luminanceMap");
            this->luminanceMap.setConstant (this->fieldOfView, this->fieldOfView, this->backgroundLuminance);
        } catch (std::exception& e) {
            DBG ("resize of luminanceMap failed: " << e.what());
        }

        // This is a container to record which luminances have been
        // "reset" from the background, so that I can set them to 0
        // once, then add the rotated luminances in afterwards.
        this->luminanceMapAddedTo.setConstant (this->fieldOfView, this->fieldOfView, 0);

        for (int i = 0; i < thetaX.rows(); ++i) {

            // If there are empty rows in thetaX, then we'll see NANs.
            if (std::isnan(thetaX(i))) {
                break;
            }

            // There is something up with this transform. To see this,
            // run weightmap and look at the eyeframe_lum_map.
            double rowi = rint ((double)thetaX(i)+(double)((this->fieldOfView-1)/2));
            int rowidx = static_cast<int>(rowi);
            int colidx = static_cast<int>(rint ((double)thetaY(i)+(double)((this->fieldOfView-1)/2)));
            // If the location of this luminance is outside the field of view, have to ignore it.
            if (rowidx >= this->fieldOfView || colidx >= this->fieldOfView || rowidx < 0 || colidx < 0) {
                DBG ("Omit " << rowidx << "," << colidx << " for which i=" << i);
            } else {
                if (this->luminanceMapAddedTo (rowidx, colidx) == 0) {
                    // Remove background luminance for this element
                    this->luminanceMap (rowidx, colidx) = 0;
                    // Note that we did this
                    this->luminanceMapAddedTo (rowidx, colidx) = 1;
                }
                DBG ("Adding to luminanceMap(" << rowidx << "," << colidx << ") from cart coords row "
                     << i << " which has value  "
                     << luminanceCartesianCoords (i, 3));
                // Note: Here, >1 pixel in the world frame may be
                // effectively incident on a pixel in the eye frame,
                // depending on the geometry, leading to intuitively
                // unexpected luminance spikes in the eye frame for
                // some eye rotations.
                this->luminanceMap (rowidx, colidx) += luminanceCartesianCoords (i, 3);
            }
        }
    } else {
        throw runtime_error ("Unknown screen shape in EyeFrame::luminanceCartesianCoordsToThetaMap");
    }
}

void
EyeFrame::saveLuminanceMap (const std::string& filepath)
{
    ofstream f;
    f.open (filepath.c_str(), ios::out|ios::trunc);
    if (!f.is_open()) {
        cerr << "Can't open '" << filepath << "'; failed to save eyeframe luminance map." << endl;
        return;
    }

    f << this->luminanceMap.format (this->OctaveFmt) << flush;
    f.close();
}

void
EyeFrame::populateCorticalSheet (void)
{
    DBG ("Called");
    this->corticalSheet.resize(this->neuralFieldSize, this->neuralFieldSize);

    unsigned int cort_r = 0; // radial eccentricity.
    unsigned int cort_theta = 0; // angle from vertical.
    for (unsigned int i = 0; i < this->pixelNeuronThetaCoords.rows(); ++i) {

        // Mapping from the row in pixelNeuronThetaCoords (50x50 =
        // 2500 rows in length) to cortical sheet r and theta:
        cort_r = i%this->neuralFieldSize;

        // Initially I had cort_theta = i/this->neuralFieldSize, but
        // this gives the wrong mapping - it leads to output which
        // looks like theta is reversed in direction. With the code
        // here, we fill in row 49, then row 48 and so on of
        // corticalSheet. This leads to the correct data format
        // expected by the brain model.
        //cort_theta = (this->neuralFieldSize - i/this->neuralFieldSize) - 1;
        //
        // 20150821: Careful examination of the mapping shows that
        // i/this-neuralFieldSize IS correct (the above led to a sign
        // error in one axis):
        cort_theta = i/this->neuralFieldSize;

        // Note: theta is "rows" r is "cols". When saved out, and loaded into matlab, this holds (tested 20150105).
        DBG ("pixelNeuronThetaCoords, row " << i
             << ": (" << this->pixelNeuronThetaCoords(i,0) << "," << this->pixelNeuronThetaCoords(i,1) << ")");
        if (this->pixelNeuronThetaCoords(i,0) >= -this->fovOffset && this->pixelNeuronThetaCoords(i,0) <= this->fovOffset
            && this->pixelNeuronThetaCoords(i,1) >= -this->fovOffset && this->pixelNeuronThetaCoords(i,1) <= this->fovOffset) {
            this->corticalSheet (cort_theta, cort_r) = this->luminanceMap (this->pixelNeuronThetaCoords(i,0) + this->fovOffset,
                                                                           this->pixelNeuronThetaCoords(i,1) + this->fovOffset);
        } else {
            DBG2 ("corticalSheet (" << cort_theta << "," << cort_r << ") empty");
            this->corticalSheet (cort_theta, cort_r) = 0.0;
        }

#define BE_EFFICIENT 1
#ifndef BE_EFFICIENT
        this->pixelNeuronThetaCoords(i,2) = this->corticalSheet (cort_theta, cort_r);
        DBG2 ("pixelNeuronThetaCoords = (" << this->pixelNeuronThetaCoords(i,0)
              << "," << this->pixelNeuronThetaCoords(i,1) << ") for value " << this->pixelNeuronThetaCoords(i,2));
        this->preciseNeuronThetaCoords(i,2) = this->corticalSheet (cort_theta, cort_r);
        DBG2 ("preciseNeuronThetaCoords = (" << this->preciseNeuronThetaCoords(i,0)
              << "," << this->preciseNeuronThetaCoords(i,1) << ") for value " << this->preciseNeuronThetaCoords(i,2));
#endif

#ifdef DEBUG2
        if (this->corticalSheet (cort_theta, cort_r) > this->backgroundLuminance) {
            DBG ("Set corticalSheet (" << cort_theta << "," << cort_r << ") from luminanceMap ("
                 << this->pixelNeuronThetaCoords(i,0) + this->fovOffset << "," << this->pixelNeuronThetaCoords(i,1) + this->fovOffset
                << ") to value " << this->corticalSheet (cort_theta, cort_r));
        } else {
            DBG ("corticalSheet (" << cort_theta << "," << cort_r << ")=" << this->corticalSheet (cort_theta, cort_r) << " is <= bg luminance");
        }
#endif
    }
}

void
EyeFrame::saveNeuronPixels (const std::string& filepath)
{
    ofstream f;
    f.open (filepath.c_str(), ios::out|ios::trunc);
    if (!f.is_open()) {
        cerr << "Can't open '" << filepath << "'; failed to save pixel neuron co-ords." << endl;
        return;
    }
    f << this->pixelNeuronThetaCoords.format (this->OctaveFmt) << flush;
    f.close();
}

void
EyeFrame::saveNeuronPrecise (const std::string& filepath)
{
    ofstream f;
    f.open (filepath.c_str(), ios::out|ios::trunc);
    if (!f.is_open()) {
        cerr << "Can't open '" << filepath << "'; failed to save precise neuron co-ords." << endl;
        return;
    }
    f << this->preciseNeuronThetaCoords.format (this->OctaveFmt) << flush;
    f.close();
}

void
EyeFrame::saveCorticalSheet (const std::string& filepath)
{
    ofstream f;
    f.open (filepath.c_str(), ios::out|ios::trunc);
    if (!f.is_open()) {
        cerr << "Can't open " << filepath << "; failed to save cortical sheet." << endl;
        return;
    }
    f << this->corticalSheet.format (this->OctaveFmt) << flush;
    f.close();
}

double
EyeFrame::roundnum (double d)
{
    return round(d);
}

double
EyeFrame::arctan (double d)
{
    return atan(d) * RAD_TO_DEGREES;
}

#define TWOPI 6.283185307
void
EyeFrame::generateNeuronThetaCoords (void)
{
    // Reproduces this matlab code:
    // E2 = 2.5;
    // nfs = 50; // 50x50 grid.
    // Mf = nfs/(E2*log(((window_size/2)/E2)+1));
    // thetax = E2.*(-1+exp(R(:,2)./(Mf.*E2))).*cos(R(:,1).*2.*pi./nfs);
    // thetay = E2.*(-1+exp(R(:,2)./(Mf.*E2))).*sin(R(:,1).*2.*pi./nfs);

    int nrows = this->neuralFieldSize;
    int ncols = nrows;
    int iter = 0;

    // R is a matrix containing cortical X and Y coordinates.
    R.resize (nrows * ncols, 2);
    // Build R up.
    for (int cort_theta = 1; cort_theta <= nrows; ++cort_theta) {
        for (int cort_r = 1; cort_r <= ncols; ++cort_r) {
            R (iter, 0) = cort_theta; // Rotational angle
            R (iter, 1) = cort_r; // Radius
            DBG ("R("<< iter << ") = ("<< cort_theta <<","<<cort_r<<")");
            ++iter;
        }
    }

    double Mf;
    {
        double Mf_numer = static_cast<double>(this->neuralFieldSize);
        // log from math.h is natural log here.
        double Mf_denom = (E2 * log(((static_cast<double>(fieldOfView)/2.0)/E2)+1));
        Mf = Mf_numer / Mf_denom;
        DBG("Mf: " << Mf << " Mf_numer: " << Mf_numer << " Mf_denom: " << Mf_denom);
    }
    double MfE2 = Mf * this->E2;
    DBG("MfE2: " << MfE2);

    VectorXd part1 = this->E2 * ( -1 + (R.col(1)/MfE2).array().exp() );
    VectorXd part2 = R.col(0)*TWOPI/this->neuralFieldSize;
    // Here, thetaX, thetaY are the rotational angles in the eyeframe
    // to the points in real space.
    VectorXd thetaX = part1.array() * part2.array().cos();
    VectorXd thetaY = part1.array() * part2.array().sin();

    // Destructive resize:
    this->preciseNeuronThetaCoords.resize (thetaX.rows(), 2);
    this->preciseNeuronThetaCoords << thetaX , thetaY;

    // Now populate pixelNeuronThetaCoords by rounding the precise neuron locations.
    // pixelNeuronThetaCoords is "relevantPixels" in the matlab code
    this->pixelNeuronThetaCoords = this->preciseNeuronThetaCoords.unaryExpr (ptr_fun (EyeFrame::roundnum));

#ifdef DEBUG_PIXEL_NEURONS
    // This counts the number of neurons in each of up to 2500 neuron
    // locations. Could see the same thing with a uniformly luminant
    // input.  Turns out there are 1203 entries in
    // pixelNeuronsThetaCounts.
    MatrixXi m = this->pixelNeuronThetaCoords.cast<int>();
    std::map<std::pair<int, int>, int> pixelNeuronThetaCounts;

    for (int i = 0; i < this->pixelNeuronThetaCoords.rows(); ++i) {
        std::pair<int, int> key(m(i,0),m(i,1));
        this->pixelNeuronThetaCounts[key] += 1;
    }

    map<pair<int, int>, int>::iterator mj = this->pixelNeuronThetaCounts.begin();
    while (mj != this->pixelNeuronThetaCounts.end()) {
        // Can just use this output as csv input to octave to see the data.
        cout << mj->first.first << "," << mj->first.second << "," << mj->second << endl;
        ++mj;
    }
#endif // DEBUG_PIXEL_NEURONS

    NoChange_t nochange;
    this->pixelNeuronThetaCoords.conservativeResize(nochange, this->preciseNeuronThetaCoords.cols()+1);
    DBG2("pixelNeuronThetaCoords.size: " << pixelNeuronThetaCoords.rows() << "," << pixelNeuronThetaCoords.cols());

    this->preciseNeuronThetaCoords.conservativeResize(nochange, this->preciseNeuronThetaCoords.cols()+1);

#ifdef DEBUG
    for (int i = 0; i < this->pixelNeuronThetaCoords.rows(); ++i) {
        DBG ("(r="<< R(i,1) <<",phi="<<R(i,0)<<") maps to theta_x=" << preciseNeuronThetaCoords(i, 0)
             << ", theta_y=" << preciseNeuronThetaCoords(i, 1));
        DBG2 ("(or pixel coords  :" << pixelNeuronThetaCoords(i, 0) << "," << pixelNeuronThetaCoords(i, 1) << ")");
    }
#endif

#ifdef DEBUG2
    ofstream f;
    f.open ("neuron_coords.dat", ios::out|ios::trunc);
    if (!f.is_open()) {
        cerr << "Can't open neuron_coords.dat; failed to save co-ords." << endl;
        return;
    }
    f << this->preciseNeuronThetaCoords.format (this->OctaveFmt) << flush;
    f.close();
    f.open ("neuron_pixels.dat", ios::out|ios::trunc);
    if (!f.is_open()) {
        cerr << "Can't open neuron_pixels.dat; failed to save co-ords." << endl;
        return;
    }
    f << this->pixelNeuronThetaCoords.format (this->OctaveFmt) << flush;
    f.close();
#endif
}

void
EyeFrame::neuronThetaToCartesian (void)
{
    int nrows = this->preciseNeuronThetaCoords.rows();
    int ncols = 2;

#ifdef DEBUG
    if (this->screenShape == SCREENSHAPE_FLAT) {
        DBG ("Flat screen\n");
    } else if (this->screenShape == SCREENSHAPE_SPHERICAL) {
        DBG ("Spherical screen\n");
    }
#endif

    double dist = static_cast<double>(this->distanceToScreen);
    double negdist = -1 * dist;

    double dtanthetaxrad = 0.0;
    double dsinthetaxrad = 0.0;
    double thetaX, thetaY;
    double thetaXrad = 0.0;
    double thetaYrad = 0.0;

    this->neuronCartesianCoords.resize (nrows, 3);

    for (int row = 0; row < nrows; ++row) {

        thetaX = this->preciseNeuronThetaCoords(row, 0);
        thetaY = this->preciseNeuronThetaCoords(row, 1);
        thetaXrad = static_cast<double>(thetaX) * DEG_TO_RADIANS;

        thetaYrad = static_cast<double>(thetaY) * DEG_TO_RADIANS;

        if (this->screenShape == SCREENSHAPE_FLAT) {
            dtanthetaxrad = dist * tan (thetaXrad);
            this->neuronCartesianCoords (row, 0) = dist * tan (thetaYrad);
            this->neuronCartesianCoords (row, 1) = dtanthetaxrad; // dist * tan (thetaXrad);
            this->neuronCartesianCoords (row, 2) = negdist;

        } else if (this->screenShape == SCREENSHAPE_SPHERICAL) {
            // Note, this dsinthetaxrad gets recomputed many tiomes for
            // the same value of thetaXrad.
            dsinthetaxrad = dist * sin (thetaXrad);
            this->neuronCartesianCoords (row, 0) = dist * sin (thetaYrad);
            this->neuronCartesianCoords (row, 1) = dsinthetaxrad; // dist * sin (thetaXrad);
            this->neuronCartesianCoords (row, 2) = negdist * cos (sqrt (thetaXrad * thetaXrad + thetaYrad * thetaYrad));
#ifdef DEBUG2
            cout << "retinal neuron at x=" << this->neuronCartesianCoords (row, 0)
                 << " y=" << this->neuronCartesianCoords (row, 1)
                 << " z=" << this->neuronCartesianCoords (row, 2)
                 << " For thetaX="<< thetaX << " thetaY=" << thetaY << " dist="
                 << this->distanceToScreen << endl;
#endif
        } else {
            throw runtime_error ("Unknown screen shape");
        }
    }

#ifdef DEBUG
    ofstream f;
    f.open ("neuron_3d_coords.dat", ios::out|ios::trunc);
    if (!f.is_open()) {
        cerr << "Can't open neuron_coords.dat; failed to save co-ords." << endl;
        return;
    }
    f << this->neuronCartesianCoords.format (this->OctaveFmt) << flush;
    f.close();
#endif
}
