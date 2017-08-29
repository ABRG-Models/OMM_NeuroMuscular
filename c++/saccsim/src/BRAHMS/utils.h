#ifndef UTILS_H
#define UTILS_H

#include <string>

using namespace std;

#define echo(x) cout<<#x<<" = "<<x<<endl

double getSeconds();
double elapsed(double startTime);
string getExePath();
string getBasePath();

#endif
