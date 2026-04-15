import ij.gui.Wand
import qupath.lib.objects.PathObjects
import qupath.lib.regions.ImagePlane
import ij.IJ
import ij.process.ColorProcessor
import qupath.imagej.processing.RoiLabeling
import qupath.imagej.tools.IJTools
import java.util.regex.Matcher
import java.util.regex.Pattern
import qupath.lib.analysis.features.ObjectMeasurements

def directoryPath = 'Directory/to/3_nuclear' // TO CHANGE

clearAllObjects()
double downsample = 1 // TO CHANGE (if needed)
ImagePlane plane = ImagePlane.getDefaultPlane()

File folder = new File(directoryPath);
File[] listOfFiles = folder.listFiles();

currentImport = listOfFiles.find{ GeneralTools.getNameWithoutExtension(it.getPath()).contains(GeneralTools.getNameWithoutExtension(getProjectEntry().getImageName())) &&  it.toString().contains("masks")}

path = currentImport.getPath()
    /*if (!path.endsWith(".png"))
        return*/
def imp = IJ.openImage(path)


int n = imp.getStatistics().max as int
if (n == 0) {
    print 'No objects found!'
    return
}
def ip = imp.getProcessor()
    if (ip instanceof ColorProcessor) {
        throw new IllegalArgumentException("RGB images are not supported!")
    }
def roisIJ = RoiLabeling.labelsToConnectedROIs(ip, n)

    def rois = roisIJ.collect {
        if (it == null)
            return
        return IJTools.convertToROI(it, 0, 0, downsample, plane);
    }
    rois = rois.findAll{null != it}
    
    // Convert QuPath ROIs to objects
    def pathObjects = rois.collect {
        return PathObjects.createDetectionObject(it)
    }
    addObjects(pathObjects)
    
resolveHierarchy()


def imageData = getCurrentImageData()
server = imageData.getServer()
clearCellMeasurements()
cells = getDetectionObjects()
ObjectMeasurements.addShapeMeasurements(cells, server.getPixelCalibration())
 downsample = server.getDownsampleForResolution(0) // May want to compute at a different resolution!
def measurements = ObjectMeasurements.Measurements.values() as List
def compartments = ObjectMeasurements.Compartments.values() as List

cells.parallelStream().forEach { cell ->
    ObjectMeasurements.addIntensityMeasurements(server, cell, downsample, measurements, compartments)
}
fireHierarchyUpdate()


print "Import completed"

