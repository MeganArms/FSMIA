# FSMIA
**Fluorescent Single Molecule Imaging Analysis**  
Developed in The Lab for Nanobiotechnology by Dr. Siheng He and Megan Armstrong  
Department of Biomedical Engineering  
School of Engineering and Applied Science  
Columbia University  

## What is the purpose of this directory?
The files here are designed to locate and parameterize fluorescent particles in an image or image sequence. 

Input: An ND2 or TIFF image. The image is processed in grayscale.

Required: MATLAB and Bio-Formats library `bfmatlab` (available in this directory or [here](https://www.openmicroscopy.org/site/support/bio-formats5.1/users/matlab/)).

Output: An FSMIA object with properties **Filename**, **Option**, **Molecule**, **Frame**, **Result**, and **Intensity**.

Definitions:

- **Filename**: full path location of the image to be analyzed
- **Option**:
	* Threshold: level to make image binary.
	* Spot radius: estimated radius of the point spread function of the particle in pixels. This sets the size of the subimage used for fitting.
	* Pixel size_: size of a pixel in nanometers.
	* Include only region: `[min, max]`, where the included region is a centered square ranging from `i` and `j` coordinates `[min:max, min:max]`.
	* Exclude region: `[i1, j1; i2, j2]` region in image or image sequence that will be set to zero, i.e. not be included in the analysis.
	* Connect distance: the maximum distance between two particles on different frames at which they will still be considered the same particle (in nanometers).
	* Fitting: Centroid ('fast') or Gaussian ('slow') fitting.
	* Isolation Method: Set the method for insuring that two neighboring particles are not so close that they effect the fitting process. 
		* ‘fast’ will set any pixel on the border of the subimage that is above the threshold level to the minimum of the subimage.
		* ‘slow’ will attempt to fit any pixel on the border with a Gaussian to check if it is a particle. If it is a particle, it will set the	pixel to the minimum of the subimage.
	* Downsampling rate: Set this to greater than 1 to reduce the number of frames analyzed. For example, if the rate were 5, every fifth frame would be analyzed.
	* Illumination: Correct for uneven illumination ('on') or assume a uniform background illumination ('off').
	* Background: Estimated or measured background level in counts.
	* Wavelength: Excitation wavelength.
	* Numerical aperture: Numerical aperture of the objective.
- **Molecule**: structure with 6 fields whose length is the number of molecules found in the image or image sequence. The fields are:
	* centroid: the centroid of the region that is found to be above the threshold level (for fast fitting). It is given in nm away from the center of the center pixel of the subregion defined by the spot radius.
	* volume: the total intensity counts above background over the area that is found to be above the threshold level (for fast fitting).
	* area: the area in nm^2 that is found to be above the threshold level (for fast fitting).
	* maxInt: the maximum intensity in counts in the region where the particle was detected minus the backgroudn (for fast fitting). Or, it's the amplitude of the Gaussian fit to the point spread function (for slow fitting).
	* fit: the fit object that describes the point spread function of the particle (for slow fitting).
	* gof: the goodness of fit of the fit object to the point spread function (for slow fitting).
	* coordinate: the `[i,j]` coordinates of the pixel that the particle can be found on.
	* frame: frame number of the particle.
	* To: the next frame number where the particle is found.
	* From: the previous frame number where the particle is found.
	* Coords: the subpixel coordinates of the particle trajectories, where the coordinates are given in microns. The origin is at `[i,j] = [1,1]`.
	* Result: described below. The trajectories are stored additionally with the molecule whose index is the start of the trajectory.
- **Frame**: structure with 1 field whose length is the number of frames in the image sequence. The one field is:
	* MoleculeIndex: A vector indexing the particles found in that frame. Listing is continuous across frames.
- **Result**: structure with 1 field whose length is the number of particles that appear for more than one consecutive frame. The one field is:
	* trajectory: each entry is a vector of the particle indices that are connected to each other. This information should match that in the To/From fields of the Molecule property.
- **Intensity**: a matrix whose length is the number of particles that appear on more than one frame consecutively. The first column is the maximum volume integral of the particle over all the frames. The second column is the maximum maximum intensity of the volume integral over all the frames. The third column is the number of frames that the particle appears on consecutively. The fourth column is standard deviation of the fit to the point spread function.


## Quick Start Guide to FSMIA

### Filter image to set threshold 
- Run in the command window:
```
FilterGUI
```
- Browse for the file to be analyzed. 
- Enter the frame number to be filtered. 
- Set the output file to the same as the input. Add “_filter###” to the end of the filename before the extension. Replace ### with the frame number that was filtered.
- Click “uneven illumination” if there is uneven illumination to be corrected for.
- Click OK to filter.
- The recommended threshold will be output to the command window.

### Initialize FSMIA object
- Run in the command window:
```
movie1 = FSMIA(‘filename’);
```
- 'filename' is the full path to the image **stack** to be analyzed.
- This initializes the FSMIA object MOVIE1 with properties described above.

### Set FSMIA properties
- Run in the command window:
```
setoption(movie1);
```
- The properties of movie1.Option are described above, but use these below as a quick start:
	- Use the threshold recommended by FilterGUI.
	- Use observation to choose the expected size of the point spread function to set spotR. Count the number of pixels that the particles span.
	- Get the pixel size from the camera specs.
	- Set exclude to 0.
	- Set include to 0.
	- Connect distance must be determined by expected diffusion. Set to zero for no expected diffusion. Set this to the maximum number of pixels a particle moves between frames times the pixel size.
	- Fitting method: 'fast'
	- Isolation method: 'fast'
	- Downsampling rate: 1
	- Illumination correction: 'on'
	- Background: Find the value of a region with no visibile particles and find the intensity value in ImageJ or using `imshow` and the data cursor. 1000 is normal.
	- Wavelength: 647
	- Numerical aperture: 1.49

### Perform analysis
- Run in the command window:
```
analyzestack(movie1, movie1.filename);
createTrajectories(movie1);
coords = getCoordinates(movie1);
particleSize(movie1);
[~, Displacements, ~] = findSteps(coords,1);
[msd,D] = Dcoeff(Displacements,0.05);
```
This series of steps will:
- Analyze frames for particles
- Connect particles on sequential frames
- Extract the subpixel path coordinates
- Analyze the particles for size
- Get the displacement size between particles on sequential frames
- Find the diffusion coefficient, D, and plot the mean squared displacement against time steps.

### Visualize results
- Run in the command window:
```
ShowMarker(movie1,1);
```
This visualizes all the particles that are detected on frame one. The numbers are the trajectory numbers associated with the particle, which are zero if the particle stays for fewer than one frame. Pick a trajectory number on a particle (not 0), e.g. 10.
  
- Run in the command window
```
plotTrajectory(movie1,10,'on');
```
This will create an `avi` movie of trajectory 10 overlaid on the corresponding frames of the input video.
