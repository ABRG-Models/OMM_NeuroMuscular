# Simulation & Visualization of saccadic eye movements #

### Compatible Platforms ###
* Windows (Visual Studio 2010/2013)
* Linux 
* MacOSX 

### Dependencies ###

* [OpenSim 3.2](http://opensim.stanford.edu/)
* [Qt 5](http://www.qt.io/download-open-source/)
* [VTK 6 - Requires build from source with Qt5 support](http://www.vtk.org/VTK/resources/software.html)

### Who do I talk to? ###

* [Simulation: Chris Papapavlou](mailto:chrispapapaulou@ece.upatras.gr)
* [Visualization: Iason Nikolas](mailto:iason.nikolas@ece.upatras.gr)
* [BRAHMS: Stanev and James](mailto:stanev@ece.upatras.gr)

### How to build brahms component ###

!!Important!! configure build directory to be in the directory root/build/release. If you choose to build BRAHMS only, 
you don't need VTK or Qt, check CMakeLists. There are some absolute variables in component.cpp and in
test_brahms.

#### Compiling Simbody and OpenSim

Download the Simbody and OpenSim source code.

I used Simbody 3.3.1 and OpenSim 3.2.

They use cmake for compilation and so the compile procedure is:

Online build instructions are here, though these don't cover simbody:

http://simtk-confluence.stanford.edu:8080/display/OpenSim/Building+OpenSim+from+Source

Install prerequisites:

sudo aptitude install build-essential freeglut3-dev cmake subversion \
                      libxmu-dev libxi-dev liblapack-dev libblas-dev

Procedure for each is the same:

~~~{.bash}
cd src # location of both opensim and simbody source code
cmake-gui
~~~

Browse for the source (e.g. ~/src/simbody-Simbody-3.3.1)

Enter a build location (e.g. ~/src/simbody-build)

Press the Configure button.

Choose "Unix Makefiles" and "Use default native compilers" in the resulting
window and press "Finish".

I left CMAKE_INSTALL_PREFIX as "/usr/local".

Press "Generate" to create the makefiles.

~~~{.bash}
cd simbody-build
make -j8
sudo make install
~~~

#### Compiling saccsim

On Linux/Debian 7:

Get Qt 5.2.1 using the Qt binary installer. Put it in your home directory.

Get qwt 6.1.x, compile and install in your home directory. I put it in
$HOME/Qt/qwt-6.1.0

NB: To build qwt against the Qt 5.2.1 in your home directory, run
qmake from that version of Qt in qwt.

Build and install OpenSim and SimTk. I installed them with the prefix
/usr/local

Build and install MathGeoLib. I built from the source as checked out
from github, and simply copied the MathGeoLib headers into
/usr/local/include/ and copied libMathGeoLib.a into /usr/local/lib/

I added this:

~~~
set(CMAKE_CXX_FLAGS "-fPIC")
~~~

to CMakeLists.txt in MathGeoLib so that it can be linked into the
shared object comonent.so for brahms.

Lastly, find libSOIL. On Debian, it's just a case of aptitude install libsoil-dev.
On HPC, where it is absent, I'm going to copy it from Debian 7 and hope. That was ok
though I had to add a line in CMakeLists.txt in Scene3D/ to add my $HOME/usr/include dir to the
include path:

~~~{.bash}
# This line to compile on Iceberg
include_directories(/home/pc1ssj/usr/include)
# Plus add this to link:
link_directories(~/usr/lib)
target_link_libraries(scene3D SOIL)
~~~

Now, in the Saccsim source directory:

Edit CMakeLists.txt and ensure CMAKE_LIBRARY_PATH points to your Qt
library directory.

~~~{.bash}
# Create and cd to a build directory
mkdir build
cd build
# Tell cmake where it should find OpenSim and qwt:
export OPENSIM_HOME=/usr/local
export QWT_HOME=$HOME/Qt/qwt-6.1.0
# Now you can run cmake without -i:
cmake ..
# If that worked, you can now compile:
make -j2
~~~

To make a BRAHMS-only build of saccsim, call cmake with
-DBUILD_ONLY_BRAHMS=ON. This means you can ignore the Qt, Qwt 
and mathgeolib stuff.

~~~{.bash}
# Create and cd to a build directory
mkdir build
cd build
# Tell cmake where it should find OpenSim:
export OPENSIM_HOME=/usr/local
# Now you can run cmake without -i:
cmake -DBUILD_ONLY_BRAHMS=ON ..
# If that worked, you can now compile:
make -j2
~~~
