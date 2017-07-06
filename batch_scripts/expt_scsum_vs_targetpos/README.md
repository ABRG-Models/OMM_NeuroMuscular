I'm now running the widening gaussian experiments but recording scsum
rather than llbn.

WG1
---

First I used the TModel1 at git commit a267465, which has one to one
for FEF_add_noise->FEF, and Gaussian Kernels for SCs->SCd and SCd
recurrent.

Now I'll move to using the widening Gaussians, using my latest
widening gaussian with the normalisation. Here, I'll apply the
widening gaussian only to FEF_add_noise->FEF and SC_sup->SC_deep. I'll
leave the SC_deep recurrent connectivity as the same gaussian kernel
it always was.

The params for the two WG connections are sigma=variable, E2=2.5,
rshift=5, normpower=1.5. The postsynapse weight for FEF_add_noise to
FEF is 0.2 and the postsynapse weight for the SC_sup to SC_deep
connection is 0.5.

Results are that this doesn't change the gradient of the line for
scsum vs. Targ Y.

WG2
---

Now I'll set the FEF_add_noise->FEF and SC_sup->SC_deep as above, but
with fixed sigma=15.

I'll then work through different widening gaussians for the SC_deep
recurrent connection.

WG3
---

Investigating the effect of the normpower parameter. Does it give me
the even SC_deep activity that I'm trying to produce? Answer - no.

WG4
---

Now there are WG connections on:

FEF_add_noise -> FEF
SC_s -> SC_d
SC_d recurrent
FEF -> SC_d
SC_s -> Thalamus ****

And this finally begins to have an effect on the size of the hill in
SCdeep!

WG5
---

Reverting FEF->SC_d connection to regular GaussianKernel to see if it
was part of the solution. Would like as few WG connections as possible
to find out those that are critical.

WG6
---

Further to WG5, revert the SC_deep recurrent connection to a regular
GaussianKernel.

WG7
---
Now lets un-Widen the SC_s to SC_d connection, reverting it back to its
original regular GaussianKernel.

WG8
---
FEFaddnoise->FEF is reverted to Gaussian Kernel

WG9
---
SCs->Thal is reverted to one-to-one

WG10
----
FEFaddnoise->FEF is switched to Widening Gaussian

WG11
----
SCs->Thal is switched to Widening Gaussian

plot_scsum_vs_t_vs_WG456.m shows three connectivity schemes from 
results/WG4, WG5 and WG6

plot_scsum_vs_t_vs_WG.m shows all connectivity scheme results

plot_scsum_vs_t_vs_WG_selected.m shows selected, important connectivity 
schemes. Legends should explain.
