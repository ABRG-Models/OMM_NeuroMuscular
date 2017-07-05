#PARNAME=sigma #LOC=1,1
#PARNAME=E2 #LOC=1,2
#PARNAME=rshift #LOC=2,1
#PARNAME=normpower #LOC=2,2
#HASWEIGHT

def connectionFunc(srclocs,dstlocs,sigma,E2,rshift,normpower):

  import math

  # Corrected normterm (2015/01/16):
  # normterm = 1/(math.pow(sigma,2)*2*math.pi)

  # E2 can be tweaked for best result.
  #E2 = 2.5
  W_nfs = 50

  _rshift = 2
  #magfacshift = 5

  M_f_start =  W_nfs / (E2 * math.log (((_rshift+rshift)/(2*E2))+1))
    
  i = 0
  out = []
  for srcloc in srclocs:
    j = 0
    # Compute the location of srcloc, this defines what sigma will be. As r (as opp. to phi) increases, the sigma should increase.
    M_f =  W_nfs / (E2 * math.log (((_rshift+srcloc[1])/(2*E2))+1))

    # Set some of M_f to 1 to ensure the fan-out starts at around the edge of the foveal region.
    if srcloc[1] < rshift:
        M_f = M_f_start
    
    _sigma = sigma/M_f # as function of r, aka srcloc[1]
    normterm = 1/math.pow(_sigma,normpower)

    for dstloc in dstlocs:

      dist = math.sqrt(math.pow((srcloc[0] - dstloc[0]),2) + math.pow((srcloc[1] - dstloc[1]),2) + math.pow((srcloc[2] - dstloc[2]),2))

      gauss = normterm*math.exp(-0.5*math.pow(dist/_sigma,2))

      if gauss > 0.001:
        #sys.stdout.write('gauss>0.0001: i={0} gauss={1}'.format( i, gauss))
        conn = (i,j,0,gauss)
        out.append(conn)

      j = j + 1
    i = i + 1
  #sys.stdout.write('out length: %d' % len(out))
  return out
