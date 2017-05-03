The matlab scripts here produce input for the model, and also consume 
the output and display it in some figures.

worldDataMaker.m is the script which generates the input activations. 
These are passed into the WorldToBrain population, which then passes the 
data through into both Retina_1 and Retina_2 via two connections (with 
different weights and connection maps). Once the model has been run, 
worldDataMaker.m displays some figures with the results of the model.

The input data is passed to the SpineML model using the TCP/IP external 
connection functionality built into SpineML_2_BRAHMS, which is 
configured in SpineCreator. In this scheme, the model opens network 
connections to a data server. The data server either delivers data to 
the model for model inputs, or consumes data output by the model.

The data server in use here is called "spinemlnet", and it's written for 
matlab. It's available in the SpineCreator source code under 
networkserver/matlab. The spinemlnet_run1.m source code file requires 
that the spinemlnet mex functions are available in your matlab path. See 
the start of worldDataMaker.m for a line which adds this path.

The mapping of the sheets in the brain model is described in the
publications associated with this model. It's a 50 by 50 cortical
sheet with columns encoding radial eccentricity between 0 and 75
degrees and rows encoding rotational angle from vertical in 50
divisions.

Load a cortical map into octave and do a surface plot, then annotate
it like this:

xlabel ('col encodes r');
ylabel ('row encodes theta');

SpineCreator stuff: Choose the "Net in, file out" experiment in
SpineCreator.

SpineML_2_BRAHMS stuff: Select the NoTremor_Incorp_Saccsim branch,
which incorporates the saccsim brahms component into the model.
