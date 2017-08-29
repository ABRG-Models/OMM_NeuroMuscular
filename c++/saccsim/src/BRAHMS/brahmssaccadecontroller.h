#ifndef __BRAHMS_SACCCADE_CONTROLLER_H__
#define __BRAHMS_SACCCADE_CONTROLLER_H__

#include <iostream>
#include <unistd.h>

/*
 * This header provides a shared memory singleton for running in a
 * Brahms component - the class "Variables". This is used in
 * BrahmsSacadeController.
 */
#include "brahmscmpt_shared.h"
#include "saccadesimulator.h"

using namespace notremor;

using namespace std;

class BrahmsSaccadeController : public SaccadeController
{
public:
    BrahmsSaccadeController() {
        this->vars = Variables::getInstance();
    }

private:
    /*!
     * readActivations transfers activations from the shared memory
     * data container pointed to by this->vars->brahmsCurrData into
     * the member variable acts and the function argument activations.
     */
    bool readActivations (const double time,
                          EyeMuscleActivations &activations,
                          vector<double>& saccsimdata) {

        bool rtn (false);

        pthread_mutex_lock (&this->vars->brahmsSideMutex);

        if (this->vars->brahmsLastData != this->vars->brahmsSide.rend()) {
            if (this->vars->brahmsLastData == this->vars->brahmsCurrData) {
                pthread_mutex_unlock (&this->vars->brahmsSideMutex);
                return rtn;
            }
        }

        std::deque<std::vector<double> >::reverse_iterator bd = this->vars->brahmsCurrData;

        // If we compare (*bd)[STEP_TIME] and time and they're very
        // close, we call them the same. This gets around imprecisions
        // in the double/float number container.
        double delta_threshold = this->vars->timestep_size/10000;
        double delta = 0.0;

        while (bd != this->vars->brahmsSide.rend()) {
            if ((*bd)[STEP_TIME] > time) { // times are in seconds.
                // continue (probably)
                delta = (*bd)[STEP_TIME] - time;
                if (delta < delta_threshold) { // Perhaps needs to be runtime-configurable threshold.
                    //cout << "saccadescene.h: (*bd)[STEP_TIME]=" << (*bd)[STEP_TIME]
                    //     << " == time=" << time << " (delta=" << delta << "); break" << endl;
                    break;
                } else {
                    //cout << "saccadescene.h: (*bd)[STEP_TIME]=" << (*bd)[STEP_TIME]
                    //     << " > time=" << time << " (delta=" << delta << ")" << endl;
                }
            } else { // The brahms timae is now <= to the simulation time.
                //cout << "saccadescene.h: (*bd)[STEP_TIME]=" << (*bd)[STEP_TIME]
                //     << " <= time=" << time << "; break" << endl;
                break;
            }
            ++bd;
        }

        if (bd != this->vars->brahmsSide.rend()) {
            saccsimdata[STEP_TIME] = (*bd)[STEP_TIME];
            acts.act_med_rect = (*bd)[ACT_MEDRECT];
            acts.act_lat_rect = (*bd)[ACT_LATRECT];
            acts.act_inf_rect = (*bd)[ACT_INFRECT];
            acts.act_sup_rect = (*bd)[ACT_SUPRECT];
            acts.act_sup_obliq = (*bd)[ACT_SUPOBL];
            acts.act_inf_obliq = (*bd)[ACT_INFOBL];
            activations = acts;
            this->vars->brahmsLastData = bd;
            rtn = true;
        } else {
            // Need to wait for activations.
        }

        pthread_mutex_unlock (&this->vars->brahmsSideMutex);

        return rtn;
    }

public:
    void control(const double time,
        const double rotX, const double rotY, const double rotZ,
        const double rotXu, const double rotYu, const double rotZu,
        EyeMuscleActivations &activations)
    {
        // We are given the time, from that can obtain the variable time step.
        vector<double> saccsimdata;
        saccsimdata.resize(SIM_DATA_SZ);
        saccsimdata.assign(SIM_DATA_SZ, 0.0);
        saccsimdata[SACCSIM_TIME] = time;

        bool gotact = false;
        while ((gotact = this->readActivations (time, activations, saccsimdata)) == false
               && this->vars->getBrahmsFinished() == false) {
            // Wait a short while, to get the activations later
            usleep (100);
        }

        // Now update rotations.
#ifdef __DEBUG
        cout << "brahmssaccadecontroller.h: time: " << time << ", acts (up/down): "
             << acts.act_sup_rect << "/" << acts.act_inf_rect
             << ", rotX: " << rotX
             << ", rotY: " << rotY
             << ", rotZ: " << rotZ << endl;
#endif
        // First, place rotations into a holding data structure.
        saccsimdata[ROT_X] = rotX * RADIANS_TO_DEGREES;
        saccsimdata[ROT_Y] = rotY * RADIANS_TO_DEGREES;
        saccsimdata[ROT_Z] = rotZ * RADIANS_TO_DEGREES;
        saccsimdata[ROT_XU] = rotXu * RADIANS_TO_DEGREES;
        saccsimdata[ROT_YU] = rotYu * RADIANS_TO_DEGREES;
        saccsimdata[ROT_ZU] = rotZu * RADIANS_TO_DEGREES;

        // Store what we determined to be our closest activations:
        saccsimdata[ACT_MEDRECT] = acts.act_med_rect;
        saccsimdata[ACT_LATRECT] = acts.act_lat_rect;
        saccsimdata[ACT_INFRECT] = acts.act_inf_rect;
        saccsimdata[ACT_SUPRECT] = acts.act_sup_rect;
        saccsimdata[ACT_SUPOBL] = acts.act_sup_obliq;
        saccsimdata[ACT_INFOBL] = acts.act_inf_obliq;

        pthread_mutex_lock (&this->vars->saccsimSideMutex);
        this->vars->saccsimSide.push_back (saccsimdata);
        this->vars->saccsimCurrData = this->vars->saccsimSide.rbegin();
        pthread_mutex_unlock (&this->vars->saccsimSideMutex);

        // Write to file
        if (this->vars->fsaccsim.is_open()) {
            this->vars->fsaccsim << (*this->vars->saccsimCurrData)[0];
            for (int k = 1; k < SIM_DATA_SZ; ++k) {
                this->vars->fsaccsim << "," << (*this->vars->saccsimCurrData)[k];
            }
            this->vars->fsaccsim << endl;
        }

        //cout << "saccadescene.h: Recorded data in saccsimSide, control now finished." << endl;
    }

    void setActivation (int mi, double a) { acts.act[mi] = a; }

    void setActivations (EyeMuscleActivations &acts_) { acts = acts_; }

    void getActivations(EyeMuscleActivations &acts_) {acts_ = acts;}

private:
    EyeMuscleActivations acts;
    Variables* vars;
};


#endif
