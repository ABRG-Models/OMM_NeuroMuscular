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
        and from SC_sup to SC_deep. This is the most successful model.
