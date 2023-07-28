# set default shell
SHELL = bash -e -o pipefail

default: run

.PHONY:	install
install:
	fvm flutter pub get

.PHONY:	analyze
analyze:
	fvm flutter analyze

.PHONY:	lint-dry-run
lint-dry-run:
	fvm dart fix --dry-run
	
.PHONY:	lint-fix
lint-fix:
	fvm dart fix --apply

.PHONY:	test
test:
	fvm flutter test

.PHONY:	test-unit
test-unit:
	fvm flutter test test/unit

.PHONY:	test-widget
test-widget:
	fvm flutter test test/widget

.PHONY:	clean
clean:
	fvm flutter clean

.PHONY:	run
run:
	fvm flutter run

.PHONY:	compile
compile:
	fvm flutter clean
	fvm flutter pub get
	fvm flutter pub run build_runner build --delete-conflicting-outputs

.PHONY:	build-json
build-json:
	fvm flutter pub run build_runner build --delete-conflicting-outputs