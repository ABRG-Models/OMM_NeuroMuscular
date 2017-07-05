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
