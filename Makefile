work/.folder_structure_sentinel:

	mkdir -p data/imagenet/bb
	mkdir data/imagenet/images

	mkdir -p data/alov/bb

	mkdir -p work/imagenet
	mkdir -p work/alov/images

	touch work/.folder_structure_sentinel

####################
# ALOV300++ Datset #
####################

# Frames #
work/.alov_frames_sentinel: 
	curl http://isis-data.science.uva.nl/alov/alov300++_frames.zip -O 
	tar xvf alov300++_frames.zip
	mv imagedata++ data/alov/frames
	rm -rf alov300++_frames.zip imagedata++
	touch work/.alov_frames_sentinel

# Bounding Boxes #
work/.alov_bb_sentinel: 
	curl http://isis-data.science.uva.nl/alov/alov300++GT_txtFiles.zip -O 
	unzip alov300++GT_txtFiles.zip
	find alov300++_rectangleAnnotation_full -type f -name '*.ann' \
		-exec mv {} data/alov/bb/ \; 
	rm -rf alov300++GT_txtFiles.zip alov300++_rectangleAnnotation_full
	touch work/.alov_bb_sentinel

work/alov/parsed_bb.csv: work/.alov_bb_sentinel work/.alov_frames_sentinel
	python code/data_setup/parse_alov_bb.py data/alov/bb/ work/alov/parsed_bb.csv

#########################
# ILSVRC2014 (ImageNet) #
#########################

# Training Bounding Boxes #
work/.imagenet_training_bbox_sentinel:
	curl http://image-net.org/image/ilsvrc2014/ILSVRC2014_DET_bbox_train.tgz -O
	tar xvf ILSVRC2014_DET_bbox_train.tgz
	find ILSVRC2014_DET_bbox_train/ -type f -name '*.xml' \
		-exec mv {} data/imagenet/bb \; 
	rm -rf ILSVRC2014_DET_bbox_train.tgz ILSVRC2014_DET_bbox_train
	touch work/.imagenet_training_bbox_sentinel

# Validation Bounding Boxes #
work/.imagenet_validation_bbox_sentinel:
	curl http://image-net.org/image/ilsvrc2013/ILSVRC2013_DET_bbox_val.tgz -O
	tar xvf ILSVRC2013_DET_bbox_val.tgz
	find ILSVRC2013_DET_bbox_val/ -type f -name '*.xml' \
		-exec mv {} data/imagenet/bb \; 
	rm -rf ILSVRC2013_DET_bbox_val.tgz ILSVRC2013_DET_bbox_val
	touch work/.imagenet_validation_bbox_sentinel

work/imagenet/parsed_bb.csv: work/.imagenet_training_bbox_sentinel \
	work/.imagenet_validation_bbox_sentinel
	python code/data_setup/parse_imagenet_bb.py data/imagenet/bb/ \
		work/imagenet/parsed_bb.csv

data/fall11_imagenet_urls.txt:
	curl http://image-net.org/imagenet_data/urls/imagenet_fall11_urls.tgz \
	  -o data/imagenet_fall11_urls.tgz
	tar xvf data/imagenet_fall11_urls.tgz
	rm data/imagenet_fall11_urls.tgz
	mv fall11_urls.txt data/fall11_imagenet_urls.txt


work/.imagenet_training_images_sentinel: code/data_setup/download_images.py data/fall11_imagenet_urls.txt
	python code/data_setup/download_images.py "training"
	touch work/.imagenet_training_images_sentinel

work/.imagenet_validation_images_sentinel: code/data_setup/download_images.py data/fall11_imagenet_urls.txt
	python code/data_setup/download_images.py "validation"
	touch work/.imagenet_validation_images_sentinel


imagenet_bb: work/imagenet/parsed_bb.csv 
alov_bb: work/alov/parsed_bb.csv
data: work/.folder_structure_sentinel imagenet_bb alov_bb
imagenet_images: work/.imagenet_training_images_sentinel work/.imagenet_validation_images_sentinel
