Extracted from Oculomotor branch of abrg_local repository on 3rd May 2017.

To run this model fully, you need the saccsim biomechanical eye (currently a
private repository) and the NoTremor_Oculomotor_201603 branch of SpineML_2_BRAHMS.

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

TModel0: A model with the theoretical SG->SBG transfer function as in Tabareau
         et al.

TModel1: Like TModel0, but with a modification to improve the oblique saccades

TModel2: To be like TModel0 with WideningGaussian from SC_deep to SC_deep2 and
         a demonstrations that this resolves problems in TModel0.
