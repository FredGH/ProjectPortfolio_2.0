#!/usr/bin/python

# Ref:https://confluence.slac.stanford.edu/display/PSDM/How+to+access+HDF5+data+from+Python 

import h5py
import numpy as np

#
# Bounding Box
#
class BBox:
    def __init__(self):
        self.label = ""     # Digit
        self.left = 0
        self.top = 0
        self.width = 0
        self.height = 0

class DigitStruct:
    def __init__(self):
        self.name = None    # Image file name
        self.bboxList = None # List of BBox structs

# Function for debugging
def printHDFObj(theObj, theObjName):
    isFile = isinstance(theObj, h5py.File)
    isGroup = isinstance(theObj, h5py.Group)
    isDataSet = isinstance(theObj, h5py.Dataset)
    isReference = isinstance(theObj, h5py.Reference)
    print "{}".format(theObjName)
    print "    type(): {}".format(type(theObj))
    if isFile or isGroup or isDataSet:
        # if theObj.name != None:
        #    print "    name: {}".format(theObj.name)
        print "    id: {}".format(theObj.id)
    if isFile or isGroup:
        print "    keys: {}".format(theObj.keys())
    if not isReference:
        print "    Len: {}".format(len(theObj))

    if not (isFile or isGroup or isDataSet or isReference):
        print theObj

def readDigitStructGroup(dsFile):
    dsGroup = dsFile["digitStruct"]
    return dsGroup

#
# Reads a string from the file using its reference
#
def readString(strRef, dsFile):
    strObj = dsFile[strRef]
    str = ''.join(chr(i) for i in strObj)
    return str

#
# Reads an integer value from the file
#
def readInt(intArray, dsFile):
    intRef = intArray[0]
    isReference = isinstance(intRef, h5py.Reference)
    intVal = 0
    if isReference:
        intObj = dsFile[intRef]
        intVal = int(intObj[0])
    else: # Assuming value type
        intVal = int(intRef)
    return intVal

def yieldNextInt(intDataset, dsFile):
    for intData in intDataset:
        intVal = readInt(intData, dsFile)
        yield intVal 

def yieldNextBBox(bboxDataset, dsFile):
    for bboxArray in bboxDataset:
        bboxGroupRef = bboxArray[0]
        bboxGroup = dsFile[bboxGroupRef]
        labelDataset = bboxGroup["label"]
        leftDataset = bboxGroup["left"]
        topDataset = bboxGroup["top"]
        widthDataset = bboxGroup["width"]
        heightDataset = bboxGroup["height"]

        left = yieldNextInt(leftDataset, dsFile)
        top = yieldNextInt(topDataset, dsFile)
        width = yieldNextInt(widthDataset, dsFile)
        height = yieldNextInt(heightDataset, dsFile)

        bboxList = []

        for label in yieldNextInt(labelDataset, dsFile):
            bbox = BBox()
            bbox.label = label
            bbox.left = next(left)
            bbox.top = next(top)
            bbox.width = next(width)
            bbox.height = next(height)
            bboxList.append(bbox)

        yield bboxList

def yieldNextFileName(nameDataset, dsFile):
    for nameArray in nameDataset:
        nameRef = nameArray[0]
        name = readString(nameRef, dsFile)
        yield name

# dsFile = h5py.File('../data/gsvhn/train/digitStruct.mat', 'r')
def yieldNextDigitStruct(dsFileName):
    dsFile = h5py.File(dsFileName, 'r')
    dsGroup = readDigitStructGroup(dsFile)
    nameDataset = dsGroup["name"]
    bboxDataset = dsGroup["bbox"]

    bboxListIter = yieldNextBBox(bboxDataset, dsFile)
    for name in yieldNextFileName(nameDataset, dsFile):
        bboxList = next(bboxListIter)
        obj = DigitStruct()
        obj.name = name
        obj.bboxList = bboxList
        yield obj
        
        
        
def convert(imgf, labelf, outf, n):
    f = open(imgf, "r")
    o = open(outf, "w")
    l = open(labelf, "r")

    f.read(16)
    l.read(8)
    images = []

    for i in range(n):
        image = [ord(l.read(1))]
        for j in range(28*28):
            image.append(ord(f.read(1)))
        images.append(image)

    for image in images:
        o.write(",".join(str(pix) for pix in image)+"\n")
    f.close()
    o.close()
    l.close()

def commaSeparatedFileGenerator(filePath):

    dsFileName = 'C:\Users\Frederic\Downloads\Compressed\digitStruct.mat'
    testCounter = 0
    for dsObj in yieldNextDigitStruct(dsFileName):
        # testCounter += 1
        #print dsObj.name
        for bbox in dsObj.bboxList:
            print "{},{},{},{},{},{}".format(
                dsObj.name, bbox.label, bbox.left, bbox.top, bbox.width, bbox.height)
        if testCounter >= 5:
            break


if __name__ == "__main__":

    print " ---------------Training Records----------------------- "

    #generate the training records for the csv file
    commaSeparatedFileGenerator('C:\Users\Frederic\Downloads\Compressed\train\digitStruct.mat')
    
    print " ---------------Test Records----------------------- "
    
    #generate the test records for the csv file 
    commaSeparatedFileGenerator('C:\Users\Frederic\Downloads\Compressed\test\digitStruct.mat')
