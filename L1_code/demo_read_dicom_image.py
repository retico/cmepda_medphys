# Python script to read a DICOM file with a single image, such as a mammography projection:
# e.g. "DATASETS/IMAGES/DICOM_Examples/Breast_Mammography_Case2/Series_71300000_MG_L_CC/1.3.6.1.4.1.5962.99.1.2280943358.716200484.1363785608958.376.0.dcm"
# Requirements:
# pip install pydicom matplotlib numpy

import sys
import numpy as np
import matplotlib.pyplot as plt
import pydicom
from pydicom.pixel_data_handlers.util import apply_voi_lut

def load_dicom_image(path, use_windowing=True):
    """
    Loads a DICOM image and returns a display-ready numpy array and the dataset.
    Applies VOI LUT (windowing) if available and desired.
    """
    ds = pydicom.dcmread(path)

    # Convert pixel data to a numpy array
    pixel_array = ds.pixel_array  # pydicom decodes compressed transfer syntaxes if supported

    # Apply VOI LUT if present (this handles window center/width and LUTs properly)
    if use_windowing:
        try:
            pixel_array = apply_voi_lut(pixel_array, ds)
        except Exception:
            # Fallback: apply a simple linear transform using WC/WW if available
            wc = float(ds.get("WindowCenter", 0))
            ww = float(ds.get("WindowWidth", 0))
            if ww:
                low = wc - ww / 2
                high = wc + ww / 2
                pixel_array = np.clip(pixel_array, low, high)

    # Convert to Hounsfield Units if CT and rescale slope/intercept present
    intercept = float(ds.get("RescaleIntercept", 0))
    slope = float(ds.get("RescaleSlope", 1))
    pixel_array = pixel_array.astype(np.float32) * slope + intercept

    # Normalize to 0–1 for display
    # For CT, a common window is [-1000, 400] (lung/soft tissue varies).
    vmin = np.percentile(pixel_array, 1)
    vmax = np.percentile(pixel_array, 99)
    img = np.clip((pixel_array - vmin) / (vmax - vmin + 1e-6), 0, 1)

    return img, ds

def show_dicom(img, ds, cmap="gray"):
    """
    Shows a 2D DICOM image with patient and modality info in the title.
    """
    patient = ds.get("PatientID", "Unknown")
    study = ds.get("StudyDescription", "")
    series = ds.get("SeriesDescription", "")
    modality = ds.get("Modality", "NA")
    title = f"{modality} | Patient: {patient} | {study} | {series}"

    plt.figure(figsize=(6, 6))
    plt.imshow(img, cmap=cmap)
    plt.axis("off")
    plt.title(title, fontsize=10)
    plt.tight_layout()
    plt.show()


if __name__ == "__main__":
    if len(sys.argv) > 1:
        dicom_path = sys.argv[1]
        print(f"Processing the file: {dicom_path}")
        img, ds = load_dicom_image(dicom_path, use_windowing=True)
        show_dicom(img, ds)
    else:
        print("The dcm file should be passed as an argument, please try again")
