#!/usr/bin/env python


import numpy as np

def im_to_mask(A, th = 0.5):
    """
    This function applies the threshold th to convert the A image into a mask 
    """
    B = A > th;
    return B


