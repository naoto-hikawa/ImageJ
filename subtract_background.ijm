// Select a directory containing .tif files (not a stack, single channel and single plane) that you want to subtract background for.
path    = getDirectory("Choose a Directory");
list    = getFileList(path);
length  = list.length;

csv_dir = path + "csv";
File.makeDirectory(csv_dir);

cor_dir = path+"bg_corrected";
File.makeDirectory(cor_dir);

bg_roi = path+"bg_roi";
File.makeDirectory(bg_roi);
run("Close All"); 

roiManager("reset");

for (i=0; i<length; i++) {
	if (!endsWith(list[i], ".tif")) {
		continue;
	}
	
	open(path+list[i]);
    img = File.nameWithoutExtension();
    selectWindow(img+".tif");
  	run("ROI Manager...");
  	
  	rois = bg_roi+File.separator+img+"_ROIs.zip";
	
	if (!File.exists(rois)) { 
		// If you make a mistake somewhere in choosing BG, you can delete the ROI file, restart the macro, and it will 
		// check for all the ROIs you have already chosen.
		
		makebgROI(200,200); // You can change the size of the BG rectangle. Put positive integers only
	}
  	
  	else {
  		open(rois);
  	}
    
  	roiManager("select", 0);
  	run("Set Measurements...", "area mean min integrated display redirect=None decimal=3");
  	roiManager("measure");
  	saveAs("Results", csv_dir + File.separator +img+".csv");
    run("Close");
  	getStatistics(area, mean);
  		
    
    run("Select None");
    run("Subtract...", "stack value="+mean);
    c_name = cor_dir + File.separator + img;
    saveAs("Tiff", c_name);
    run("Close All"); 
    roiManager("reset");
    }
    
    
function makebgROI(w,h) {
	
	if (w<1 || h<1) {
		print("Invalid background dimension");
		exit;
	}
	
	keep_going = true;
   	px=0;
    py=0;

	while (keep_going){ 
		Dialog.create("Instructions");
		Dialog.addCheckbox("Set a better BG rectangle?", true);	
		Dialog.show();
		keep_going = Dialog.getCheckbox;
			
		if (!keep_going){
			break;
		}
			
		setTool("point");
		// Not selecting any point will set the background in left upper corner of the image.
	    waitForUser("Please select a center point. Click OK when done"); 
	    coord = Roi.getCoordinates(x,y);
	    px = x[0]-w/2;
	    py = y[0]-h/2;
	    px = Math.max(0, px);
	    py = Math.max(0, py);
	    makeRectangle(px, py, w, h); 
		    
	}
		
	run("Specify...", "width=w height=h x=px y=py");
	roiManager("Add");
	roiManager("Save", rois);
	run("Select None");	
}
