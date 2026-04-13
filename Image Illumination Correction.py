import os
import tifffile
import numpy as np
import matplotlib.pyplot as plt
import matplotlib.patches as patches
from skimage.morphology import disk
from skimage.filters import threshold_otsu, rank, try_all_threshold
from skimage import measure, data, util
from scipy.ndimage import median_filter
from tqdm.auto import tqdm
import cv2
import shapely
import geojson
import geopandas
from shapely.geometry import shape
from shapely.strtree import STRtree
import pandas as pd
import rasterio.features
import rasterstats
 
def calculate_normalising_image(images, masks, patch_size, offset=0, fixed_offset=0, tissue_fraction=0.9, return_patch=False, norm_shape=None, dapi_channel=0):
    patches_list = []
    for idx, image in enumerate(images):
        im = image[dapi_channel]
        for i in range(im.shape[0]//patch_size):
            for j in range(im.shape[1]//patch_size):
                i_pos = i*patch_size-i*offset+fixed_offset
                j_pos = j*patch_size-j*offset+fixed_offset
                if (i_pos>im.shape[0]) or (j_pos>im.shape[1]):
                    continue
                patch = im[i_pos:i_pos+patch_size,j_pos:j_pos+patch_size]
                mask_patch = masks[idx][i_pos:i_pos+patch_size,j_pos:j_pos+patch_size]
                if mask_patch.sum()>tissue_fraction*patch_size**2:
                    patches_list.append(patch)
 
    norm_patch = np.mean(np.stack(patches_list), axis=0)
    if return_patch:
        return norm_patch
    else:
        if norm_shape is None:
            norm_shape = (images[0][dapi_channel].shape[0], images[0][dapi_channel].shape[1])
        x_norm = np.concatenate((1+norm_shape[0]//patch_size)*[norm_patch], axis=0)
        full_norm = np.concatenate((1+norm_shape[1]//patch_size)*[x_norm], axis=1)
        return full_norm[fixed_offset:norm_shape[0]+fixed_offset, fixed_offset:norm_shape[1]+fixed_offset]
 
def keep_largest_object(image):
    labels_mask = measure.label(image)                       
    regions = measure.regionprops(labels_mask)
    regions.sort(key=lambda x: x.area, reverse=True)
    if len(regions) > 1:
        for rg in regions[1:]:
            labels_mask[rg.coords[:,0], rg.coords[:,1]] = 0
    labels_mask[labels_mask!=0] = 1
    mask = labels_mask
    return mask
 
def find_local_mask(image, channels, radius=5):
    inv_img = np.mean(image[channels], axis=0)
    img = (inv_img.max()-inv_img)
    img = (img-img.min())/img.max()
 
    footprint = disk(radius)
    local_otsu = rank.otsu((1-img), footprint)
 
    mask = 255*(1-img)>=local_otsu
    return mask
 
def filter_image(image, downsample=10, filter_size=(10,10)):
    resized_image = cv2.resize(image, (image.shape[1]//downsample,image.shape[0]//downsample))
    filtered_image = median_filter(resized_image, size=filter_size)
    resized_image = cv2.resize(filtered_image, (image.shape[1],image.shape[0]))
    return resized_image
 
def process_images(images, cyt_channels, patch_size=924, offset=0, fixed_offset=0, tissue_fraction=0.9, downsample=10, radius=5, dapi_channel=0, nfat_channel=11):
    filtered_images = [filter_image(im[dapi_channel], downsample=downsample) for im in tqdm(images)]
    otsu_image_masks = [keep_largest_object(filtered_image>=threshold_otsu(filtered_image)) for filtered_image in tqdm(filtered_images)]
    full_norm = calculate_normalising_image(images, otsu_image_masks, patch_size, offset=offset, fixed_offset=fixed_offset, tissue_fraction=tissue_fraction, dapi_channel=dapi_channel)
    out_image_list = [im/full_norm for im in tqdm(images)]
    filtered_images = [filter_image(im[dapi_channel], downsample=downsample) for im in tqdm(out_image_list)]
    otsu_image_masks = [keep_largest_object(filtered_image>=threshold_otsu(filtered_image)) for filtered_image in tqdm(filtered_images)]
    mask_list = [find_local_mask(out_image, cyt_channels, radius=radius) for out_image in tqdm(out_image_list)]
    masked_full_images = [otsu_image_masks[i]*im for i, im in tqdm(enumerate(out_image_list))]
    cell_masks = [(1-mask)*otsu_image_masks[i] for i, mask in tqdm(enumerate(mask_list))]
    cyt_list = [out_image_list[i][nfat_channel]*(1-cell_masks[i]) for i in range(len(out_image_list))]
    nuc_list = [out_image_list[i][nfat_channel]*cell_masks[i] for i in range(len(out_image_list))]
    return masked_full_images, cell_masks, nuc_list, cyt_list, mask_list
 
PATCH_SIZE=924
OFFSET=0
FIXED_OFFSET=0
TISSUE_FRACTION = 0.9
DOWNSAMPLE = 10
RADIUS = 5
DAPI_CHANNEL = 0
NFAT_CHANNEL = 11
 
# cyt_channels = [5,6,7,8,9,12,16,17,20]
cyt_channels = [5,6,4,8,9,11,15,16,19]
 
conditions = [("Sample1",i) for i in range(3,4)]+[("Sample2",i) for i in range(3,4)]+[("Sample3",i) for i in range(3,4)]+[("Sample4",i) for i in range(3,4)]+[("Sample5",i) for i in range(3,4)]
names = [condition+'_'+str(repeat) for condition, repeat in conditions]
 
images = [tifffile.imread(f"/beatson/R24/Lucas/CODEX/TMA011_2/codex_24_r02_tma011_ccr7_2_{condition}_{repeat}.tif") for condition, repeat in conditions]
masked_full_images, cell_masks, nuc_list, cyt_list, tissue_masks = process_images(images, patch_size=PATCH_SIZE, offset=OFFSET, fixed_offset=FIXED_OFFSET, tissue_fraction=TISSUE_FRACTION, downsample=DOWNSAMPLE, radius=RADIUS, dapi_channel=DAPI_CHANNEL, nfat_channel=NFAT_CHANNEL)
