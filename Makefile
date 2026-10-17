# The commands CI and a human share, so "green locally" and "green in CI"
# mean the same thing. Needs JDK 21 and the Android SDK (platform 34,
# build-tools 34.0.0); the Android build workflow installs both in-job.

GRADLE ?= ./gradlew

.PHONY: build test lint check

build:
	$(GRADLE) :app:assembleDebug

# No unit tests exist yet; this is the real Gradle task, so the first test
# landed runs with no further wiring.
test:
	$(GRADLE) :app:test

lint:
	$(GRADLE) :app:lint

check: build test lint
