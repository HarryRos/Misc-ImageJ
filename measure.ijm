/*
	 Copyright 2017 University of Southampton
	 Charalambos Rossides
	 Bio-Engineering group
	 Faculty of Engineering and the Environment

	 Licensed under the Apache License, Version 2.0 (the "License");
	 you may not use this file except in compliance with the License.
	 You may obtain a copy of the License at

	     http://www.apache.org/licenses/LICENSE-2.0

	 Unless required by applicable law or agreed to in writing, software
	 distributed under the License is distributed on an "AS IS" BASIS,
	 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
	 See the License for the specific language governing permissions and
	 limitations under the License.

	------------

	ImageJ/FiJi macro to measure the SNR and CNR of an image that depicts two objects (Tissue and Background).
	The macro allows the user to preset the ROI for the tissue and the background, but it also facilitates
	direct interaction with the GUI.
	The measurements are shown in the console and they are optionally saved in a predifined textfile as well.
	If the textfile path does not exist or it is empty, the user will be prompted to select one and its path
	will be exported on the screen. This allows for the path variable to be set from that point on and 
	automatically appent every new measurement on the predefined file.
	
*/

requires("1.39r");

// Define the path of the file to store the measurements
saveToFile = false;
path = "\\\\filestore.soton.ac.uk\\users\\cr1v16\\mydesktop\\t2.txt"

// Define the ROI where used to calculate Means and Std
BoxSize = 50;
TissueBoxPosX = 622;//638;
TissueBoxPosY = 463;//760;
BkgBoxPosX = 518;
BkgBoxPosY = 1001;

// Working on active image
ID = getImageID();
run("16-bit"); 
selectImage(ID); 
print("======== Measurement ========");

// Measure the tissue
makeRectangle(TissueBoxPosX, TissueBoxPosY, BoxSize, BoxSize);
waitForUser("Select tissue", "Move the box over the tissue and hit \"OK\".");
selectImage(ID); 
Roi.getBounds(TissueBoxPosX, TissueBoxPosY, TissueBoxPosW, TissueBoxPosH);
run("Measure");
MeanSamp = getResult("Mean");
StdSamp = getResult("StdDev");

// Measure the background
makeRectangle(BkgBoxPosX, BkgBoxPosY, BoxSize, BoxSize);
waitForUser("Select tissue", "Move the box over the wax and hit \"OK\".");
selectImage(ID);
Roi.getBounds(BkgBoxPosX, BkgBoxPosY, BkgBoxPosW, BkgBoxPosH);
run("Measure");
MeanBkg = getResult("Mean");
StdBkg = getResult("StdDev");

// Calculate SNR and CNR
SNR = MeanSamp/StdBkg;
CNR = (MeanSamp-MeanBkg)/sqrt(0.5*(StdSamp*StdSamp+StdBkg*StdBkg));

// Output the result
imgTitle = getTitle();
print("Image: ", imgTitle);
print("Tissue box position & size: ", TissueBoxPosX, ",", TissueBoxPosY, ",", TissueBoxPosW, ",", TissueBoxPosH);
print("Background box position & size: ", BkgBoxPosX, ",", BkgBoxPosY, ",", BkgBoxPosW, ",", BkgBoxPosH);
print("SNR = ", SNR);
print("CNR = ", CNR);

if (saveToFile){
	Dialog.create("")
	Dialog.addMessage("Accept measurement and save to file?")
	Dialog.show()
	
	// Save the measurements to the log file
	measurement = d2s(SNR,6) + "  \t" + d2s(CNR,6) + " \t" + d2s(TissueBoxPosX,0)+ " \t" + d2s(TissueBoxPosY,0)+ " \t" + d2s(TissueBoxPosW,0)+ " \t" + d2s(TissueBoxPosH,0)+ " \t" + d2s(BkgBoxPosX,0)+ " \t" + d2s(BkgBoxPosY,0)+ " \t" + d2s(BkgBoxPosW,0)+ " \t" + d2s(BkgBoxPosH,0)+ " \t" + imgTitle;
	if (path=="" || !path || !File.exists(path)){
		path = File.openDialog("Please select the logfile to save the measurement.");
		File.append("SNR\tCNR\tTissueBoxPosX\tTissueBoxPosY\tTissueBoxPosW\tTissueBoxPosH\tBkgBoxPosX\tBkgBoxPosY\tBkgBoxPosW\tBkgBoxPosH\tImage", path);
		File.append(measurement, path);	
		print("Measurements logfile path: ", path);
	}else{	
		File.append(measurement, path);	
}
}

