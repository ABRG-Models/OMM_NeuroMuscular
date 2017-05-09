
#PARNAME=sigma #LOC=1,1
#HASWEIGHT

def connectionFunc(srclocs,dstlocs,sigma):

	import math
	
	normterm = 1/(sigma*math.sqrt(2*math.pi))

	i = 0
	out = []
	for srcloc in srclocs:
		j = 0
		for dstloc in dstlocs:
			dist = math.sqrt(math.pow((srcloc[0] - dstloc[0]),2) + math.pow((srcloc[1] - dstloc[1]),2) + math.pow((srcloc[2] - dstloc[2]),2))
			gauss = normterm*math.exp(-0.5*math.pow(dist/sigma,2))
			if gauss &gt; 0.001:
				conn = (i,j,0,gauss)
				out.append(conn)
			j = j + 1
		i = i + 1
	return out

