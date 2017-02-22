#include "ofMain.h"
#include "ofApp.h"
#include "ofAppGlutWindow.h"

//========================================================================
int main( ){

    ofGLFWWindowSettings settings;
    settings.width = 800;
    settings.height = 600;
    settings.resizable = false;
    settings.setGLVersion(4,1); /// < select your GL Version here
    ofCreateWindow(settings);
    
	ofRunApp( new ofApp());
}
