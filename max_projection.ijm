// Select a directory containing nd2 files. Change line 17 to ".lif" if the format is LIF
path    = getDirectory("Choose a Directory");
list    = getFileList(path);
length  = list.length;
par = File.getParent(path);

File.makeDirectory(path+"tmp");
tmp = path+File.separator+"tmp";
out1 = File.getParent(tmp);
File.delete(tmp);
max_dir = out1+"_MAX"
File.makeDirectory(max_dir);
run("Close All"); 


for (i=0; i<length; i++) {
	if (!endsWith(list[i], ".nd2")) {
		print(list[i]);
		continue;
	}
	name = path+list[i];

    run("Bio-Formats", "open=[name] autoscale split_channels color_mode=Default view=Hyperstack stack_order=XYCZT use_virtual_stack");
    maxproject(name);
    }



function maxproject(nd2_name) {
	c = 1;
	img = getTitle();
	nd_name = File.nameWithoutExtension;
	
	if (endsWith(img, "C=1")) {
		c = 2;
	}
	
	else if (endsWith(img, "C=2")) {
		c = 3;
	}
	
	else if (endsWith(img, "C=3")) {
		c = 4;
	}
	
	img_s = img.substring(0, img.length-1);
	
	for (j=0; j<c; j++) {
		temp = img_s+ "" + j;
		selectWindow(temp);
		run("Z Project...", "projection=[Max Intensity]");
		
		p_name = max_dir + File.separator + nd_name+"_C="+j;
		saveAs("Tiff", p_name);
		close();
		close(temp);
}

}


