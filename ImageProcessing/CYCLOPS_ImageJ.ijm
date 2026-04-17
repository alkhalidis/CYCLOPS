dir1 = getDirectory("Choose Source Directory "); //select raw image directory
dir2 = getDirectory("_Choose Destination Directory "); //select directory to save final mutiplex images
dir3 = getDirectory("__Choose Destination Directory "); //select directory to save final nuclear images for segmentation

Channelnames=File.openAsRawString("enter/directory/of/channel_names.txt"); //insert directory of text file containing channel names
Channelnames=split(Channelnames, "\n");
list = getFileList(dir1); 
setBatchMode(true); 
for (i=0; i<list.length; i=i+1) {    
	showProgress(i+1, list.length);    
	filename = dir1 + list[i];
	open(filename);
		filename2=getTitle();
		run("HyperStackReg ", "transformation=Translation channel show");
		rename("registered");
		run("Reduce Dimensionality...", "frames keep");
		run("Stack to Hyperstack...", "order=xyczt(default) channels=7 slices=1 frames=1 display=Color"); //change "channels" value to reflect the number of cycles
		run("Z Project...", "projection=[Min Intensity]");
		rename("nuclear");
		selectWindow("registered");
		run("Delete Slice", "delete=channel");
		run("Stack to Hyperstack...", "order=xyczt(default) channels=21 slices=1 frames=1 display=Color"); //change "channels" value to reflect the number of targets imaged, excluding the nuclear channel
		rename("finalchannels");
		run("Concatenate...", "image1=nuclear image2=finalchannels image3=[-- None --]");
		run("Subtract Background...", "rolling=50 stack");
		
		//To change channel names:
		for (c = 0; c < Channelnames.length; c=c+1) {
			Stack.setChannel(c);
			setMetadata("Label", ""+Channelnames[c]);
		}
		
		saveAs("Tiff", dir2+filename2);
		run("Make Subset...", "channels=1");
		saveAs("Tiff", dir3+filename2);
		
   		close("*");  
   		

}
