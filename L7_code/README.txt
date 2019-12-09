Legend of the extracted features:
- first column is the image ID;
- second is the score of appropriateness of segmentation provided by radiologist: 1=good, 2=acceptable;
- 18 features, as described below; 
- last two columns are [0 1] for benign mass, and [1 0] for malignant ones

Feature order:
    (1)MASS AREA (pixel sum)
    (2)MASS PERIMETER LENGHT
    (3)COMPACTNESS(CIRCULARITY)
    (4)MEAN of NORMALIZED RDIAL LENGHT
    (5)STD of NORMALIZED RADIAL LENGHT(SPICULATION)
    (6)RADIAL DISTANCE ENTROPY
    (7)ZERO CROSSING(spiculation)
    (8)MAX AXIS
    (9)MIN AXIS
    (10)VARIATION RATIO MEAN
    (11)VARIATION RATIO STANDARD DEVIATION
    (12)CONVEXITY(not pixel area)
    (13)MEAN INTENSITY of MASS
    (14)STD INTENSITY of MASS(smoothness of intensity)
    (15)INTENSITY KURTOSIS of MASS(outlier prone)
    (16)INTENSITY SKEWNESS of MASS(asymmetry of data around mean)
    (17)MEAN INTENSITY of margin
    (18)STD INTENSITY of margin
    
