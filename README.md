# FSMIA
Fluorescent Single Molecule Imaging Analysis  
Developed in The Lab for Nanobiotechnology by Dr. Siheng He and Megan Armstrong  
Department of Biomedical Engineering  
School of Engineering and Applied Science  
Columbia University  

What is the purpose of this directory?
======================================
The files here are designed to locate and parameterize fluorescent particles in an image or image sequence. 

Input:  
An ND2 or TIFF image. The image is processed in grayscale.

Required:  
MATLAB and Bio-Formats library bfmatlab available [here](https://www.openmicroscopy.org/site/support/bio-formats5.1/users/matlab/)

Output:  
An FSMIA object with properties **Filename**, **Option**, **Molecule**, **Frame**, **Result**, and **Intensity**

Definitions:

- **Filename**: full path location of the image to be analyzed
- **Option**:
	* Threshold: level to make image binary.
	* Spot radius: estimated radius of the point spread function of the particle in pixels. This sets the size of the subimage used for fitting.
	* Pixel size_: size of a pixel in nanometers.
	* Exclude region: `[i1, j1; i2, j2]` region in image or image sequence that will be set to zero, i.e. not be included in the analysis.
	* Connect distance: the maximum distance between two particles on different frames at which they will still be considered the same particle (in nanometers).
	* Isolation Method: Set the method for insuring that two neighboring particles are not so close that they effect the fitting process. 
		* ‘fast’ will set any pixel on the border of the subimage that is above the threshold level to the minimum of the subimage.
		* ‘slow’ will attempt to fit any pixel on the border with a Gaussian to check if it is a particle. If it is a particle, it will set the	pixel to the minimum of the subimage.
	* Downsampling rate: Set this to greater than 1 to reduce the number of frames analyzed. For example, if the rate were 5, every fifth frame would be analyzed.
	* Include only region: `[min, max]`, where the included region is a centered square ranging from `i` and `j` coordinates `[min:max, min:max]`.
- **Molecule**: structure with 6 fields whose length is the number of molecules found in the image or image sequence. The fields are:
	* fit: the fit object that describes the point spread function of the particle.
	* gof: the goodness of fit of the fit object to the point spread function.
	* coordinate: the `[i,j]` coordinates of the pixel that the particle can be found on.
	* frame: frame number of the particle.
	* To: the next frame number where the particle is found.
	* From: the previous frame number where the particle is found.
- **Frame**: structure with 1 field whose length is the number of frames in the image sequence. The one field is:
	* MoleculeIndex: A vector indexing the particles found in that frame. Listing is continuous across frames.
- **Result**: structure with 1 field whose length is the number of particles that appear for more than one consecutive frame. The one field is:
	* trajectory: each entry is a vector of the particle indices that are connected to each other. This information should match that in the To/From fields of the Molecule property.
- **Intensity**: a matrix whose length is the number of particles that appear on more than one frame consecutively. The first column is the maximum volume integral of the particle over all the frames. The second column is the maximum maximum intensity of the volume integral over all the frames. The third column is the number of frames that the particle appears on consecutively. The fourth column is standard deviation of the fit to the point spread function.


Quick Start Guide to FSMIA
==========================

1. Run in the command window: 
```
FilterGUI
```
- Browse for the file to be analyzed. 
- Enter the frame number to be filtered. 
- Set the output file to the same as the input. Add “_filter###” to the end of the filename before the extension. Replace ### with the frame number that was filtered.
- Click “uneven illumination” if there is uneven illumination to be corrected for.
- Click OK to filter.
- The recommended threshold will be output to the command window.

2. Run in the command window:
```
movie1 = FSMIA(‘filename’);
```
- This initializes the FSMIA object MOVIE1 with properties described above.

3. Set options by running in the command window:
```
setoption(movie1);
```
- The properties of movie1.Option are described above, but use these below as a quick start:
	- Use the threshold recommended by FilterGUI.
	- Use observation to choose the expected size of the point spread function to set spotR.
	- Get the pixel size from the camera specs.
	- Set exclude to 0.
	- Connect distance must be determined by expected diffusion. Set to zero for no expected diffusion.
	- Isolation method: ‘fast’
	- Downsampling rate: 1
	- Include: 0

4. Run in the command window:
```
analyzestack(movie1, movie1.filename);
```
