package com.littlereddevshed.androidEngine;

import org.libsdl.app.SDLActivity; 
import android.view.*;

import android.util.Log;
import java.util.Arrays;
import android.os.Bundle;

import java.io.InputStream;
/* 
 * A sample wrapper class that just calls SDLActivity 
 */ 

public class Engine extends SDLActivity {

	protected static Engine mSingleton;
    // Setup
    @Override
    protected void onCreate(Bundle savedInstanceState) {
    	//create a static instance to allow us indefinite access to the resources bundled with the android mainActivity API
    	mSingleton = this;
        Log.v("Engine", "onCreate():" + mSingleton);
        super.onCreate(savedInstanceState);
    }	

    protected static String readFile(String filename) throws Exception{
    	//split directory name from file name to work with the android getAsset() API
    	int directoryIndex=filename.lastIndexOf("/");
    	String directory = "";
    	if(directoryIndex != -1){
			directory=filename.substring(0, directoryIndex);
    	}
		
		String file = filename.substring(directoryIndex+1);

		//if file exists in directory, return it's contents as a string. Otherwise return empty string
    	if(Arrays.asList(mSingleton.getAssets().list(directory)).contains(file)){
			InputStream istream = mSingleton.getAssets().open(filename);
			int size = istream.available();
			byte[] buffer = new byte[size];
			istream.read(buffer);
			istream.close();

			return new String(buffer);
		}else{
			return "";
		}

    }
}