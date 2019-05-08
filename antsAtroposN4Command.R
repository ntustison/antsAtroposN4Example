library( ANTsR )

baseDirectory <- './'
dataDirectory <- paste0( baseDirectory, 'Images/' )

outputDirectory <- paste0( baseDirectory, 'OutputANTsR/' )
if( ! dir.exists( outputDirectory ) )
  {
  dir.create( outputDirectory )
  }
outputPrefix <- paste0( outputDirectory, 'antsr' )

numberOfOuterIterations <- 5

image <- antsImageRead( paste0( dataDirectory, 'KKI2009-01-MPRAGE_slice150.nii.gz' ), dimension = 2 )
mask <- antsImageRead( paste0( dataDirectory, 'KKI2009-01-MPRAGE_slice150_mask.nii.gz' ), dimension = 2 )
weightMask <- NULL

for( i in seq_len( numberOfOuterIterations ) )
  {
  cat( "***************   N4 <---> Atropos iteration ", i, "  ******************" )
  n4Results <- n4BiasFieldCorrection( img = image, mask = mask,
    weight_mask = weightMask, verbose = TRUE )
  image <- n4Results

  atroposResults <- atropos( a = image, x = mask, verbose = TRUE )

  # only use gm and wm probabilities for weight mask
  weightMask <- atroposResults$probabilityimages[[2]] *
                  ( 1 - atroposResults$probabilityimages[[1]] ) *
                  ( 1 - atroposResults$probabilityimages[[3]] ) +
                atroposResults$probabilityimages[[3]] *
                  ( 1 - atroposResults$probabilityimages[[1]] ) *
                  ( 1 - atroposResults$probabilityimages[[2]] )
  }

antsImageWrite( image, paste0( outputPrefix, "N4Corrected.nii.gz" ) )
antsImageWrite( atroposResults$segmentation, paste0( outputPrefix, "AtroposSegmentation.nii.gz" ) )

for( i in seq_len( length( atroposResults$probabilityimages ) ) )
  {
  antsImageWrite( atroposResults$probabilityimages[[i]],
    paste0( outputPrefix, "AtroposSegmentationProbability", i, ".nii.gz" ) )
  }

