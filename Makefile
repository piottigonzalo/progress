bundle:
	flutter build appbundle
generate:
	java -jar bundletool.jar build-apks --bundle=progress/build/app/outputs/bundle/release/app-release.aab --output=progress/progress.apks
push:
	java -jar bundletool.jar install-apks --apks=progress/progress.apks --device-id R5CRB0C944M