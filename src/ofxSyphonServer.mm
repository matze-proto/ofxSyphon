/*
 *  ofxSyphonServer.cpp
 *  syphonTest
 *
 *  Created by astellato,vade,bangnoise on 11/6/10.
 *
 *  http://syphon.v002.info/license.php
 */

#include "ofxSyphonServer.h"
#import <Syphon/Syphon.h>

ofxSyphonServer::ofxSyphonServer()
{
	mSyphon = nil;
}

ofxSyphonServer::~ofxSyphonServer()
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    [(SyphonServer *)mSyphon stop];
    [(SyphonServer *)mSyphon release];
    
    [pool drain];
}


void ofxSyphonServer::setName(string n)
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
	NSString *title = [NSString stringWithCString:n.c_str()
										 encoding:[NSString defaultCStringEncoding]];
	
	if (!mSyphon)
	{
		mSyphon = [[SyphonServer alloc] initWithName:title context:CGLGetCurrentContext() options:nil];
	}
	else
	{
		[(SyphonServer *)mSyphon setName:title];
	}
    
    [pool drain];
}

string ofxSyphonServer::getName()
{
	string name;
	if (mSyphon)
	{
		NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        
		name = [[(SyphonServer *)mSyphon name] cStringUsingEncoding:[NSString defaultCStringEncoding]];
		
		[pool drain];
	}
	else
	{
		name = "Untitled";
	}
	return name;
}

void ofxSyphonServer::stop()
{
    [(SyphonServer *)mSyphon stop];
    [(SyphonServer *)mSyphon release];
    mSyphon = nil;
}

void ofxSyphonServer::publishScreen()
{
	int w = ofGetWidth();
	int h = ofGetHeight();
	
	ofTexture tex;
	tex.allocate(w, h, GL_RGBA);
	
	tex.loadScreenData(0, 0, w, h);
    
	this->publishTexture(&tex);
	
	tex.clear();
}

void ofxSyphonServer::publishFBO(ofFbo* inputFbo){
    // If we are setup, and our input texture
    if(inputFbo->isAllocated())
    {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        
        if (!mSyphon)
        {
            mSyphon = [[SyphonServer alloc] initWithName:@"Untitled" context:CGLGetCurrentContext() options:nil];
        }
        SyphonServer *ss = static_cast<SyphonServer*>(mSyphon);
        CGLLockContext(ss.context);
        CGLSetCurrentContext(ss.context);
        NSSize size;
        size.width = inputFbo->getWidth();
        size.height = inputFbo->getHeight();
        [ss bindToDrawFrameOfSize:size];
        GLint syFBO;
        glGetIntegerv(GL_FRAMEBUFFER_BINDING, &syFBO);
        glBindFramebuffer(GL_READ_FRAMEBUFFER, inputFbo->getFbo());
        glBindFramebuffer(GL_DRAW_FRAMEBUFFER, syFBO);
        
        glBlitFramebuffer(0, 0, size.width, size.height,
                          0, 0, size.width, size.height,
                          GL_COLOR_BUFFER_BIT, GL_LINEAR);
        [ss unbindAndPublish];
        CGLUnlockContext(ss.context);
        
        [pool drain];
    }
    else
    {
        cout<<"ofxSyphonServer FBO is not properly backed.  Cannot draw.\n";
    }
}

void ofxSyphonServer::publishTexture(ofTexture* inputTexture)
{
    // If we are setup, and our input texture
	if(inputTexture->isAllocated())
    {
        NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
        
		ofTextureData texData = inputTexture->getTextureData();
        
		if (!mSyphon)
		{
			mSyphon = [[SyphonServer alloc] initWithName:@"Untitled" context:CGLGetCurrentContext() options:nil];
		}
		
		[(SyphonServer *)mSyphon publishFrameTexture:texData.textureID textureTarget:texData.textureTarget imageRegion:NSMakeRect(0, 0, texData.width, texData.height) textureDimensions:NSMakeSize(texData.width, texData.height) flipped:!texData.bFlipTexture];
        [pool drain];
    }
    else
    {
		cout<<"ofxSyphonServer texture is not properly backed.  Cannot draw.\n";
	}
}

void ofxSyphonServer::publishTexture(GLuint id, GLenum target, GLsizei width, GLsizei height, bool isFlipped)
{
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
    
    if (!mSyphon)
    {
        mSyphon = [[SyphonServer alloc] initWithName:@"Untitled" context:CGLGetCurrentContext() options:nil];
    }
    
    [(SyphonServer *)mSyphon publishFrameTexture:id textureTarget:target imageRegion:NSMakeRect(0, 0, width, height) textureDimensions:NSMakeSize(width, height) flipped:!isFlipped];
    [pool drain];
    
}
