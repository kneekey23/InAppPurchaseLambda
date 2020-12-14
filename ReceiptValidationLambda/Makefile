### Add functions here and link them to builder-bit format MUST BE "build-FunctionResourceName in template.yaml"

build-ReceiptValidationLambda: builder-bot

######################  No Change required below this line  ##########################

builder-bot:
				$(eval $@PRODUCT = $(subst build-,,$(MAKECMDGOALS)))
				$(eval $@BUILD_DIR = $(PWD)/.aws-sam/build-$($@PRODUCT))
				$(eval $@STAGE = $($@BUILD_DIR)/lambda)
				$(eval $@ARTIFACTS_DIR = $(PWD)/.aws-sam/build/$($@PRODUCT))

				# prep directories
				mkdir -p $($@BUILD_DIR)/lambda $($@ARTIFACTS_DIR)

				# Compile application
				docker run --rm -v $($@BUILD_DIR):/build-target -v `pwd`:/build-src -w /build-src builder bash -cl "swift build --product $($@PRODUCT) -c release -Xswiftc -static-stdlib --build-path /build-target"

				# link deps
				-docker run --rm -v $($@BUILD_DIR):/build-target -v `pwd`:/build-src -w /build-src builder bash -cl "cd /build-target/lambda && ln -s $($@PRODUCT) /bootstrap"

				# copy binary to stage
				cp $($@BUILD_DIR)/release/$($@PRODUCT) $($@BUILD_DIR)/lambda/bootstrap

				# copy app from stage to artifacts dir
				cp $($@STAGE)/* $($@ARTIFACTS_DIR)
