#include "brahmscmpt_shared.h"

/*!
 * Initialise static members of Variables at global scope, as
 * Variables has a private constructor:
 */
//@{
bool Variables::instanceFlag = false;
bool Variables::saccsimStarted = false;
bool Variables::brahmsFinished = false;
Variables* Variables::single = NULL;
std::string Variables::bss_data_header = "BST,AMR,ALR,AIR,ASR,ASO,AIO,RX,RY,RZ,RXu,RYu,RZu,SST";
//@}

/*!
 * Implementation of the getInstance public method.
 */
Variables* Variables::getInstance (void)
{
    if (!instanceFlag) {
        single = new Variables();
        instanceFlag = true;
        return single;
    } else {
        return single;
    }
}

bool Variables::getSaccsimStarted (void)
{
    return this->saccsimStarted;
}

void Variables::setSaccsimStarted (const bool& b)
{
    this->saccsimStarted = b;
}

bool Variables::getBrahmsFinished (void)
{
    return this->brahmsFinished;
}

void Variables::setBrahmsFinished (const bool& b)
{
    this->brahmsFinished = b;
}

void Variables::initData (void)
{
    this->brahmsCurrData = this->brahmsSide.rend();
    this->brahmsLastData = this->brahmsSide.rend();
    this->saccsimCurrData = this->saccsimSide.rend();
#ifdef WANT_COMPONENT_TO_OUTPUT_ROTATIONS
    this->saccsimLastData = this->saccsimSide.rend();
#endif
    this->duration = 0;
    this->timestep_size = 0;
    this->simtk_integrator = "";
}
