#!/usr/bin/env sh
DIR="$(cd "$(dirname "$0")" >/dev/null && pwd)"
exec "$JAVA_HOME/bin/java" -Dorg.gradle.appname=gradlew -classpath "$DIR/gradle/wrapper/gradle-wrapper.jar" org.gradle.wrapper.GradleWrapperMain "$@"