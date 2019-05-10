import ants
import os

baseDirectory = './'
dataDirectory = baseDirectory + 'Images/'

outputDirectory = baseDirectory + 'OutputANTsPy/'
if not os.path.isdir( outputDirectory ):
  os.mkdir( outputDirectory )

outputPrefix = outputDirectory + 'antspy'

numberOfOuterIterations = 5

image = ants.image_read( dataDirectory + 'KKI2009-01-MPRAGE_slice150.nii.gz', dimension = 2 )
mask = ants.image_read( dataDirectory + 'KKI2009-01-MPRAGE_slice150_mask.nii.gz', dimension = 2 )
weightMask = None

for i in range( numberOfOuterIterations ):
  print( "***************   N4 <---> Atropos iteration ", i, "  ******************\n" )
  n4Results = ants.n4_bias_field_correction( image, mask = mask,
    weight_mask = weightMask, verbose = True )
  image = n4Results
  atroposResults = ants.atropos( a = image, x = mask )
  onesImage = ants.make_image( image.shape, voxval = 0,
    spacing = ants.get_spacing( image ),
    origin = ants.get_origin( image ),
    direction = ants.get_direction( image ) )
  weightMask = atroposResults['probabilityimages'][1] *\
    ( onesImage - atroposResults['probabilityimages'][0] ) *\
    ( onesImage - atroposResults['probabilityimages'][2] ) +\
    atroposResults['probabilityimages'][2] *\
    ( onesImage - atroposResults['probabilityimages'][1] ) *\
    ( onesImage - atroposResults['probabilityimages'][0] )

ants.image_write( image, outputPrefix + "N4Corrected.nii.gz" )
ants.image_write( atroposResults['segmentation'], outputPrefix + "AtroposSegmentation.nii.gz" )

for i in range( len( atroposResults['probabilityimages'] ) ):
  ants.image_write( atroposResults['probabilityimages'][i],
    outputPrefix + "AtroposSegmentationProbability" + str( i ) + ".nii.gz" )

