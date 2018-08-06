# Weakly- and Semi-Supervised Panoptic Segmentation
by [Qizhu Li](http://www.robots.ox.ac.uk/~liqizhu/)\*, [Anurag Arnab](http://www.robots.ox.ac.uk/~aarnab/)\*, [Philip H.S. Torr](https://scholar.google.com/citations?user=kPxa2w0AAAAJ&hl=en)

This repository demonstrates the weakly supervised ground truth generation scheme presented in our paper *Weakly- and Semi-Supervised Panoptic Segmentation* published at ECCV 2018. The code has been cleaned-up and refactored, and should reproduce the results presented in the paper.

For details, please refer to our [paper](#), and [project page](#).

![Summary](data/readme/summary.png)


<sup><sub> \* Equal first authorship </sup></sub>

## Introduction
In our weakly-supervised *panoptic* segmentation experiments, our models are supervised by 1) image-level tags and 2) bounding boxes, as shown in the figure above.
We used image-level tags as supervision for "stuff" classes which do not have a defined extent and cannot be described well by tight bounding boxes. For "thing" classes, we used bounding boxes as our weak supervision. This code release clarifies the implementation details of the method presented in the paper.

## Iterative ground truth generation 
For readers' convenience, we will give an outline of the proposed iterative ground truth generation pipeline, and provide demos for some of the key steps.

1. We train a multi-class classifier for all classes to obtain rough localisation cues. As it is not possible to fit an entire Cityscapes image (1024x2048) into a network due to GPU memory constraints, we took 15 fixed 400x500 crops per training image, and derived their classification ground truth accordingly, which we use to train the multi-class classifier. From the trained classifier, we extract the Class Activation Maps (CAMs) using Grad-CAM, which has the advantage of being agnostic to network architecture over CAM.
   - Download the fixed image crops with image-level tags [here](#) to train your own classifier. For convenience, the pixel-level semantic label of the crops are also included, though they should not be used in training.
   - The CAMs we produced are available for download [here](#).
2. In parallel, we extract bounding box annotations from Cityscapes ground truth files, and then run MCG (a segment-proposal algorithm) and Grabcut (a classic foreground segmentation technique given a bounding-box prior) on the training images to generate foreground masks inside each annotated bounding box. MCG and Grabcut masks are merged following the rule that only regions where both have consensus are given the predicted label; otherwise an "ignore" label is assigned.
   - The extracted bounding boxes (saved in .mat format) can be downloaded [here](#). Alternatively, we also provide a demo script `demo_instanceTrainId_to_dets.m` and a batch script `batch_instanceTrainId_to_dets.m` for you to try it out yourself. The demo is self-contained; to run the batch script, make sure to
        1. download the [official Cityscapes scripts repository](https://github.com/mcordts/cityscapesScripts),
        2. inside the above repository, navigate to `cityscapesscripts/preparation` and run `python createTrainIdInstanceImgs.py`; this command requires an environment variable `CITYSCAPES_DATASTET=path/to/your/cityscapes/data/folder`.
   - Please see [here](#) for details on MCG.
   - We use the [OpenCV implementation](https://docs.opencv.org/3.2.0/d8/d83/tutorial_py_grabcut.html) of Grabcut in our experiments.
   - The merged M&G masks we produced are available for download [here](#).
3. The CAMs (step 1) and M&G masks (step 2) are merged to produce the ground truth needed to kick off iterative training. To see a demo of merging, navigate to the root folder of this repo in MATLAB and run:
   ```
    demo_merge_cam_mandg;
   ```
   When post-processing network predictions of images from the Cityscapes `train_extra` split, make sure to use the following settings:
   ```
   opts.run_apply_bbox_prior = false;
   opts.run_check_image_level_tags = false;
   opts.save_ins = false;
   ```
   because the coarse annotation provided on the `train_extra` split trades off recall for precision, leading to inaccurate bounding box coordinates, and frequent occurrences of false negatives. This also applies to step 5.
4. Using the generated ground truth, weakly-supervised models can be trained in the same way as a fully-supervised model. When the training loss converges, we make dense predictions using the model and also save the prediction scores. 
   - An example of dense prediction made by a weakly-supervised model is included at `results/pred_sem_raw/`, and an example of the corresponding prediction scores is provided at `results/pred_flat_feat/`. 
5. The prediction and prediction scores (and optionally, the M&G masks) are used to generate the ground truth labels for next stage of iterative training. To see a demo of iterative ground truth generation, navigate to the root folder of this repo in MATLAB and run:
   ```
   demo_make_iterative_gt;
   ```
    The generated semantic and instance ground truth labels are saved at `results/pred_sem_clean` and `results/pred_ins_clean` respectively. 
    
    Please refer to `scripts/get_opts.m` for the options available. To reproduce the results presented in the paper, use the default setting, and set `opts.run_merge_with_mcg_and_grabcut` to `false` after five iterations of training, as the weakly supervised model by then produces better quality segmentation of ''thing'' classes than the original M&G masks. 
6. Repeat step 4 and 5 until training loss no longer reduces.

## Reference
If you find the code helpful in your research, please cite our paper:

```
@inproceedings{li2018wsps,
    author = {Qizhu Li and
              Anurag Arnab and
              Philip H.S. Torr},
    title = {Weakly- and Semi-Supervised Panoptic Segmentation},
    booktitle = {European Conference on Computer Vision (ECCV)},
    year = {2018}
}
```
## Questions
Please contact Qizhu Li <qizhu.li@eng.ox.ac.uk> and Anurag Arnab <aarnab@robots.ox.ac.uk> for enquires, issues, and suggestions.
