This is the James et al. oculomotor model. The main paper for this
model is "Integrating brain and biomechanical models - a new paradigm
for understanding neuro-muscular control". The paper can be found at
papers/integration/omm_integ.pdf

To run this model fully, and reproduce the results, you need the
saccsim biomechanical eye, BRAHMS and SpineML_2_BRAHMS. To view the
models, you need SpineCreator.

To install SpineCreator, BRAHMS, SpineML_2_BRAHMS (and also
SpineML_PreFlight), please refer to the instructions at
http://spineml.github.io/spinecreator/sourcelin/ Note that these are
build instructions for Linux, and they explain how to build the
following programs from github:

https://github.com/BRAHMS-SystemML/brahms

https://github.com/SpineML/SpineML_PreFlight

https://github.com/SpineML/SpineML_2_BRAHMS

https://github.com/SpineML/SpineCreator

Each of these repositories have a tag 'James_omm_integ' which tag the
state of the repositories when the paper was submitted. In principle,
the latest version of each should be able to reproduce the results of
the paper, but to be sure, it is probably a good idea to checkout the
James_omm_integ branches whilst building.

The saccsim eye model code as used for the paper results is available
within this repository in the subdirectory c++/saccsim. Instructions
for building the saccsim BRAHMS component is in
c++/saccsim/README.md

To build our worldDataMaker component, and some tests of the c++
classes that are used in that code, do the following:

```bash
cd c++
mkdir build
cd build
cmake ..
make -j4
```

Now you'll have some BRAHMS components that you need to copy into your
'BRAHMS Namespace' which, if you've compiled brahms according to the
instructions mentioned above, will be at:

```bash
/usr/local/var/SystemML/Namespace
```

Copy in the skeleton BRAHMS NoTremor namespace:

```bash
cp -Ra c++/brahms_namespace/NoTremor /usr/local/var/SystemML/Namespace/dev/
```

Now you can copy your newly compiled components into the NoTremor
namespace:

worldDataMaker:
```bash
cp c++/build/worldDataMaker.so \
   /usr/local/var/SystemML/Namespace/dev/NoTremor/worldDataMaker/brahms/0/component.so
```

Centroiding components:
```bash
cp c++/build/centroid.so \
   /usr/local/var/SystemML/Namespace/dev/NoTremor/centroid/brahms/0/component.so
cp c++/build/powercentroid.so \
   /usr/local/var/SystemML/Namespace/dev/NoTremor/powercentroid/brahms/0/component.so
cp c++/build/multicentroid.so \
   /usr/local/var/SystemML/Namespace/dev/NoTremor/multicentroid/brahms/0/component.so
```

Saccsim:
```bash
cp c++/saccsim/src/build/BRAHMS/component.so \
   /usr/local/var/SystemML/Namespace/dev/NoTremor/saccsim/brahms/0/component.so
```

If I didn't miss anything out of these instructions, you should now be
able to run the models (from the experiments interface of SpineCreator
or from the SpineML_2_BRAHMS command line program
'convert_script_s2b'), which are:

The 'ModelN' models were those which were used to develop a training
procedure for the SC_deep to LLBN weight maps. I also used some of
these to investigate a widening projection field *within* the brain
model, before abandoning this idea.

Model1: This is the model with no centroiding component, and no widening
        Gaussian projective fields. It's the naive model which demonstrates
        the issue whereby the retinotopic projection affects the size of the
        hill of activity in SC_deep (the experimental observation is that the
        size of this hill of activity is invariant wrt its position).

Model2: This is the model with the centroiding component between SC_deep and
        SC_avg and is the model used to compute the weight maps from SC_avg
        to the SBG

Model3: This is the model with a non-centroided connection from SCdeep to the
        SBG. It has a widening Gaussian projection from FEF_add_noise to FEF
        and from SC_sup to SC_deep. I've tried to optimise this model to make
        the best, most linear vertical movements (Rotations about X).

Model4: Like Model3, but parameters modified to give this the most linear
        horizontal movements (rotations about Y).

Model5: A copy of 4, which I will tweak to try to get vertical rotations to
        work reasonably well in conjunction with horizontal rotations.

The TModel0-2 models were a first set of models employing the
theoretical weight mapping from Ottes et al. and Tabareau et al.

TModel0: A model with the theoretical SG->SBG transfer function as in Tabareau
         et al. Legacy.

TModel1: Like TModel0, but with a modification to improve the oblique
         saccades. Legacy.

TModel2: To be like TModel0 with WideningGaussian from SC_deep to SC_deep2 and
         a demonstrations that this resolves problems in TModel0. Legacy.

From the perspective of the paper, TModel3-5 are the only ones that matter.

TModel3: Back to the naive model - Model1 - but with the
         exponential/sine wave weight maps predicted by the Ottes
         mapping and Tabareau et al. 2007.

TModel4: To TModel3 is added a widening Gaussian projection field from
         SC_deep to a new layer, SC_deep2.

TModel5: This adds a mechanism to reset the TN firing in the SBG,
         which was missing in the first iteration of the SBG.

Note: This repository was extracted from Oculomotor branch of our
private abrg_local repository on 3rd May 2017, with a view to making
it public with the paper. Earlier history on model/code changes is
held there.
